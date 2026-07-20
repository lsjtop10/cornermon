KEY_PASS ?= 
UNAME_S := $(shell uname -s)

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