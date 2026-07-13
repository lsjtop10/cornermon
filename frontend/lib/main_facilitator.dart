import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'facilitator/app.dart';
import 'facilitator/session/track_session_token_source.dart';
import 'shared/auth/session_token_source.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        sessionTokenSourceProvider.overrideWith((ref) => TrackSessionTokenSource(ref)),
      ],
      child: const FacilitatorApp(),
    ),
  );
}
