# cornermon_api_gen.api.HealthApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**healthGet**](HealthApi.md#healthget) | **GET** /health | 헬스체크
[**readyGet**](HealthApi.md#readyget) | **GET** /ready | 레디니스 체크


# **healthGet**
> HealthResponse healthGet()

헬스체크

서버가 정상적으로 응답하는지 확인한다. 인증이 필요하지 않다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getHealthApi();

try {
    final response = api.healthGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling HealthApi->healthGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**HealthResponse**](HealthResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readyGet**
> HealthResponse readyGet()

레디니스 체크

서버가 데이터베이스 등 필수 의존성에 연결되어 트래픽을 받을 준비가 되었는지 확인한다. 인증이 필요하지 않다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getHealthApi();

try {
    final response = api.readyGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling HealthApi->readyGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**HealthResponse**](HealthResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

