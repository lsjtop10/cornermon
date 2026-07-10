import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';

part 'auth_device_trust_providers.g.dart';

@riverpod
AAuthDeviceTrustApi authDeviceTrustApi(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return AAuthDeviceTrustApi(dio, serializers);
}
