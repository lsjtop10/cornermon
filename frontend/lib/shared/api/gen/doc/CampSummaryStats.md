# cornermon_api_gen.model.CampSummaryStats

## Load the model package
```dart
import 'package:cornermon_api_gen/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**totalGroups** | **int** |  | [optional] 
**finishedGroupCount** | **int** |  | [optional] 
**completionRate** | **double** | 완주율 (0.0 ~ 1.0) | [optional] 
**totalVisits** | **int** |  | [optional] 
**visitCompletionRate** | **double** | 방문 완료율 (완료 방문 수 / 이론상 최대 200) | [optional] 
**programDurationSeconds** | **int** |  | [optional] 
**avgDeviationSeconds** | **double** |  | [optional] 
**manualVisitRatio** | **double** |  | [optional] 
**ruleOverrideCount** | **int** |  | [optional] 
**trackOperationCount** | **int** |  | [optional] 
**exceptionApprovalCount** | **int** |  | [optional] 
**bottleneckRanking** | [**BuiltList&lt;CampSummaryStatsBottleneckRankingInner&gt;**](CampSummaryStatsBottleneckRankingInner.md) | 코너를 평균편차 기준 내림차순 정렬한 병목 랭킹 | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


