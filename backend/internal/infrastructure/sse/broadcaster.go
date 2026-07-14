package sse

import (
	"context"
	"sync"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"
)

const subscriberBufferSize = 100

type trackSubscription struct {
	campID domain.CampID
	chans  map[chan usecase.SSEMessage]struct{}
}

type BroadcasterImpl struct {
	mu        sync.RWMutex
	adminSubs map[domain.CampID]map[chan usecase.SSEMessage]struct{}
	trackSubs map[domain.TrackID]*trackSubscription
}

func NewBroadcaster() *BroadcasterImpl {
	return &BroadcasterImpl{
		adminSubs: make(map[domain.CampID]map[chan usecase.SSEMessage]struct{}),
		trackSubs: make(map[domain.TrackID]*trackSubscription),
	}
}

func (b *BroadcasterImpl) Broadcast(_ context.Context, campID domain.CampID, event usecase.NotificationEvent, scope usecase.Scope) error {
	message := usecase.SSEMessage{Event: event, Scope: scope}
	var fullAdminSubs []chan usecase.SSEMessage
	var fullTrackSubs []chan usecase.SSEMessage

	b.mu.RLock()
	for ch := range b.adminSubs[campID] {
		select {
		case ch <- message:
		default:
			fullAdminSubs = append(fullAdminSubs, ch)
		}
	}

	for trackID, subscription := range b.trackSubs {
		if subscription.campID != campID || (scope.Kind == usecase.ScopeTrack && scope.TrackID != trackID) {
			continue
		}
		for ch := range subscription.chans {
			select {
			case ch <- message:
			default:
				fullTrackSubs = append(fullTrackSubs, ch)
			}
		}
	}
	b.mu.RUnlock()

	if len(fullAdminSubs) > 0 || len(fullTrackSubs) > 0 {
		b.removeFullSubscribers(campID, fullAdminSubs, fullTrackSubs)
	}
	return nil
}

func (b *BroadcasterImpl) SubscribeAdmin(ctx context.Context, campID domain.CampID) (<-chan usecase.SSEMessage, error) {
	ch := make(chan usecase.SSEMessage, subscriberBufferSize)
	b.mu.Lock()
	if b.adminSubs[campID] == nil {
		b.adminSubs[campID] = make(map[chan usecase.SSEMessage]struct{})
	}
	b.adminSubs[campID][ch] = struct{}{}
	b.mu.Unlock()

	go func() {
		<-ctx.Done()
		b.removeAdminSubscriber(campID, ch)
	}()
	return ch, nil
}

func (b *BroadcasterImpl) SubscribeTrack(ctx context.Context, campID domain.CampID, trackID domain.TrackID) (<-chan usecase.SSEMessage, error) {
	ch := make(chan usecase.SSEMessage, subscriberBufferSize)
	b.mu.Lock()
	if b.trackSubs[trackID] == nil {
		b.trackSubs[trackID] = &trackSubscription{
			campID: campID,
			chans:  make(map[chan usecase.SSEMessage]struct{}),
		}
	}
	b.trackSubs[trackID].chans[ch] = struct{}{}
	b.mu.Unlock()

	go func() {
		<-ctx.Done()
		b.removeTrackSubscriber(trackID, ch)
	}()
	return ch, nil
}

func (b *BroadcasterImpl) removeFullSubscribers(campID domain.CampID, adminSubs, trackSubs []chan usecase.SSEMessage) {
	b.mu.Lock()
	defer b.mu.Unlock()

	for _, ch := range adminSubs {
		if _, ok := b.adminSubs[campID][ch]; ok {
			delete(b.adminSubs[campID], ch)
			close(ch)
		}
	}
	if len(b.adminSubs[campID]) == 0 {
		delete(b.adminSubs, campID)
	}

	for trackID, subscription := range b.trackSubs {
		for _, ch := range trackSubs {
			if _, ok := subscription.chans[ch]; ok {
				delete(subscription.chans, ch)
				close(ch)
			}
		}
		if len(subscription.chans) == 0 {
			delete(b.trackSubs, trackID)
		}
	}
}

func (b *BroadcasterImpl) removeAdminSubscriber(campID domain.CampID, ch chan usecase.SSEMessage) {
	b.mu.Lock()
	defer b.mu.Unlock()
	if _, ok := b.adminSubs[campID][ch]; !ok {
		return
	}
	delete(b.adminSubs[campID], ch)
	if len(b.adminSubs[campID]) == 0 {
		delete(b.adminSubs, campID)
	}
	close(ch)
}

func (b *BroadcasterImpl) removeTrackSubscriber(trackID domain.TrackID, ch chan usecase.SSEMessage) {
	b.mu.Lock()
	defer b.mu.Unlock()
	subscription, ok := b.trackSubs[trackID]
	if !ok {
		return
	}
	if _, ok := subscription.chans[ch]; !ok {
		return
	}
	delete(subscription.chans, ch)
	if len(subscription.chans) == 0 {
		delete(b.trackSubs, trackID)
	}
	close(ch)
}
