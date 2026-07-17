import 'package:dio/dio.dart';

const _cornerStatusValues = {'INACTIVE', 'IDLE', 'BUSY'};
const _trackStatusValues = {'ACTIVE', 'DELETED'};
const _trackOperationalStatusValues = {'IDLE', 'BUSY'};

/// 백엔드가 status를 채우지 않고 내려줄 경우(예: 빈 문자열) built_value enum 파싱이
/// 던지는 ArgumentError가 응답 전체(리스트 포함) 디코딩을 깨뜨리는 것을 막는다.
/// 근본 원인은 백엔드 이슈로 별도 트래킹 — 여기서는 알 수 없는 값을 안전한 기본값으로
/// 대체해 화면이 죽지 않도록만 방어한다.
class StatusFallbackInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _sanitize(response.data);
    handler.next(response);
  }

  void _sanitize(dynamic node) {
    if (node is List) {
      for (final item in node) {
        _sanitize(item);
      }
      return;
    }
    if (node is! Map) return;

    if (node.containsKey('targetMinutes') && !_cornerStatusValues.contains(node['status'])) {
      node['status'] = 'INACTIVE';
    }
    if (node.containsKey('trackNo')) {
      if (!_trackStatusValues.contains(node['status'])) {
        node['status'] = 'ACTIVE';
      }
      if (!_trackOperationalStatusValues.contains(node['operationalStatus'])) {
        node['operationalStatus'] = 'IDLE';
      }
    }

    for (final value in node.values) {
      _sanitize(value);
    }
  }
}
