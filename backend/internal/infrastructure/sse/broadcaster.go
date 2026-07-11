package sse

import (
	"context"
	"fmt"
	"strings"
	"sync"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"
)

type BroadcasterImpl struct {
	mu        sync.RWMutex
	adminSubs map[chan string]struct{}
	trackSubs map[string]map[chan string]struct{}
}

func NewBroadcaster() *BroadcasterImpl {
	return &BroadcasterImpl{
		adminSubs: make(map[chan string]struct{}),
		trackSubs: make(map[string]map[chan string]struct{}),
	}
}

func (b *BroadcasterImpl) Broadcast(ctx context.Context, campID domain.CampID, event usecase.NotificationEvent, scope string) error {
	b.mu.RLock()
	defer b.mu.RUnlock()

	msg := fmt.Sprintf("event: %s\ndata: {\"scope\": \"%s\"}", event, scope)

	for ch := range b.adminSubs {
		select {
		case ch <- msg:
		default:
		}
	}

	isBroadcast := scope == "broadcast"
	var targetTrackID string
	if strings.HasPrefix(scope, "track:") {
		targetTrackID = strings.TrimPrefix(scope, "track:")
	}

	for trackID, subs := range b.trackSubs {
		if isBroadcast || scope == "camp" || targetTrackID == trackID {
			for ch := range subs {
				select {
				case ch <- msg:
				default:
				}
			}
		}
	}

	return nil
}

func (b *BroadcasterImpl) SubscribeAdmin(ctx context.Context) (<-chan string, error) {
	ch := make(chan string, 100)
	b.mu.Lock()
	b.adminSubs[ch] = struct{}{}
	b.mu.Unlock()

	go func() {
		<-ctx.Done()
		b.mu.Lock()
		delete(b.adminSubs, ch)
		b.mu.Unlock()
		close(ch)
	}()
	return ch, nil
}

func (b *BroadcasterImpl) SubscribeTrack(ctx context.Context, trackID string) (<-chan string, error) {
	ch := make(chan string, 100)
	b.mu.Lock()
	if b.trackSubs[trackID] == nil {
		b.trackSubs[trackID] = make(map[chan string]struct{})
	}
	b.trackSubs[trackID][ch] = struct{}{}
	b.mu.Unlock()

	go func() {
		<-ctx.Done()
		b.mu.Lock()
		if subs, ok := b.trackSubs[trackID]; ok {
			delete(subs, ch)
			if len(subs) == 0 {
				delete(b.trackSubs, trackID)
			}
		}
		b.mu.Unlock()
		close(ch)
	}()
	return ch, nil
}
