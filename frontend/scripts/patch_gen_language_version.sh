#!/usr/bin/env bash
# openapi-generator-cli(dart-dio) + built_value 조합으로 lib/shared/api/gen을 생성/재생성한 뒤 매번 실행할 것.
#
# 배경: cornermon_api_gen을 frontend(cornermon)의 path dependency로 소비할 때, 명시적
# `// @dart=` 언어 버전 pragma가 없는 라이브러리(.dart)와 그 part(.g.dart)가 서로 다른
# 암묵적 언어 버전으로 해석되어 `dart run`/`flutter test` 컴파일이
# "The language version override has to be the same in the library and its part(s)" 로 실패한다
# (frontend 패키지 자체 안에서 standalone으로 실행할 땐 재현되지 않고, path dependency로
# 소비될 때만 재현됨 — Dart/CFE의 알려지지 않은 언어버전 해석 차이로 추정, 근본 원인 미상).
# 모든 라이브러리/part 파일에 gen 패키지의 pubspec.yaml environment.sdk 하한(2.18)과 동일한
# 명시적 pragma를 박아 이 모호성을 없앤다.
set -euo pipefail

GEN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib/shared/api/gen" && pwd)"
LANG_VERSION="2.18"

patched=0
while IFS= read -r -d '' f; do
  if ! head -1 "$f" | grep -q "^// @dart="; then
    printf '// @dart=%s\n%s\n' "$LANG_VERSION" "$(cat "$f")" > "$f.tmp"
    mv "$f.tmp" "$f"
    patched=$((patched + 1))
  fi
done < <(find "$GEN_DIR/lib" -name "*.dart" -print0)

echo "patched $patched file(s) under $GEN_DIR/lib"
