# cornermon_api_gen.model.Camp

## Load the model package
```dart
import 'package:cornermon_api_gen/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**name** | **String** |  | 
**startAt** | [**DateTime**](DateTime.md) |  | 
**endAt** | [**DateTime**](DateTime.md) |  | 
**status** | [**CampStatus**](CampStatus.md) |  | 
**bottleneckMinSamples** | **int** | 병목 판정 최소 표본 수 | [optional] [default to 3]
**bottleneckRatioPct** | **int** | 병목 판정 편차 비율 기준 (%) | [optional] [default to 20]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


