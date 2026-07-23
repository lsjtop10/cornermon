package usecase

import (
	"context"
	"fmt"

	"cornermon/backend/internal/domain"
)

// adminActorLabel은 감사 로그 actor_name에 기록할 관리자 표시 이름(username)을 해석한다.
// preloaded가 주어지면(호출부가 이미 Admin 엔티티를 로드해 둔 경우) 그 값을 그대로 쓰고
// 리포지토리를 다시 조회하지 않는다 — 감사 로그는 핫패스에서 매번 기록되므로 이미 메모리에
// 있는 엔티티를 두고 강제로 재조회하면 불필요한 DB 부하로 이어진다.
func adminActorLabel(ctx context.Context, admins AdminRepository, adminID domain.AdminID, preloaded *domain.Admin) string {
	if preloaded != nil {
		return preloaded.Username()
	}
	admin, err := admins.Get(ctx, adminID)
	if err != nil || admin == nil {
		return string(adminID)
	}
	return admin.Username()
}

// trackDisplayLabel은 관리자 화면의 기존 트랙 표시 관례("{코너명} · {트랙번호}번 트랙",
// track_direct/_track_list_pane.dart)와 동일한 포맷으로 트랙을 문자열화한다. 진행자는
// 개인 식별자가 없으므로 "어느 트랙"이 곧 행위자 표시 이름이다. preloadedTrack도
// adminActorLabel과 동일한 이유로 재조회를 피하기 위해 지원한다.
func trackDisplayLabel(ctx context.Context, tracks TrackRepository, corners CornerRepository, trackID domain.TrackID, preloadedTrack *domain.Track) string {
	track := preloadedTrack
	if track == nil {
		var err error
		track, err = tracks.Get(ctx, trackID)
		if err != nil || track == nil {
			return string(trackID)
		}
	}
	corner, err := corners.Get(ctx, track.CornerID())
	if err != nil || corner == nil {
		return string(trackID)
	}
	return fmt.Sprintf("%s · %d번 트랙", corner.Name(), track.TrackNo())
}
