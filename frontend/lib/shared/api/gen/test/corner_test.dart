import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

// tests for Corner
void main() {
  final instance = CornerBuilder();
  // TODO add properties to the builder and call build()

  group(Corner, () {
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // 목표 소요 시간 (분)
    // int targetMinutes (default value: 10)
    test('to test the property `targetMinutes`', () async {
      // TODO
    });

    // CornerOperationalStatus status
    test('to test the property `status`', () async {
      // TODO
    });

    // 병목 판정 여부 (실시간 집계 기반)
    // bool isBottleneck
    test('to test the property `isBottleneck`', () async {
      // TODO
    });

    // BuiltList<TrackSummary> activeTracks
    test('to test the property `activeTracks`', () async {
      // TODO
    });

  });
}
