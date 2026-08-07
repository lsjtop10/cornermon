import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/app.dart';
import 'package:cornermon/admin/session/admin_session_token_source.dart';
import 'package:cornermon/shared/auth/session_token_source.dart';
import 'package:cornermon/shared/logging/app_logger.dart';

void main() {
  // 지금까지 캐치 안 된 예외는 어디에도 남지 않았다(#131 UC-3) — 세 소스
  // (Flutter 프레임워크/위젯 빌드, 플랫폼 채널, 그 외 비동기 zone)를 전부 [appLogger]로
  // 연결해 최소한 release 링버퍼에는 남게 한다.
  runZonedGuarded(
    () {
      FlutterError.onError = (details) {
        appLogger.error(
          'flutter',
          details.exceptionAsString(),
          error: details.exception,
          stackTrace: details.stack,
        );
      };
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        appLogger.error('platform', '$error', error: error, stackTrace: stackTrace);
        return true;
      };
      runApp(
        ProviderScope(
          overrides: [
            sessionTokenSourceProvider.overrideWith(
              (ref) => AdminSessionTokenSource(ref),
            ),
          ],
          child: const AdminApp(),
        ),
      );
    },
    (error, stackTrace) =>
        appLogger.error('zone', '$error', error: error, stackTrace: stackTrace),
  );
}
