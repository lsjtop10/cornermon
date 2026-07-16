// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart';
import 'package:cornermon_api_gen/src/serializers.dart';
import 'package:cornermon_api_gen/src/auth/api_key_auth.dart';
import 'package:cornermon_api_gen/src/auth/basic_auth.dart';
import 'package:cornermon_api_gen/src/auth/bearer_auth.dart';
import 'package:cornermon_api_gen/src/auth/oauth.dart';
import 'package:cornermon_api_gen/src/api/a_auth_device_trust_api.dart';
import 'package:cornermon_api_gen/src/api/b_camp_corner_track_api.dart';
import 'package:cornermon_api_gen/src/api/b_resource_management_admin_api.dart';
import 'package:cornermon_api_gen/src/api/c_visit_scan_flow_api.dart';
import 'package:cornermon_api_gen/src/api/d_report_api.dart';
import 'package:cornermon_api_gen/src/api/e_message_api.dart';
import 'package:cornermon_api_gen/src/api/f_events_sse_api.dart';
import 'package:cornermon_api_gen/src/api/g_audit_logs_api.dart';
import 'package:cornermon_api_gen/src/api/health_api.dart';

class CornermonApiGen {
  static const String basePath = r'/api/v1';

  final Dio dio;
  final Serializers serializers;

  CornermonApiGen({
    Dio? dio,
    Serializers? serializers,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : this.serializers = serializers ?? standardSerializers,
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the OAuth token associated with the given [name].
  ///
  /// If no [OAuthInterceptor] is registered or no token exists for the given
  /// [name], this method has no effect.
  void removeOAuthToken(String name) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens.remove(name);
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the bearer authentication token associated with the given [name].
  ///
  /// If no [BearerAuthInterceptor] is registered or no token exists for the
  /// given [name], this method has no effect.
  void removeBearerAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens.remove(name);
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  /// Removes the basic authentication credentials associated with the given [name].
  ///
  /// If no [BasicAuthInterceptor] is registered or no credentials exist for the
  /// given [name], this method has no effect.
  void removeBasicAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo.remove(name);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Removes the API key associated with the given [name].
  ///
  /// If no [ApiKeyAuthInterceptor] is registered or no API key exists for the
  /// given [name], this method has no effect.
  void removeApiKey(String name) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys.remove(name);
    }
  }

  /// Get AAuthDeviceTrustApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AAuthDeviceTrustApi getAAuthDeviceTrustApi() {
    return AAuthDeviceTrustApi(dio, serializers);
  }

  /// Get BCampCornerTrackApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  BCampCornerTrackApi getBCampCornerTrackApi() {
    return BCampCornerTrackApi(dio, serializers);
  }

  /// Get BResourceManagementAdminApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  BResourceManagementAdminApi getBResourceManagementAdminApi() {
    return BResourceManagementAdminApi(dio, serializers);
  }

  /// Get CVisitScanFlowApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CVisitScanFlowApi getCVisitScanFlowApi() {
    return CVisitScanFlowApi(dio, serializers);
  }

  /// Get DReportApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DReportApi getDReportApi() {
    return DReportApi(dio, serializers);
  }

  /// Get EMessageApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  EMessageApi getEMessageApi() {
    return EMessageApi(dio, serializers);
  }

  /// Get FEventsSSEApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  FEventsSSEApi getFEventsSSEApi() {
    return FEventsSSEApi(dio, serializers);
  }

  /// Get GAuditLogsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  GAuditLogsApi getGAuditLogsApi() {
    return GAuditLogsApi(dio, serializers);
  }

  /// Get HealthApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  HealthApi getHealthApi() {
    return HealthApi(dio, serializers);
  }
}
