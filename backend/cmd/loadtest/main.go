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
	"strings"
	"sync"
	"time"

	"gopkg.in/yaml.v3"
)

// ── config ──────────────────────────────────────────────────────────────────

// Dur is a time.Duration that unmarshals from a YAML string like "3m" / "20s".
type Dur time.Duration

func (d Dur) D() time.Duration { return time.Duration(d) }

func (d *Dur) UnmarshalYAML(n *yaml.Node) error {
	v, err := time.ParseDuration(n.Value)
	if err != nil {
		return err
	}
	*d = Dur(v)
	return nil
}

type config struct {
	Base            string   `yaml:"base"`
	AdminID         string   `yaml:"adminId"`
	AdminPW         string   `yaml:"adminPassword"`
	Corners         int      `yaml:"corners"`
	TracksPerCorner int      `yaml:"tracksPerCorner"`
	Groups          int      `yaml:"groups"`
	Admins          int      `yaml:"admins"`
	VisitEvery      Dur      `yaml:"visitEvery"`
	VisitHoldFrac   float64  `yaml:"visitHoldFrac"` // fraction of VisitEvery a visit stays IN_PROGRESS (corner reads BUSY)
	ChatEvery       Dur      `yaml:"chatEvery"`
	ReadEvery       Dur      `yaml:"readEvery"` // per-track: how often a facilitator checks/reads messages
	AdminPoll       Dur      `yaml:"adminPoll"`
	BroadcastEvery  Dur      `yaml:"broadcastEvery"` // admin: how often to send a camp-wide announcement
	Duration        Dur      `yaml:"duration"`
	CampName        string   `yaml:"campName"`
	StateFile       string   `yaml:"stateFile"`
	Phases          []string `yaml:"phases"`
}

// loadConfig reads the YAML config (path from -config) on top of built-in
// defaults, so the file only needs to set what differs. -phases overrides the
// file's phase list for one-off runs.
func loadConfig() config {
	path := flag.String("config", "loadtest.yaml", "path to YAML config")
	phasesOverride := flag.String("phases", "", "comma list overriding config phases (bootstrap,soak,teardown)")
	flag.Parse()

	c := config{
		Base:            "http://localhost:8080/api/v1",
		AdminID:         "admin",
		StateFile:       "loadtest-state.json",
		Corners:         10,
		TracksPerCorner: 1,
		Groups:          25,
		Admins:          3,
		VisitEvery:      Dur(3 * time.Minute),
		VisitHoldFrac:   0.8,
		ChatEvery:       Dur(20 * time.Second),
		ReadEvery:       Dur(45 * time.Second),
		AdminPoll:       Dur(5 * time.Second),
		BroadcastEvery:  Dur(5 * time.Minute),
		Duration:        Dur(30 * time.Minute),
		Phases:          []string{"bootstrap", "soak", "teardown"},
	}
	b, err := os.ReadFile(*path)
	if err != nil {
		log.Fatalf("read config %s: %v", *path, err)
	}
	if err := yaml.Unmarshal(b, &c); err != nil {
		log.Fatalf("parse config %s: %v", *path, err)
	}
	if *phasesOverride != "" {
		c.Phases = strings.Split(*phasesOverride, ",")
	}
	if c.CampName == "" {
		c.CampName = fmt.Sprintf("loadtest-%d", time.Now().Unix())
	}
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

// adminCall is an already-authenticated request against c.Base as the admin.
type adminCall func(method, path string, body, out any) error

func adminLogin(ctx context.Context, c config) (string, error) {
	var login struct {
		AccessToken string `json:"accessToken"`
	}
	if err := call(ctx, "POST", c.Base+"/auth/admin/login", "",
		map[string]string{"id": c.AdminID, "password": c.AdminPW}, &login, nil); err != nil {
		return "", fmt.Errorf("admin login: %w", err)
	}
	return login.AccessToken, nil
}

func adminCaller(ctx context.Context, c config, token string) adminCall {
	return func(method, path string, body, out any) error {
		return call(ctx, method, c.Base+path, token, body, out, nil)
	}
}

func createCamp(adm adminCall, name string) (id, regCode string, err error) {
	var camp struct {
		ID               string `json:"id"`
		RegistrationCode string `json:"registrationCode"`
	}
	now := time.Now().UTC()
	if err := adm("POST", "/camps", map[string]any{
		"name":    name,
		"startAt": now.Add(-time.Hour).Format(time.RFC3339),
		"endAt":   now.Add(7 * 24 * time.Hour).Format(time.RFC3339),
	}, &camp); err != nil {
		return "", "", fmt.Errorf("create camp: %w", err)
	}
	return camp.ID, camp.RegistrationCode, nil
}

// createCornersAndTracks creates `corners` corners, each with `tracksPerCorner`
// tracks, and returns every created track (without a facilitator token yet).
func createCornersAndTracks(adm adminCall, campID string, corners, tracksPerCorner int) ([]track, error) {
	var tracks []track
	for i := 0; i < corners; i++ {
		var corner struct {
			ID string `json:"id"`
		}
		if err := adm("POST", "/corners", map[string]any{
			"campId": campID, "name": fmt.Sprintf("corner-%02d", i+1), "targetMinutes": 10,
		}, &corner); err != nil {
			return nil, fmt.Errorf("create corner %d: %w", i, err)
		}
		var created []struct {
			Track track `json:"track"`
		}
		if err := adm("POST", "/tracks", map[string]any{
			"campId": campID, "cornerId": corner.ID, "count": tracksPerCorner,
		}, &created); err != nil {
			return nil, fmt.Errorf("create tracks for corner %d: %w", i, err)
		}
		for _, t := range created {
			tracks = append(tracks, track{ID: t.Track.ID, CornerID: corner.ID})
		}
	}
	return tracks, nil
}

// createGroups issues `n` badges and registers each into its own group,
// returning the group IDs (visit capacity: one visit per group per corner).
func createGroups(adm adminCall, campID string, n int) ([]string, error) {
	var badges []struct {
		ID string `json:"id"`
	}
	if err := adm("POST", "/badges/bulk-generate", map[string]any{"count": n}, &badges); err != nil {
		return nil, fmt.Errorf("bulk-generate badges: %w", err)
	}
	groupIDs := make([]string, 0, len(badges))
	for i, b := range badges {
		var grp struct {
			ID string `json:"id"`
		}
		if err := adm("POST", "/badges/"+b.ID+"/register", map[string]any{
			"campId": campID, "groupName": fmt.Sprintf("group-%02d", i+1),
		}, &grp); err != nil {
			return nil, fmt.Errorf("register badge %d: %w", i, err)
		}
		groupIDs = append(groupIDs, grp.ID)
	}
	return groupIDs, nil
}

// provisionFacilitator registers, approves, and logs in one device for track
// #i, returning the resulting track session token.
func provisionFacilitator(ctx context.Context, c config, adm adminCall, campID, regCode string, t track, i int) (string, error) {
	var dev struct {
		ID          string `json:"id"`
		DeviceToken string `json:"deviceToken"`
	}
	if err := call(ctx, "POST", c.Base+"/device-registrations", "", map[string]any{
		"registrationCode": regCode,
		"deviceName":       fmt.Sprintf("%s-dev-%03d", c.CampName, i),
		"deviceModel":      "loadtest",
		"displayName":      fmt.Sprintf("lt-%03d", i),
		"role":             "FACILITATOR",
	}, &dev, nil); err != nil {
		return "", fmt.Errorf("register device %d: %w", i, err)
	}
	if err := adm("POST", "/camps/"+campID+"/device-registrations/"+dev.ID+"/approve", nil, nil); err != nil {
		return "", fmt.Errorf("approve device %d: %w", i, err)
	}
	// PIN: /tracks/{id}/export returns {track:{id},pin}. Devices are approved in
	// track order, but PINs aren't ordered — fetch this track's PIN explicitly.
	var exp struct {
		PIN string `json:"pin"`
	}
	if err := adm("GET", "/tracks/"+t.ID+"/export", nil, &exp); err != nil {
		return "", fmt.Errorf("export track %d: %w", i, err)
	}
	var tl struct {
		TrackToken string `json:"trackToken"`
	}
	if err := call(ctx, "POST", c.Base+"/auth/track/login", "",
		map[string]string{"pin": exp.PIN}, &tl,
		map[string]string{"X-Device-Token": dev.DeviceToken}); err != nil {
		return "", fmt.Errorf("track login %d: %w", i, err)
	}
	return tl.TrackToken, nil
}

func bootstrap(ctx context.Context, c config) (state, error) {
	st := state{Base: c.Base}

	token, err := adminLogin(ctx, c)
	if err != nil {
		return st, err
	}
	st.AdminToken = token
	adm := adminCaller(ctx, c, token)

	st.CampID, st.RegCode, err = createCamp(adm, c.CampName)
	if err != nil {
		return st, err
	}
	log.Printf("camp %s (%s) reg=%s", c.CampName, st.CampID, st.RegCode)

	st.Tracks, err = createCornersAndTracks(adm, st.CampID, c.Corners, c.TracksPerCorner)
	if err != nil {
		return st, err
	}
	log.Printf("%d corners, %d tracks", c.Corners, len(st.Tracks))

	if err := adm("POST", "/camps/"+st.CampID+"/start", nil, nil); err != nil {
		return st, fmt.Errorf("start camp: %w", err)
	}

	st.GroupIDs, err = createGroups(adm, st.CampID, c.Groups)
	if err != nil {
		return st, err
	}
	log.Printf("%d groups", len(st.GroupIDs))

	for i := range st.Tracks {
		token, err := provisionFacilitator(ctx, c, adm, st.CampID, st.RegCode, st.Tracks[i], i)
		if err != nil {
			return st, err
		}
		st.Tracks[i].Token = token
	}
	log.Printf("%d facilitator devices approved + logged in", len(st.Tracks))
	return st, nil
}

// ── soak ────────────────────────────────────────────────────────────────────

// visitPool hands out (group, track-corner) pairs that haven't been used yet.
// A group can visit each corner once; once a corner's groups are exhausted the
// track's visit cycles are skipped (bump -groups if that starts early).
//
// A group also can't be at two corners at once — the server correctly rejects
// that as ITINERARY_CONFLICT — so `busy` locks a group from take() until the
// caller release()s it, covering the whole start→hold→end window.
type visitPool struct {
	mu   sync.Mutex
	used map[string]map[string]bool // cornerID -> groupID -> done
	busy map[string]bool            // groupID -> currently held by some track
	all  []string
}

func newVisitPool(groups []string) *visitPool {
	return &visitPool{used: map[string]map[string]bool{}, busy: map[string]bool{}, all: groups}
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
		gid := p.all[g]
		if !seen[gid] && !p.busy[gid] {
			seen[gid] = true
			p.busy[gid] = true
			return gid, true
		}
	}
	return "", false
}

// release frees a group taken via take(), once its visit has ended (or failed
// to start at all).
func (p *visitPool) release(groupID string) {
	p.mu.Lock()
	delete(p.busy, groupID)
	p.mu.Unlock()
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

	visitT := time.NewTicker(jitter(c.VisitEvery.D()))
	chatT := time.NewTicker(jitter(c.ChatEvery.D()))
	readT := time.NewTicker(jitter(c.ReadEvery.D()))
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
				pool.release(gid) // never actually started; free it back up
				continue
			}
			// Corner reads BUSY for this long — a hardcoded couple of seconds here
			// made corners look permanently IDLE against any realistic visitEvery,
			// so it's a share of the cycle instead (see visitHoldFrac).
			hold := time.Duration(float64(c.VisitEvery.D()) * c.VisitHoldFrac)
			select {
			case <-time.After(hold):
			case <-ctx.Done():
				pool.release(gid)
				return
			}
			timed("visit_end", func() error {
				return call(ctx, "POST", c.Base+"/tracks/"+t.ID+"/visits/current/end", t.Token, nil, nil, nil)
			})
			pool.release(gid)
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

	poll := time.NewTicker(jitter(c.AdminPoll.D()))
	defer poll.Stop()

	// Only one admin sends announcements; a nil channel in the select below
	// just never fires for the rest.
	var broadcastC <-chan time.Time
	if sendsBroadcasts {
		broadcast := time.NewTicker(jitter(c.BroadcastEvery.D()))
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
		soakCtx, cancel := context.WithTimeout(ctx, c.Duration.D())
		defer cancel()
		log.Printf("soak: %d tracks, %d admins, %s", len(st.Tracks), c.Admins, c.Duration.D())
		soak(soakCtx, c, st)
	}

	if phases["teardown"] {
		if err := teardown(context.Background(), st); err != nil {
			log.Fatalf("teardown: %v", err)
		}
		log.Printf("camp %s ended", st.CampID)
	}
}
