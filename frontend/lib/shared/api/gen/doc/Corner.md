# cornermon_api_gen.model.Corner

## Load the model package
```dart
import 'package:cornermon_api_gen/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**name** | **String** |  | 
**targetMinutes** | **int** | 목표 소요 시간 (분) | [default to 10]
**status** | [**CornerOperationalStatus**](CornerOperationalStatus.md) |  | 
**isBottleneck** | **bool** | 병목 판정 여부 (실시간 집계 기반) | [optional] 
**activeTracks** | [**BuiltList&lt;TrackSummary&gt;**](TrackSummary.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


