# cornermon_api_gen.model.Track

## Load the model package
```dart
import 'package:cornermon_api_gen/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**cornerId** | **String** |  | 
**trackNo** | **int** | 코너 내 트랙 번호 (자동 부여) | 
**status** | [**TrackStatus**](TrackStatus.md) |  | 
**operationalStatus** | [**TrackOperationalStatus**](TrackOperationalStatus.md) |  | [optional] 
**pin** | **String** | 6자리 숫자 PIN (관리자 전용 응답에만 포함) | [optional] 
**currentVisit** | [**VisitSummary**](VisitSummary.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


