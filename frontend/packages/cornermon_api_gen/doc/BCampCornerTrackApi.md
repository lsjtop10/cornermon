# cornermon_api_gen.api.BCampCornerTrackApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**tracksIdMigrateSessionPost**](BCampCornerTrackApi.md#tracksidmigratesessionpost) | **POST** /tracks/{id}/migrate-session | 교체된 트랙의 세션 마이그레이션


# **tracksIdMigrateSessionPost**
> TrackLoginResponse tracksIdMigrateSessionPost(id)

교체된 트랙의 세션 마이그레이션

트랙이 교체되어 `track_replaced` 알림을 받은 기기가 호출한다. 기존 세션 토큰을 Authorization 헤더에 담아 새 세션을 발급받는다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: TrackAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String id = id_example; // String | 기존 트랙 ID

try {
    final response = api.tracksIdMigrateSessionPost(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->tracksIdMigrateSessionPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 기존 트랙 ID | 

### Return type

[**TrackLoginResponse**](TrackLoginResponse.md)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

