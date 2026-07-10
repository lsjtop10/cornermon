.PHONY: gen dev-admin dev-facilitator

gen:
	cd frontend && npx @openapitools/openapi-generator-cli generate
	# dart-dio 제너레이터가 매번 sdk 하한을 2.18.0으로 되돌려 쓴다 — 외곽 frontend 패키지(3.12대)와
	# 언어버전이 갈리면 flutter analyze는 통과하지만 flutter build의 CFE가 part 파일 언어버전 불일치로
	# 크래시한다(모든 모델에서 "language version override has to be the same in the library and its
	# part(s)"). 매 gen마다 3.12.0으로 맞춰준다.
	sed -i '' "s/sdk: '>=2.18.0 <4.0.0'/sdk: '>=3.12.0 <4.0.0'/" frontend/lib/shared/api/gen/pubspec.yaml
	# frontend/의 build_runner가 cornermon_api_gen을 path dependency로 물고 들어가면서 gen/ 쪽
	# .g.dart를 자기 소유로 착각해 지워버린다 — 반드시 gen을 나중에, 마지막에 다시 생성한다.
	# 매번 .dart_tool/build 캐시를 지우고 시작한다 — incremental 빌드 캐시가 이전 실행에서
	# cornermon_api_gen 산출물을 "이 빌드가 소유한 파일"로 잘못 기억하면 InvalidOutputException으로 죽는다.
	cd frontend && flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs
	cd frontend/lib/shared/api/gen && rm -rf .dart_tool && flutter pub get && dart run build_runner build --delete-conflicting-outputs

dev-admin:
	cd frontend && flutter run -t lib/main_admin.dart --flavor admin

dev-facilitator:
	cd frontend && flutter run -t lib/main_facilitator.dart --flavor facilitator
