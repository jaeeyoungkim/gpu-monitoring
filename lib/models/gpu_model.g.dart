// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gpu_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GPUPerformance _$GPUPerformanceFromJson(Map<String, dynamic> json) =>
    GPUPerformance(
      latency: (json['latency'] as num).toDouble(),
      tps: (json['tps'] as num).toInt(),
    );

Map<String, dynamic> _$GPUPerformanceToJson(GPUPerformance instance) =>
    <String, dynamic>{
      'latency': instance.latency,
      'tps': instance.tps,
    };

MIGInstance _$MIGInstanceFromJson(Map<String, dynamic> json) => MIGInstance(
      id: json['id'] as String,
      util: (json['util'] as num).toInt(),
    );

Map<String, dynamic> _$MIGInstanceToJson(MIGInstance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'util': instance.util,
    };

GPUModel _$GPUModelFromJson(Map<String, dynamic> json) => GPUModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avgUtil: (json['avgUtil'] as num).toInt(),
      isMig: json['isMig'] as bool,
      migInstances: (json['migInstances'] as List<dynamic>?)
          ?.map((e) => MIGInstance.fromJson(e as Map<String, dynamic>))
          .toList(),
      performance:
          GPUPerformance.fromJson(json['performance'] as Map<String, dynamic>),
      monthlyData: (json['monthlyData'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      weeklyData: (json['weeklyData'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      dailyData: (json['dailyData'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      departmentName: json['departmentName'] as String?,
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$GPUModelToJson(GPUModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avgUtil': instance.avgUtil,
      'isMig': instance.isMig,
      'migInstances': instance.migInstances,
      'performance': instance.performance,
      'monthlyData': instance.monthlyData,
      'weeklyData': instance.weeklyData,
      'dailyData': instance.dailyData,
      'departmentName': instance.departmentName,
      'userName': instance.userName,
    };
