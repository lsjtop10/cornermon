import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class FacilitatorApp extends StatelessWidget {
  const FacilitatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Facilitator App Stub'),
        ),
      ),
    );
  }
}
