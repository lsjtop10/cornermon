# cornermon_api_gen.model.AuditLog

## Load the model package
```dart
import 'package:cornermon_api_gen/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**actor** | **String** | 행위자 (관리자 ID 또는 트랙 ID) | 
**action** | **String** | 행위 종류 | 
**target** | **String** | 행위 대상 식별자 | 
**success** | **bool** |  | 
**occurredAt** | [**DateTime**](DateTime.md) |  | 
**metadata** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


