// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_cost_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyCostEntry _$DailyCostEntryFromJson(Map<String, dynamic> json) =>
    DailyCostEntry(
      date: DateTime.parse(json['date'] as String),
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      departmentName: json['departmentName'] as String,
      gpuId: json['gpuId'] as String,
      gpuType: json['gpuType'] as String,
      instanceType: json['instanceType'] as String,
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      utilizationRate: (json['utilizationRate'] as num).toDouble(),
      dailyCost: (json['dailyCost'] as num).toDouble(),
    );

Map<String, dynamic> _$DailyCostEntryToJson(DailyCostEntry instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'userId': instance.userId,
      'userName': instance.userName,
      'departmentName': instance.departmentName,
      'gpuId': instance.gpuId,
      'gpuType': instance.gpuType,
      'instanceType': instance.instanceType,
      'hourlyRate': instance.hourlyRate,
      'utilizationRate': instance.utilizationRate,
      'dailyCost': instance.dailyCost,
    };

DailyCostData _$DailyCostDataFromJson(Map<String, dynamic> json) =>
    DailyCostData(
      date: DateTime.parse(json['date'] as String),
      departmentCosts: (json['departmentCosts'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      totalCost: (json['totalCost'] as num).toDouble(),
    );

Map<String, dynamic> _$DailyCostDataToJson(DailyCostData instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'departmentCosts': instance.departmentCosts,
      'totalCost': instance.totalCost,
    };
