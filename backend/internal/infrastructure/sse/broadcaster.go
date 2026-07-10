package sse

import (
	"context"
	"log"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"
)

type BroadcasterImpl struct {
	// 실제 구현은 Redis Pub/Sub이나 로컬 채널 등을 활용할 수 있지만,
	// 현재는 임시로 로그만 남기거나 간단한 구조만 갖춥니다.
}

func NewBroadcaster() *BroadcasterImpl {
	return &BroadcasterImpl{}
}

func (b *BroadcasterImpl) Broadcast(ctx context.Context, campID domain.CampID, event usecase.NotificationEvent, scope string) error {
	// TODO: 실제 SSE 채널이나 Redis Pub/Sub으로 이벤트 전송
	log.Printf("[SSE Broadcaster] camp_id: %s, event: %s, scope: %s\n", campID, event, scope)
	
	// 에러 처리가 필요하면 여기서 에러 리턴
	return nil
}

func (b *BroadcasterImpl) SubscribeAdmin(ctx context.Context) (<-chan string, error) {
	ch := make(chan string)
	go func() {
		<-ctx.Done()
		close(ch)
	}()
	return ch, nil
}

func (b *BroadcasterImpl) SubscribeTrack(ctx context.Context, trackID string) (<-chan string, error) {
	ch := make(chan string)
	go func() {
		<-ctx.Done()
		close(ch)
	}()
	return ch, nil
}

