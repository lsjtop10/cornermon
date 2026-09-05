// Command loadtest drives a synthetic camp against a running server to check that
// the infrastructure holds up: it bootstraps a camp (corners, tracks, groups,
// approved facilitator devices), then runs a soak where each track holds an SSE
// connection and periodically starts/ends visits and sends chat messages while
// admins hold SSE connections and poll the live summary.
//
// Nothing here is camp-domain logic — it only speaks the public REST API — so it
// lives as a throwaway ops tool, stdlib only.
//
//	cd backend
//	cp cmd/loadtest/loadtest.example.yaml cmd/loadtest/loadtest.yaml   # fill in adminPassword
//	go run ./cmd/loadtest -config cmd/loadtest/loadtest.yaml
//
// Re-run just the soak against an existing bootstrap with -phases soak (reads
// stateFile). Tear the camp down afterwards with -phases teardown.
package main

import (
	"bufio"
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"math/rand"
	"net/http"
	"os"
	"os/signal"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"
)

// ── config ──────────────────────────────────────────────────────────────────

func (c config) D(key string, def time.Duration) time.Duration {
	v, ok := c.raw[key]
	if !ok || v == "" {
		return def
	}
	d, err := time.ParseDuration(v)
	if err != nil {
		log.Fatalf("config %s: %v", key, err)
	}
	return d
}

func (c config) S(key, def string) string {
	if v, ok := c.raw[key]; ok && v != "" {
		return v
	}
	return def
}

func (c config) I(key string, def int) int {
	v, ok := c.raw[key]
	if !ok || v == "" {
		return def
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		log.Fatalf("config %s: %v", key, err)
	}
	return n
}

func (c config) F(key string, def float64) float64 {
	v, ok := c.raw[key]
	if !ok || v == "" {
		return def
	}
	n, err := strconv.ParseFloat(v, 64)
	if err != nil {
		log.Fatalf("config %s: %v", key, err)
	}
	return n
}

// config is the flat key/value config file. The format is a deliberately tiny
// YAML subset — one `key: value` per line, `#` comments, `key: [a, b]` lists —
// so no YAML dependency is needed for ~a dozen scalars.
type config struct {
	raw map[string]string

	Base            string
	AdminID         string
	AdminPW         string
	Corners         int
	TracksPerCorner int
	Groups          int
	Admins          int
	VisitEvery      time.Duration
	VisitHoldFrac   float64 // fraction of VisitEvery a visit stays IN_PROGRESS (corner reads BUSY)
	ChatEvery       time.Duration
	ReadEvery       time.Duration // per-track: how often a facilitator checks/reads messages
	AdminPoll       time.Duration
	BroadcastEvery  time.Duration // admin: how often to send a camp-wide announcement
	Duration        time.Duration
	CampName        string
	StateFile       string
	Phases          []string
}

func loadConfig() config {
	path := flag.String("config", "loadtest.yaml", "path to config file")
	phasesOverride := flag.String("phases", "", "comma list overriding config phases (bootstrap,soak,teardown)")
	flag.Parse()

	b, err := os.ReadFile(*path)
	if err != nil {
		log.Fatalf("read config %s: %v", *path, err)
	}
	c := config{raw: map[string]string{}}
	for _, line := range strings.Split(string(b), "\n") {
		if i := strings.IndexByte(line, '#'); i >= 0 {
			line = line[:i]
		}
		k, v, ok := strings.Cut(line, ":")
		if !ok {
			continue
		}
		c.raw[strings.TrimSpace(k)] = strings.Trim(strings.TrimSpace(v), `"'`)
	}

	c.Base = c.S("base", "http://localhost:8080/api/v1")
	c.AdminID = c.S("adminId", "admin")
	c.AdminPW = c.S("adminPassword", "")
	c.Corners = c.I("corners", 10)
	c.TracksPerCorner = c.I("tracksPerCorner", 1)
	c.Groups = c.I("groups", 25)
	c.Admins = c.I("admins", 3)
	c.VisitEvery = c.D("visitEvery", 3*time.Minute)
	c.VisitHoldFrac = c.F("visitHoldFrac", 0.8)
	c.ChatEvery = c.D("chatEvery", 20*time.Second)
	c.ReadEvery = c.D("readEvery", 45*time.Second)
	c.AdminPoll = c.D("adminPoll", 5*time.Second)
	c.BroadcastEvery = c.D("broadcastEvery", 5*time.Minute)
	c.Duration = c.D("duration", 30*time.Minute)
	c.StateFile = c.S("stateFile", "loadtest-state.json")

	phases := c.S("phases", "bootstrap, soak, teardown")
	if *phasesOverride != "" {
		phases = *phasesOverride
	}
	for _, p := range strings.Split(strings.Trim(phases, "[]"), ",") {
		if p = strings.TrimSpace(p); p != "" {
			c.Phases = append(c.Phases, p)
		}
	}

	c.CampName = c.S("campName", fmt.Sprintf("loadtest-%d", time.Now().Unix()))
	return c
}

// ── state persisted between phases ──────────────────────────────────────────

type state struct {
	Base       string   `json:"base"`
	AdminToken string   `json:"adminToken"`
	CampID     string   `json:"campId"`
	RegCode    string   `json:"registrationCode"`
	GroupIDs   []string `json:"groupIds"`
	Tracks     []track  `json:"tracks"`
}

type track struct {
	ID       string `json:"id"`
	CornerID string `json:"cornerId"`
	Token    string `json:"token"`
}

// ── HTTP ────────────────────────────────────────────────────────────────────

// api is the short-timeout client for ordinary requests. SSE uses its own
// no-timeout client (see streamSSE).
var api = &http.Client{Timeout: 15 * time.Second}

type apiError struct {
	status int
	body   string
}

func (e apiError) Error() string { return fmt.Sprintf("http %d: %s", e.status, e.body) }

// call sends a JSON request and unmarshals a 2xx JSON body into out (out may be nil).
// token, when set, goes in Authorization: Bearer unless it looks like a device token
// header is needed — callers pass deviceHdr for that.
func call(ctx context.Context, method, url, token string, body, out any, extra map[string]string) error {
	var rdr io.Reader
	if body != nil {
		b, _ := json.Marshal(body)
		rdr = strings.NewReader(string(b))
	}
	req, err := http.NewRequestWithContext(ctx, method, url, rdr)
	if err != nil {
		return err
	}
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	for k, v := range extra {
		req.Header.Set(k, v)
	}
	resp, err := api.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if resp.StatusCode/100 != 2 {
		return apiError{resp.StatusCode, string(raw)}
	}
	if out != nil {
		return json.Unmarshal(raw, out)
	}
	return nil
}

// ── metrics ─────────────────────────────────────────────────────────────────

type metric struct {
	mu    sync.Mutex
	durs  []time.Duration
	codes map[int]int
	errs  int
}

func (m *metric) observe(d time.Duration, err error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.durs = append(m.durs, d)
	if err != nil {
		m.errs++
		if ae, ok := err.(apiError); ok {
			m.codes[ae.status]++
		} else {
			m.codes[0]++ // transport error
		}
		return
	}
	m.codes[200]++
}

func (m *metric) snapshot() (n int, p50, p95, p99 time.Duration, codes map[int]int, errs int) {
	m.mu.Lock()
	defer m.mu.Unlock()
	d := append([]time.Duration(nil), m.durs...)
	sort.Slice(d, func(i, j int) bool { return d[i] < d[j] })
	pick := func(p float64) time.Duration {
		if len(d) == 0 {
			return 0
		}
		return d[int(float64(len(d)-1)*p)]
	}
	cp := map[int]int{}
	for k, v := range m.codes {
		cp[k] = v
	}
	return len(d), pick(0.50), pick(0.95), pick(0.99), cp, m.errs
}

var (
	metricsMu sync.Mutex
	metrics   = map[string]*metric{}
)

func mget(label string) *metric {
	metricsMu.Lock()
	defer metricsMu.Unlock()
	m := metrics[label]
	if m == nil {
		m = &metric{codes: map[int]int{}}
		metrics[label] = m
	}
	return m
}

// timed runs fn, records its latency + outcome under label.
func timed(label string, fn func() error) error {
	start := time.Now()
	err := fn()
	mget(label).observe(time.Since(start), err)
	return err
}

// SSE connection accounting.
var (
	sseMu          sync.Mutex
	sseConnected   = map[string]int{} // label -> currently open
	sseDisconnects = map[string]int{} // label -> total drops (excluding ctx cancel)
	sseEvents      = map[string]int{} // label -> data: lines seen
)

func sseInc(label string, key map[string]int, d int) {
	sseMu.Lock()
	key[label] += d
	sseMu.Unlock()
}

func printReport(elapsed time.Duration) {
	fmt.Printf("\n─── loadtest report @ %s ───\n", elapsed.Round(time.Second))
	labels := make([]string, 0, len(metrics))
	metricsMu.Lock()
	for l := range metrics {
		labels = append(labels, l)
	}
	metricsMu.Unlock()
	sort.Strings(labels)
	for _, l := range labels {
		n, p50, p95, p99, codes, errs := mget(l).snapshot()
		fmt.Printf("%-16s n=%-5d p50=%-8v p95=%-8v p99=%-8v errs=%-3d codes=%v\n",
			l, n, p50.Round(time.Millisecond), p95.Round(time.Millisecond), p99.Round(time.Millisecond), errs, codes)
	}
	sseMu.Lock()
	defer sseMu.Unlock()
	fmt.Println("SSE:")
	for l := range sseEvents {
		fmt.Printf("  %-16s open=%d disconnects=%d events=%d\n", l, sseConnected[l], sseDisconnects[l], sseEvents[l])
	}
	fmt.Println("(server-side: watch for 'SSE subscriber buffer full' WARN and pgx pool saturation)")
}

// ── bootstrap ───────────────────────────────────────────────────────────────

func bootstrap(ctx context.Context, c config) (state, error) {
	st := state{Base: c.Base}

	var login struct {
		AccessToken string `json:"accessToken"`
	}
	if err := call(ctx, "POST", c.Base+"/auth/admin/login", "",
		map[string]string{"id": c.AdminID, "password": c.AdminPW}, &login, nil); err != nil {
		return st, fmt.Errorf("admin login: %w", err)
	}
	st.AdminToken = login.AccessToken
	adm := func(method, path string, body, out any) error {
		return call(ctx, method, c.Base+path, st.AdminToken, body, out, nil)
	}

	var camp struct {
		ID               string `json:"id"`
		RegistrationCode string `json:"registrationCode"`
	}
	now := time.Now().UTC()
	if err := adm("POST", "/camps", map[string]any{
		"name":    c.CampName,
		"startAt": now.Add(-time.Hour).Format(time.RFC3339),
		"endAt":   now.Add(7 * 24 * time.Hour).Format(time.RFC3339),
	}, &camp); err != nil {
		return st, fmt.Errorf("create camp: %w", err)
	}
	st.CampID, st.RegCode = camp.ID, camp.RegistrationCode
	log.Printf("camp %s (%s) reg=%s", c.CampName, st.CampID, st.RegCode)

	for i := 0; i < c.Corners; i++ {
		var corner struct {
			ID string `json:"id"`
		}
		if err := adm("POST", "/corners", map[string]any{
			"campId": st.CampID, "name": fmt.Sprintf("corner-%02d", i+1), "targetMinutes": 10,
		}, &corner); err != nil {
			return st, fmt.Errorf("create corner %d: %w", i, err)
		}
		var created []struct {
			Track track `json:"track"`
		}
		if err := adm("POST", "/tracks", map[string]any{
			"campId": st.CampID, "cornerId": corner.ID, "count": c.TracksPerCorner,
		}, &created); err != nil {
			return st, fmt.Errorf("create tracks for corner %d: %w", i, err)
		}
		for _, t := range created {
			st.Tracks = append(st.Tracks, track{ID: t.Track.ID, CornerID: corner.ID})
		}
	}
	log.Printf("%d corners, %d tracks", c.Corners, len(st.Tracks))

	if err := adm("POST", "/camps/"+st.CampID+"/start", nil, nil); err != nil {
		return st, fmt.Errorf("start camp: %w", err)
	}

	var badges []struct {
		ID string `json:"id"`
	}
	if err := adm("POST", "/badges/bulk-generate", map[string]any{"count": c.Groups}, &badges); err != nil {
		return st, fmt.Errorf("bulk-generate badges: %w", err)
	}
	for i, b := range badges {
		var grp struct {
			ID string `json:"id"`
		}
		if err := adm("POST", "/badges/"+b.ID+"/register", map[string]any{
			"campId": st.CampID, "groupName": fmt.Sprintf("group-%02d", i+1),
		}, &grp); err != nil {
			return st, fmt.Errorf("register badge %d: %w", i, err)
		}
		st.GroupIDs = append(st.GroupIDs, grp.ID)
	}
	log.Printf("%d groups", len(st.GroupIDs))

	// One approved facilitator device per track, then track login for its PIN.
	for i := range st.Tracks {
		var dev struct {
			ID          string `json:"id"`
			DeviceToken string `json:"deviceToken"`
		}
		if err := call(ctx, "POST", c.Base+"/device-registrations", "", map[string]any{
			"registrationCode": st.RegCode,
			"deviceName":       fmt.Sprintf("%s-dev-%03d", c.CampName, i),
			"deviceModel":      "loadtest",
			"displayName":      fmt.Sprintf("lt-%03d", i),
			"role":             "FACILITATOR",
		}, &dev, nil); err != nil {
			return st, fmt.Errorf("register device %d: %w", i, err)
		}
		if err := adm("POST", "/camps/"+st.CampID+"/device-registrations/"+dev.ID+"/approve", nil, nil); err != nil {
			return st, fmt.Errorf("approve device %d: %w", i, err)
		}
		var tl struct {
			TrackToken string `json:"trackToken"`
			Track      struct {
				ID string `json:"id"`
			} `json:"track"`
		}
		// PIN: /tracks/{id}/export returns {track:{id},pin}. Devices are approved in
		// track order, but PINs aren't ordered — fetch this track's PIN explicitly.
		var exp struct {
			PIN string `json:"pin"`
		}
		if err := adm("GET", "/tracks/"+st.Tracks[i].ID+"/export", nil, &exp); err != nil {
			return st, fmt.Errorf("export track %d: %w", i, err)
		}
		if err := call(ctx, "POST", c.Base+"/auth/track/login", "",
			map[string]string{"pin": exp.PIN}, &tl,
			map[string]string{"X-Device-Token": dev.DeviceToken}); err != nil {
			return st, fmt.Errorf("track login %d: %w", i, err)
		}
		st.Tracks[i].Token = tl.TrackToken
	}
	log.Printf("%d facilitator devices approved + logged in", len(st.Tracks))
	return st, nil
}

// ── soak ────────────────────────────────────────────────────────────────────

// visitPool hands out (group, track-corner) pairs that haven't been used yet.
// A group can visit each corner once; once a corner's groups are exhausted the
// track's visit cycles are skipped (bump -groups if that starts early).
type visitPool struct {
	mu   sync.Mutex
	used map[string]map[string]bool // cornerID -> groupID -> done
	all  []string
}

func newVisitPool(groups []string) *visitPool {
	return &visitPool{used: map[string]map[string]bool{}, all: groups}
}

func (p *visitPool) take(cornerID string) (string, bool) {
	p.mu.Lock()
	defer p.mu.Unlock()
	seen := p.used[cornerID]
	if seen == nil {
		seen = map[string]bool{}
		p.used[cornerID] = seen
	}
	for _, g := range rand.Perm(len(p.all)) {
		if !seen[p.all[g]] {
			seen[p.all[g]] = true
			return p.all[g], true
		}
	}
	return "", false
}

func soak(ctx context.Context, c config, st state) {
	pool := newVisitPool(st.GroupIDs)
	var wg sync.WaitGroup

	for _, t := range st.Tracks {
		t := t
		wg.Add(1)
		go func() {
			defer wg.Done()
			runTrack(ctx, c, st, t, pool)
		}()
	}
	for i := 0; i < c.Admins; i++ {
		sendsBroadcasts := i == 0 // one admin announces; the rest just watch + poll
		wg.Add(1)
		go func() {
			defer wg.Done()
			runAdmin(ctx, c, st, sendsBroadcasts)
		}()
	}

	// Periodic progress report.
	start := time.Now()
	tick := time.NewTicker(30 * time.Second)
	defer tick.Stop()
	go func() {
		for {
			select {
			case <-ctx.Done():
				return
			case <-tick.C:
				printReport(time.Since(start))
			}
		}
	}()

	wg.Wait()
	printReport(time.Since(start))
}

func runTrack(ctx context.Context, c config, st state, t track, pool *visitPool) {
	go streamSSE(ctx, c.Base+"/events/track/"+t.ID, t.Token, "track_sse")

	visitT := time.NewTicker(jitter(c.VisitEvery))
	chatT := time.NewTicker(jitter(c.ChatEvery))
	readT := time.NewTicker(jitter(c.ReadEvery))
	defer visitT.Stop()
	defer chatT.Stop()
	defer readT.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-visitT.C:
			gid, ok := pool.take(t.CornerID)
			if !ok {
				mget("visit_skip").observe(0, nil)
				continue
			}
			err := timed("visit_start", func() error {
				return call(ctx, "POST", c.Base+"/tracks/"+t.ID+"/visits/start", t.Token,
					map[string]string{"groupId": gid, "method": "MANUAL"}, nil, nil)
			})
			if err != nil {
				continue
			}
			// Corner reads BUSY for this long — a hardcoded couple of seconds here
			// made corners look permanently IDLE against any realistic visitEvery,
			// so it's a share of the cycle instead (see visitHoldFrac).
			hold := time.Duration(float64(c.VisitEvery) * c.VisitHoldFrac)
			select {
			case <-time.After(hold):
			case <-ctx.Done():
				return
			}
			timed("visit_end", func() error {
				return call(ctx, "POST", c.Base+"/tracks/"+t.ID+"/visits/current/end", t.Token, nil, nil, nil)
			})
		case <-chatT.C:
			timed("chat_send", func() error {
				return call(ctx, "POST", c.Base+"/tracks/"+t.ID+"/messages", t.Token,
					map[string]string{"content": "loadtest " + time.Now().Format("15:04:05")}, nil, nil)
			})
		case <-readT.C:
			// Facilitator opening the chat screen: lists messages with
			// background=true, which also marks the admin's unread ones read.
			timed("track_read", func() error {
				return call(ctx, "GET", c.Base+"/tracks/"+t.ID+"/messages?background=true", t.Token, nil, nil, nil)
			})
		}
	}
}

func runAdmin(ctx context.Context, c config, st state, sendsBroadcasts bool) {
	go streamSSE(ctx, c.Base+"/camps/"+st.CampID+"/events/admin", st.AdminToken, "admin_sse")

	poll := time.NewTicker(jitter(c.AdminPoll))
	defer poll.Stop()

	// Only one admin sends announcements; a nil channel in the select below
	// just never fires for the rest.
	var broadcastC <-chan time.Time
	if sendsBroadcasts {
		broadcast := time.NewTicker(jitter(c.BroadcastEvery))
		defer broadcast.Stop()
		broadcastC = broadcast.C
	}

	for {
		select {
		case <-ctx.Done():
			return
		case <-poll.C:
			timed("admin_poll", func() error {
				return call(ctx, "GET", c.Base+"/camps/"+st.CampID+"/reports/live-summary", st.AdminToken, nil, nil, nil)
			})
		case <-broadcastC:
			timed("broadcast_send", func() error {
				return call(ctx, "POST", c.Base+"/camps/"+st.CampID+"/messages/broadcast", st.AdminToken,
					map[string]string{"content": "loadtest announcement " + time.Now().Format("15:04:05")}, nil, nil)
			})
		}
	}
}

// streamSSE holds one SSE connection open, counting events and reconnecting on
// drop until ctx is cancelled. A drop that isn't ctx cancellation is what a
// "buffer full, disconnecting" server-side eviction looks like from the client.
func streamSSE(ctx context.Context, url, token, label string) {
	client := &http.Client{} // no timeout: long-lived stream
	for ctx.Err() == nil {
		func() {
			req, _ := http.NewRequestWithContext(ctx, "GET", url, nil)
			req.Header.Set("Authorization", "Bearer "+token)
			req.Header.Set("Accept", "text/event-stream")
			resp, err := client.Do(req)
			if err != nil {
				sseInc(label, sseDisconnects, 1)
				return
			}
			defer resp.Body.Close()
			if resp.StatusCode != 200 {
				sseInc(label, sseDisconnects, 1)
				time.Sleep(time.Second)
				return
			}
			sseInc(label, sseConnected, 1)
			defer sseInc(label, sseConnected, -1)
			sc := bufio.NewScanner(resp.Body)
			sc.Buffer(make([]byte, 64*1024), 1<<20)
			for sc.Scan() {
				if strings.HasPrefix(sc.Text(), "data:") {
					sseInc(label, sseEvents, 1)
				}
			}
			if ctx.Err() == nil {
				sseInc(label, sseDisconnects, 1)
			}
		}()
		if ctx.Err() == nil {
			time.Sleep(time.Second) // reconnect backoff
		}
	}
}

// jitter returns d ±20% so tickers don't align into thundering herds.
func jitter(d time.Duration) time.Duration {
	return d - d/5 + time.Duration(rand.Int63n(int64(2*d/5+1)))
}

// ── teardown ────────────────────────────────────────────────────────────────

func teardown(ctx context.Context, st state) error {
	return call(ctx, "POST", st.Base+"/camps/"+st.CampID+"/end", st.AdminToken, nil, nil, nil)
}

// ── main ────────────────────────────────────────────────────────────────────

func main() {
	log.SetFlags(log.Ltime)
	c := loadConfig()
	if c.AdminPW == "" {
		log.Fatal("adminPassword missing in config")
	}
	phases := map[string]bool{}
	for _, p := range c.Phases {
		phases[strings.TrimSpace(p)] = true
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	defer stop()

	var st state
	if phases["bootstrap"] {
		var err error
		st, err = bootstrap(ctx, c)
		if err != nil {
			log.Fatalf("bootstrap: %v", err)
		}
		b, _ := json.MarshalIndent(st, "", "  ")
		if err := os.WriteFile(c.StateFile, b, 0o644); err != nil {
			log.Fatalf("write state: %v", err)
		}
		log.Printf("bootstrap done, state → %s", c.StateFile)
	} else {
		b, err := os.ReadFile(c.StateFile)
		if err != nil {
			log.Fatalf("read state (%s): %v", c.StateFile, err)
		}
		if err := json.Unmarshal(b, &st); err != nil {
			log.Fatalf("parse state: %v", err)
		}
	}

	if phases["soak"] {
		soakCtx, cancel := context.WithTimeout(ctx, c.Duration)
		defer cancel()
		log.Printf("soak: %d tracks, %d admins, %s", len(st.Tracks), c.Admins, c.Duration)
		soak(soakCtx, c, st)
	}

	if phases["teardown"] {
		if err := teardown(context.Background(), st); err != nil {
			log.Fatalf("teardown: %v", err)
		}
		log.Printf("camp %s ended", st.CampID)
	}
}
