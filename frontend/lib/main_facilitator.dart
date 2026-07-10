import 'package:flutter/material.dart';

void main() {
  runApp(const FacilitatorApp());
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
