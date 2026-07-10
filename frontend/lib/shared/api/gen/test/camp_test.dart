import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

// tests for Camp
void main() {
  final instance = CampBuilder();
  // TODO add properties to the builder and call build()

  group(Camp, () {
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // DateTime startAt
    test('to test the property `startAt`', () async {
      // TODO
    });

    // DateTime endAt
    test('to test the property `endAt`', () async {
      // TODO
    });

    // CampStatus status
    test('to test the property `status`', () async {
      // TODO
    });

    // 병목 판정 최소 표본 수
    // int bottleneckMinSamples (default value: 3)
    test('to test the property `bottleneckMinSamples`', () async {
      // TODO
    });

    // 병목 판정 편차 비율 기준 (%)
    // int bottleneckRatioPct (default value: 20)
    test('to test the property `bottleneckRatioPct`', () async {
      // TODO
    });

  });
}
