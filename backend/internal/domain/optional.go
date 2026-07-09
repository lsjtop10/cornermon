package domain

// Optional[T]는 값이 명시적으로 지정되었는지 여부를 도메인 계층에서 표현하는 타입입니다.
//
// Go의 포인터(*T)가 "없을 수 있음"을 암묵적 컨벤션으로 표현하는 것과 달리,
// Optional[T]는 "지정되지 않음"이라는 상태를 도메인이 직접 소유합니다.
//
// 생성: Some(v) 또는 None[T]()
// 읽기: Value() — (T, bool) 튜플, IsSet() — bool
//
// Optional[T]는 불변(immutable) 값 타입이므로 별도의 동기화 없이 동시 읽기가 안전합니다.
type Optional[T any] struct {
	value T
	set   bool
}

// Some는 값이 지정된 Optional[T]를 반환합니다.
func Some[T any](v T) Optional[T] {
	return Optional[T]{value: v, set: true}
}

// None은 값이 지정되지 않은 Optional[T]를 반환합니다.
// Optional[T]의 zero value와 동일하게 동작합니다.
func None[T any]() Optional[T] {
	return Optional[T]{}
}

// IsSet은 값이 명시적으로 지정되었는지 반환합니다.
func (o Optional[T]) IsSet() bool {
	return o.set
}

// Value는 값과 지정 여부를 함께 반환합니다.
// 값이 지정되지 않은 경우 T의 zero value와 false를 반환합니다.
func (o Optional[T]) Value() (T, bool) {
	return o.value, o.set
}
