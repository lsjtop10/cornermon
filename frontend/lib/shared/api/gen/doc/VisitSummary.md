# cornermon_api_gen.model.VisitSummary

## Load the model package
```dart
import 'package:cornermon_api_gen/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**groupId** | **String** |  | 
**cornerId** | **String** |  | 
**trackId** | **String** |  | 
**status** | [**VisitStatus**](VisitStatus.md) |  | 
**inputMethod** | [**VisitInputMethod**](VisitInputMethod.md) |  | [optional] 
**startedAt** | [**DateTime**](DateTime.md) |  | 
**endedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**durationSeconds** | **int** | 실제 소요 시간 (초) | [optional] 
**deviationSeconds** | **int** | 목표시간 편차 = 실제소요시간 - 목표시간 (초) | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


