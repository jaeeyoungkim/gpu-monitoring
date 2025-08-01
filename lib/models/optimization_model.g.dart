// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optimization_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptimizationOpportunity _$OptimizationOpportunityFromJson(
        Map<String, dynamic> json) =>
    OptimizationOpportunity(
      type: $enumDecode(_$OptimizationOpportunityTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      gpus: (json['gpus'] as List<dynamic>).map((e) => e as String).toList(),
      potentialSavings: (json['potentialSavings'] as num).toInt(),
      priority: $enumDecode(_$OptimizationPriorityEnumMap, json['priority']),
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$OptimizationOpportunityToJson(
        OptimizationOpportunity instance) =>
    <String, dynamic>{
      'type': _$OptimizationOpportunityTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'gpus': instance.gpus,
      'potentialSavings': instance.potentialSavings,
      'priority': _$OptimizationPriorityEnumMap[instance.priority]!,
      'icon': instance.icon,
    };

const _$OptimizationOpportunityTypeEnumMap = {
  OptimizationOpportunityType.assignment: 'assignment',
  OptimizationOpportunityType.consolidation: 'consolidation',
  OptimizationOpportunityType.reallocation: 'reallocation',
  OptimizationOpportunityType.cooling: 'cooling',
  OptimizationOpportunityType.monitoring: 'monitoring',
};

const _$OptimizationPriorityEnumMap = {
  OptimizationPriority.low: 'low',
  OptimizationPriority.medium: 'medium',
  OptimizationPriority.high: 'high',
  OptimizationPriority.critical: 'critical',
};

HeatmapAnalysis _$HeatmapAnalysisFromJson(Map<String, dynamic> json) =>
    HeatmapAnalysis(
      underutilized: (json['underutilized'] as List<dynamic>)
          .map((e) => GPUModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      unassigned: (json['unassigned'] as List<dynamic>)
          .map((e) => GPUModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      highUtilization: (json['highUtilization'] as List<dynamic>)
          .map((e) => GPUModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      optimizationOpportunities:
          (json['optimizationOpportunities'] as List<dynamic>)
              .map((e) =>
                  OptimizationOpportunity.fromJson(e as Map<String, dynamic>))
              .toList(),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
    );

Map<String, dynamic> _$HeatmapAnalysisToJson(HeatmapAnalysis instance) =>
    <String, dynamic>{
      'underutilized': instance.underutilized,
      'unassigned': instance.unassigned,
      'highUtilization': instance.highUtilization,
      'optimizationOpportunities': instance.optimizationOpportunities,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
    };

OptimizationRecommendation _$OptimizationRecommendationFromJson(
        Map<String, dynamic> json) =>
    OptimizationRecommendation(
      title: json['title'] as String,
      description: json['description'] as String,
      benefit: json['benefit'] as String,
      actionItems: (json['actionItems'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      priority: $enumDecode(_$OptimizationPriorityEnumMap, json['priority']),
      affectedGPUs: (json['affectedGPUs'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      estimatedSavings: (json['estimatedSavings'] as num).toInt(),
    );

Map<String, dynamic> _$OptimizationRecommendationToJson(
        OptimizationRecommendation instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'benefit': instance.benefit,
      'actionItems': instance.actionItems,
      'priority': _$OptimizationPriorityEnumMap[instance.priority]!,
      'affectedGPUs': instance.affectedGPUs,
      'estimatedSavings': instance.estimatedSavings,
    };

OptimizationAnalysisResult _$OptimizationAnalysisResultFromJson(
        Map<String, dynamic> json) =>
    OptimizationAnalysisResult(
      heatmapAnalysis: HeatmapAnalysis.fromJson(
          json['heatmapAnalysis'] as Map<String, dynamic>),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) =>
              OptimizationRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$OptimizationAnalysisResultToJson(
        OptimizationAnalysisResult instance) =>
    <String, dynamic>{
      'heatmapAnalysis': instance.heatmapAnalysis,
      'recommendations': instance.recommendations,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
    };
