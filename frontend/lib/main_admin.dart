import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/app.dart';
import 'package:cornermon/admin/session/admin_session_token_source.dart';
import 'package:cornermon/shared/auth/session_token_source.dart';

void main() {
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
}
