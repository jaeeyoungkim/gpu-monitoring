// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepartmentModel _$DepartmentModelFromJson(Map<String, dynamic> json) =>
    DepartmentModel(
      name: json['name'] as String,
      gpu: json['gpu'] as String,
      assignment: json['assignment'] as String,
      schedule:
          (json['schedule'] as List<dynamic>).map((e) => e as bool).toList(),
      utilization: (json['utilization'] as num).toInt(),
      status: $enumDecode(_$DepartmentStatusEnumMap, json['status']),
      heatmapRef: json['heatmapRef'] as String?,
    );

Map<String, dynamic> _$DepartmentModelToJson(DepartmentModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'gpu': instance.gpu,
      'assignment': instance.assignment,
      'schedule': instance.schedule,
      'utilization': instance.utilization,
      'status': _$DepartmentStatusEnumMap[instance.status]!,
      'heatmapRef': instance.heatmapRef,
    };

const _$DepartmentStatusEnumMap = {
  DepartmentStatus.allocated: 'allocated',
  DepartmentStatus.pending: 'pending',
  DepartmentStatus.optimized: 'optimized',
};

SchedulingScenario _$SchedulingScenarioFromJson(Map<String, dynamic> json) =>
    SchedulingScenario(
      departments: (json['departments'] as List<dynamic>)
          .map((e) => DepartmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalGPUs: (json['totalGPUs'] as num).toInt(),
      newGPUsNeeded: (json['newGPUsNeeded'] as num).toInt(),
      totalCost: (json['totalCost'] as num).toInt(),
      savings: json['savings'] == null
          ? null
          : OptimizationSavings.fromJson(
              json['savings'] as Map<String, dynamic>),
      improvements: (json['improvements'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, GPUImprovement.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$SchedulingScenarioToJson(SchedulingScenario instance) =>
    <String, dynamic>{
      'departments': instance.departments,
      'totalGPUs': instance.totalGPUs,
      'newGPUsNeeded': instance.newGPUsNeeded,
      'totalCost': instance.totalCost,
      'savings': instance.savings,
      'improvements': instance.improvements,
    };

OptimizationSavings _$OptimizationSavingsFromJson(Map<String, dynamic> json) =>
    OptimizationSavings(
      gpusSaved: (json['gpusSaved'] as num).toInt(),
      costSaved: (json['costSaved'] as num).toInt(),
      operationalSavings: (json['operationalSavings'] as num).toInt(),
      totalSavings: (json['totalSavings'] as num).toInt(),
    );

Map<String, dynamic> _$OptimizationSavingsToJson(
        OptimizationSavings instance) =>
    <String, dynamic>{
      'gpusSaved': instance.gpusSaved,
      'costSaved': instance.costSaved,
      'operationalSavings': instance.operationalSavings,
      'totalSavings': instance.totalSavings,
    };

GPUImprovement _$GPUImprovementFromJson(Map<String, dynamic> json) =>
    GPUImprovement(
      before: (json['before'] as num).toInt(),
      after: (json['after'] as num).toInt(),
      improvement: (json['improvement'] as num).toInt(),
    );

Map<String, dynamic> _$GPUImprovementToJson(GPUImprovement instance) =>
    <String, dynamic>{
      'before': instance.before,
      'after': instance.after,
      'improvement': instance.improvement,
    };

SchedulingData _$SchedulingDataFromJson(Map<String, dynamic> json) =>
    SchedulingData(
      current:
          SchedulingScenario.fromJson(json['current'] as Map<String, dynamic>),
      optimized: SchedulingScenario.fromJson(
          json['optimized'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SchedulingDataToJson(SchedulingData instance) =>
    <String, dynamic>{
      'current': instance.current,
      'optimized': instance.optimized,
    };
