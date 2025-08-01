import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'gpu_model.dart';

part 'optimization_model.g.dart';

/// 최적화 기회 타입 열거형
enum OptimizationOpportunityType {
  assignment,     // 미할당 GPU 활용
  consolidation,  // GPU 워크로드 통합
  reallocation,   // GPU 재할당
  cooling,        // 냉각 최적화
  monitoring,     // 사용률 모니터링
}

/// 최적화 우선순위 열거형
enum OptimizationPriority {
  low,
  medium,
  high,
  critical,
}

/// 최적화 기회 모델
@JsonSerializable()
class OptimizationOpportunity extends Equatable {
  final OptimizationOpportunityType type;
  final String title;
  final String description;
  final List<String> gpus;
  final int potentialSavings;
  final OptimizationPriority priority;
  final String? icon;

  const OptimizationOpportunity({
    required this.type,
    required this.title,
    required this.description,
    required this.gpus,
    required this.potentialSavings,
    required this.priority,
    this.icon,
  });

  factory OptimizationOpportunity.fromJson(Map<String, dynamic> json) =>
      _$OptimizationOpportunityFromJson(json);

  Map<String, dynamic> toJson() => _$OptimizationOpportunityToJson(this);

  /// 타입별 기본 아이콘
  String get defaultIcon {
    switch (type) {
      case OptimizationOpportunityType.assignment:
        return '🎯';
      case OptimizationOpportunityType.consolidation:
        return '🔄';
      case OptimizationOpportunityType.reallocation:
        return '↔️';
      case OptimizationOpportunityType.cooling:
        return '❄️';
      case OptimizationOpportunityType.monitoring:
        return '📊';
    }
  }

  /// 실제 사용할 아이콘
  String get displayIcon => icon ?? defaultIcon;

  /// 우선순위 텍스트
  String get priorityText {
    switch (priority) {
      case OptimizationPriority.low:
        return '낮음';
      case OptimizationPriority.medium:
        return '보통';
      case OptimizationPriority.high:
        return '높음';
      case OptimizationPriority.critical:
        return '긴급';
    }
  }

  /// 절약 효과 포맷팅
  String get potentialSavingsFormatted {
    if (potentialSavings >= 1000000000) {
      return '₩${(potentialSavings / 1000000000).toStringAsFixed(1)}B';
    } else if (potentialSavings >= 1000000) {
      return '₩${(potentialSavings / 1000000).toStringAsFixed(0)}M';
    } else if (potentialSavings >= 1000) {
      return '₩${(potentialSavings / 1000).toStringAsFixed(0)}K';
    } else {
      return '₩$potentialSavings';
    }
  }

  /// GPU 목록 텍스트
  String get gpusText => gpus.join(', ');

  @override
  List<Object?> get props => [
        type,
        title,
        description,
        gpus,
        potentialSavings,
        priority,
        icon,
      ];
}

/// 히트맵 분석 결과 모델
@JsonSerializable()
class HeatmapAnalysis extends Equatable {
  final List<GPUModel> underutilized;
  final List<GPUModel> unassigned;
  final List<GPUModel> highUtilization;
  final List<OptimizationOpportunity> optimizationOpportunities;
  final DateTime analyzedAt;

  const HeatmapAnalysis({
    required this.underutilized,
    required this.unassigned,
    required this.highUtilization,
    required this.optimizationOpportunities,
    required this.analyzedAt,
  });

  factory HeatmapAnalysis.fromJson(Map<String, dynamic> json) =>
      _$HeatmapAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$HeatmapAnalysisToJson(this);

  /// 총 최적화 기회 개수
  int get totalOpportunities => optimizationOpportunities.length;

  /// 총 잠재 절약액
  int get totalPotentialSavings => optimizationOpportunities
      .fold<int>(0, (sum, opportunity) => sum + opportunity.potentialSavings);

  /// 총 잠재 절약액 포맷팅
  String get totalPotentialSavingsFormatted {
    if (totalPotentialSavings >= 1000000000) {
      return '₩${(totalPotentialSavings / 1000000000).toStringAsFixed(1)}B';
    } else if (totalPotentialSavings >= 1000000) {
      return '₩${(totalPotentialSavings / 1000000).toStringAsFixed(0)}M';
    } else if (totalPotentialSavings >= 1000) {
      return '₩${(totalPotentialSavings / 1000).toStringAsFixed(0)}K';
    } else {
      return '₩$totalPotentialSavings';
    }
  }

  /// 우선순위별 기회 개수
  Map<OptimizationPriority, int> get opportunitiesByPriority {
    final counts = <OptimizationPriority, int>{};
    for (final priority in OptimizationPriority.values) {
      counts[priority] = optimizationOpportunities
          .where((opp) => opp.priority == priority)
          .length;
    }
    return counts;
  }

  /// 높은 우선순위 기회들
  List<OptimizationOpportunity> get highPriorityOpportunities =>
      optimizationOpportunities
          .where((opp) => opp.priority == OptimizationPriority.high ||
                         opp.priority == OptimizationPriority.critical)
          .toList();

  @override
  List<Object?> get props => [
        underutilized,
        unassigned,
        highUtilization,
        optimizationOpportunities,
        analyzedAt,
      ];
}

/// 최적화 추천 모델
@JsonSerializable()
class OptimizationRecommendation extends Equatable {
  final String title;
  final String description;
  final String benefit;
  final List<String> actionItems;
  final OptimizationPriority priority;
  final List<String> affectedGPUs;
  final int estimatedSavings;

  const OptimizationRecommendation({
    required this.title,
    required this.description,
    required this.benefit,
    required this.actionItems,
    required this.priority,
    required this.affectedGPUs,
    required this.estimatedSavings,
  });

  factory OptimizationRecommendation.fromJson(Map<String, dynamic> json) =>
      _$OptimizationRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$OptimizationRecommendationToJson(this);

  /// 절약 효과 포맷팅
  String get estimatedSavingsFormatted {
    if (estimatedSavings >= 1000000000) {
      return '₩${(estimatedSavings / 1000000000).toStringAsFixed(1)}B';
    } else if (estimatedSavings >= 1000000) {
      return '₩${(estimatedSavings / 1000000).toStringAsFixed(0)}M';
    } else if (estimatedSavings >= 1000) {
      return '₩${(estimatedSavings / 1000).toStringAsFixed(0)}K';
    } else {
      return '₩$estimatedSavings';
    }
  }

  @override
  List<Object?> get props => [
        title,
        description,
        benefit,
        actionItems,
        priority,
        affectedGPUs,
        estimatedSavings,
      ];
}

/// 최적화 분석 서비스 결과 모델
@JsonSerializable()
class OptimizationAnalysisResult extends Equatable {
  final HeatmapAnalysis heatmapAnalysis;
  final List<OptimizationRecommendation> recommendations;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const OptimizationAnalysisResult({
    required this.heatmapAnalysis,
    required this.recommendations,
    required this.metadata,
    required this.createdAt,
  });

  factory OptimizationAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$OptimizationAnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$OptimizationAnalysisResultToJson(this);

  /// 분석 요약 텍스트
  String get summaryText {
    final unassignedCount = heatmapAnalysis.unassigned.length;
    final underutilizedCount = heatmapAnalysis.underutilized.length;
    final highUtilCount = heatmapAnalysis.highUtilization.length;
    
    return '미할당 GPU ${unassignedCount}개, 저활용 GPU ${underutilizedCount}개, '
           '고활용 GPU ${highUtilCount}개 발견';
  }

  /// 총 추천사항 개수
  int get totalRecommendations => recommendations.length;

  /// 총 예상 절약액
  int get totalEstimatedSavings => recommendations
      .fold<int>(0, (sum, rec) => sum + rec.estimatedSavings);

  /// 총 예상 절약액 포맷팅
  String get totalEstimatedSavingsFormatted {
    if (totalEstimatedSavings >= 1000000000) {
      return '₩${(totalEstimatedSavings / 1000000000).toStringAsFixed(1)}B';
    } else if (totalEstimatedSavings >= 1000000) {
      return '₩${(totalEstimatedSavings / 1000000).toStringAsFixed(0)}M';
    } else if (totalEstimatedSavings >= 1000) {
      return '₩${(totalEstimatedSavings / 1000).toStringAsFixed(0)}K';
    } else {
      return '₩$totalEstimatedSavings';
    }
  }

  @override
  List<Object?> get props => [
        heatmapAnalysis,
        recommendations,
        metadata,
        createdAt,
      ];
}

/// 최적화 기회 리스트 확장 메서드
extension OptimizationOpportunityListExtensions on List<OptimizationOpportunity> {
  /// 우선순위별 정렬
  List<OptimizationOpportunity> sortedByPriority() {
    final sorted = List<OptimizationOpportunity>.from(this);
    sorted.sort((a, b) {
      final priorityOrder = {
        OptimizationPriority.critical: 4,
        OptimizationPriority.high: 3,
        OptimizationPriority.medium: 2,
        OptimizationPriority.low: 1,
      };
      return (priorityOrder[b.priority] ?? 0) - (priorityOrder[a.priority] ?? 0);
    });
    return sorted;
  }

  /// 절약액별 정렬 (높은 순)
  List<OptimizationOpportunity> sortedBySavings() {
    final sorted = List<OptimizationOpportunity>.from(this);
    sorted.sort((a, b) => b.potentialSavings.compareTo(a.potentialSavings));
    return sorted;
  }

  /// 타입별 필터링
  List<OptimizationOpportunity> filterByType(OptimizationOpportunityType type) {
    return where((opp) => opp.type == type).toList();
  }

  /// 우선순위별 필터링
  List<OptimizationOpportunity> filterByPriority(OptimizationPriority priority) {
    return where((opp) => opp.priority == priority).toList();
  }

  /// 총 절약 가능액
  int get totalPotentialSavings =>
      fold<int>(0, (sum, opp) => sum + opp.potentialSavings);
}