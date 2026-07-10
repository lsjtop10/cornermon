.PHONY: gen dev-admin dev-facilitator

gen:
	cd frontend && npx @openapitools/openapi-generator-cli generate
	cd frontend/lib/shared/api/gen && flutter pub get && dart run build_runner build --delete-conflicting-outputs
	cd frontend && flutter pub get && dart run build_runner build --delete-conflicting-outputs
	# (백엔드 oapi-codegen 호출은 backend 트랙 Plan에서 이 타겟에 이어붙임)

dev-admin:
	cd frontend && flutter run -t lib/main_admin.dart --flavor admin

dev-facilitator:
	cd frontend && flutter run -t lib/main_facilitator.dart --flavor facilitator
