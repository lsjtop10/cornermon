KEY_PASS ?= 
FLUTTER_ANDROID_BASE_IMAGE ?= ghcr.io/cirruslabs/android-sdk:36
FLUTTER_VERSION ?= 3.44.7
FLUTTER_DOCKER_IMAGE ?= cornermon-flutter:3.44.7
FLUTTER_DOCKERFILE ?= Dockerfile.flutter
FLUTTER_DOCKER_CONTAINER ?= cornermon-flutter-check
FLUTTER_PUB_CACHE_VOLUME ?= cornermon-flutter-pub-cache
UNAME_S := $(shell uname -s)

.PHONY: unlock-keychain run-admin run-facilitator docker-build docker-check

unlock-keychain:
ifeq ($(UNAME_S),Darwin)
ifneq ($(KEY_PASS),)
# KEY_PASS 값이 비어있지 않은 경우 (줄 맨 앞 Tab 필수)
	@echo "macOS 환경: 전달된 비밀번호로 키체인을 해제합니다."
	@security unlock-keychain -p '$(KEY_PASS)' login.keychain
	@security set-keychain-settings -t 3600 login.keychain
else
# KEY_PASS 값이 비어있는 경우 (줄 맨 앞 Tab 필수)
	@echo "경고: KEY_PASS 인자가 없어 대화형 입력을 시도합니다."
	@security unlock-keychain login.keychain
endif
endif

run-admin:unlock-keychain
	flutter run --dart-define-from-file=env/dev.json -t lib/main_admin.dart --flavor admin

run-facilitator:unlock-keychain
	flutter run --dart-define-from-file=env/dev.json -t lib/main_facilitator.dart --flavor facilitator

run-admin-prod:unlock-keychain
	flutter run --release --dart-define-from-file=env/prod.json -t lib/main_admin.dart --flavor admin

run-facilitator-prod:unlock-keychain
	flutter run --release --dart-define-from-file=env/prod.json -t lib/main_facilitator.dart --flavor facilitator


# pubspec.yaml의 Dart SDK 하한을 만족하는 Flutter/Dart 도구 이미지를 만든다.
# 빌드 컨텍스트에는 Dockerfile만 전달하므로 앱 소스는 이미지에 포함하지 않는다.
docker-build:
	docker build --tag '$(FLUTTER_DOCKER_IMAGE)' \
		--build-arg 'ANDROID_SDK_IMAGE=$(FLUTTER_ANDROID_BASE_IMAGE)' \
		--build-arg 'FLUTTER_VERSION=$(FLUTTER_VERSION)' \
		- < '$(FLUTTER_DOCKERFILE)'

# Host bind mount 없이 소스를 일회성 컨테이너에 복사해 검증한다.
# 패키지 다운로드 캐시만 Docker named volume에 보존한다.
docker-check:
	@set -eu; \
		container='$(FLUTTER_DOCKER_CONTAINER)'; \
		if docker container inspect "$$container" >/dev/null 2>&1; then \
			echo "error: container '$$container' already exists; remove it or set FLUTTER_DOCKER_CONTAINER" >&2; \
			exit 1; \
		fi; \
		cleanup() { docker rm -f "$$container" >/dev/null 2>&1 || true; }; \
		trap cleanup 0 1 2 15; \
		docker create --name "$$container" --workdir /app \
			-v '$(FLUTTER_PUB_CACHE_VOLUME):/root/.pub-cache' \
			--entrypoint sh '$(FLUTTER_DOCKER_IMAGE)' \
			-lc 'flutter pub get && flutter analyze && flutter test' >/dev/null; \
		tar --exclude='./.dart_tool' --exclude='./build' --exclude='./.git' -cf - . \
			| docker cp - "$$container:/app"; \
		docker start -a "$$container"
