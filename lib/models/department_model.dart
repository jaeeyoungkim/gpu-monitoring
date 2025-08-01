import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'department_model.g.dart';

/// 부서 상태 열거형
enum DepartmentStatus {
  allocated,  // 할당됨
  pending,    // 대기중 (신규 요청)
  optimized,  // 최적화됨
}

/// 부서 모델 클래스
@JsonSerializable()
class DepartmentModel extends Equatable {
  final String name;
  final String gpu;
  final String assignment;
  final List<bool> schedule; // 월화수목금토일 (7일)
  final int utilization;
  final DepartmentStatus status;
  final String? heatmapRef; // 히트맵 GPU ID 참조

  const DepartmentModel({
    required this.name,
    required this.gpu,
    required this.assignment,
    required this.schedule,
    required this.utilization,
    required this.status,
    this.heatmapRef,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) =>
      _$DepartmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$DepartmentModelToJson(this);

  /// 주간 사용 일수 계산
  int get weeklyUsageDays => schedule.where((day) => day).length;

  /// 주간 사용률 계산 (7일 기준)
  double get weeklyUsageRate => weeklyUsageDays / 7.0;

  /// 상태별 한국어 텍스트
  String get statusText {
    switch (status) {
      case DepartmentStatus.allocated:
        return '할당됨';
      case DepartmentStatus.pending:
        return '대기중';
      case DepartmentStatus.optimized:
        return '최적화됨';
    }
  }

  /// 요일별 한국어 텍스트
  static const List<String> weekDays = ['월', '화', '수', '목', '금', '토', '일'];

  /// 사용 요일 목록 (한국어)
  List<String> get usageDaysText {
    final days = <String>[];
    for (int i = 0; i < schedule.length && i < weekDays.length; i++) {
      if (schedule[i]) {
        days.add(weekDays[i]);
      }
    }
    return days;
  }

  /// 사용 요일 텍스트 (쉼표로 구분)
  String get usageDaysString => usageDaysText.join(', ');

  /// 부서 모델 복사
  DepartmentModel copyWith({
    String? name,
    String? gpu,
    String? assignment,
    List<bool>? schedule,
    int? utilization,
    DepartmentStatus? status,
    String? heatmapRef,
  }) {
    return DepartmentModel(
      name: name ?? this.name,
      gpu: gpu ?? this.gpu,
      assignment: assignment ?? this.assignment,
      schedule: schedule ?? this.schedule,
      utilization: utilization ?? this.utilization,
      status: status ?? this.status,
      heatmapRef: heatmapRef ?? this.heatmapRef,
    );
  }

  @override
  List<Object?> get props => [
        name,
        gpu,
        assignment,
        schedule,
        utilization,
        status,
        heatmapRef,
      ];
}

/// 스케줄링 시나리오 모델
@JsonSerializable()
class SchedulingScenario extends Equatable {
  final List<DepartmentModel> departments;
  final int totalGPUs;
  final int newGPUsNeeded;
  final int totalCost;
  final OptimizationSavings? savings;
  final Map<String, GPUImprovement>? improvements;

  const SchedulingScenario({
    required this.departments,
    required this.totalGPUs,
    required this.newGPUsNeeded,
    required this.totalCost,
    this.savings,
    this.improvements,
  });

  factory SchedulingScenario.fromJson(Map<String, dynamic> json) =>
      _$SchedulingScenarioFromJson(json);

  Map<String, dynamic> toJson() => _$SchedulingScenarioToJson(this);

  @override
  List<Object?> get props => [
        departments,
        totalGPUs,
        newGPUsNeeded,
        totalCost,
        savings,
        improvements,
      ];
}

/// 최적화 절약 효과 모델
@JsonSerializable()
class OptimizationSavings extends Equatable {
  final int gpusSaved;
  final int costSaved;
  final int operationalSavings;
  final int totalSavings;

  const OptimizationSavings({
    required this.gpusSaved,
    required this.costSaved,
    required this.operationalSavings,
    required this.totalSavings,
  });

  factory OptimizationSavings.fromJson(Map<String, dynamic> json) =>
      _$OptimizationSavingsFromJson(json);

  Map<String, dynamic> toJson() => _$OptimizationSavingsToJson(this);

  /// 비용을 한국어 형식으로 포맷 (예: ₩80M)
  String formatCost(int cost) {
    if (cost >= 1000000000) {
      return '₩${(cost / 1000000000).toStringAsFixed(1)}B';
    } else if (cost >= 1000000) {
      return '₩${(cost / 1000000).toStringAsFixed(0)}M';
    } else if (cost >= 1000) {
      return '₩${(cost / 1000).toStringAsFixed(0)}K';
    } else {
      return '₩$cost';
    }
  }

  String get costSavedFormatted => formatCost(costSaved);
  String get operationalSavingsFormatted => formatCost(operationalSavings);
  String get totalSavingsFormatted => formatCost(totalSavings);

  @override
  List<Object?> get props => [
        gpusSaved,
        costSaved,
        operationalSavings,
        totalSavings,
      ];
}

/// GPU 개선 효과 모델
@JsonSerializable()
class GPUImprovement extends Equatable {
  final int before;
  final int after;
  final int improvement;

  const GPUImprovement({
    required this.before,
    required this.after,
    required this.improvement,
  });

  factory GPUImprovement.fromJson(Map<String, dynamic> json) =>
      _$GPUImprovementFromJson(json);

  Map<String, dynamic> toJson() => _$GPUImprovementToJson(this);

  /// 개선율 백분율
  double get improvementPercentage => improvement.toDouble();

  /// 개선 효과 텍스트
  String get improvementText => '${before}% → ${after}% (+${improvement}%)';

  @override
  List<Object?> get props => [before, after, improvement];
}

/// 스케줄링 데이터 모델 (현재 + 최적화)
@JsonSerializable()
class SchedulingData extends Equatable {
  final SchedulingScenario current;
  final SchedulingScenario optimized;

  const SchedulingData({
    required this.current,
    required this.optimized,
  });

  factory SchedulingData.fromJson(Map<String, dynamic> json) =>
      _$SchedulingDataFromJson(json);

  Map<String, dynamic> toJson() => _$SchedulingDataToJson(this);

  @override
  List<Object?> get props => [current, optimized];
}

/// 부서 리스트 확장 메서드
extension DepartmentListExtensions on List<DepartmentModel> {
  /// 상태별 필터링
  List<DepartmentModel> filterByStatus(DepartmentStatus status) {
    return where((dept) => dept.status == status).toList();
  }

  /// 특정 GPU를 사용하는 부서들
  List<DepartmentModel> filterByGPU(String gpuId) {
    return where((dept) => dept.gpu == gpuId).toList();
  }

  /// 총 사용률 계산
  double get totalUtilization {
    if (isEmpty) return 0.0;
    return fold<int>(0, (sum, dept) => sum + dept.utilization) / length;
  }

  /// 스케줄 충돌 검사
  List<ScheduleConflict> checkScheduleConflicts() {
    final conflicts = <ScheduleConflict>[];
    final gpuSchedules = <String, List<DepartmentModel>>{};

    // GPU별로 부서들을 그룹화
    for (final dept in this) {
      if (!gpuSchedules.containsKey(dept.gpu)) {
        gpuSchedules[dept.gpu] = [];
      }
      gpuSchedules[dept.gpu]!.add(dept);
    }

    // 각 GPU별로 스케줄 충돌 검사
    for (final entry in gpuSchedules.entries) {
      final gpu = entry.key;
      final departments = entry.value;

      if (departments.length > 1) {
        for (int day = 0; day < 7; day++) {
          final conflictingDepts = departments
              .where((dept) => dept.schedule.length > day && dept.schedule[day])
              .toList();

          if (conflictingDepts.length > 1) {
            conflicts.add(ScheduleConflict(
              gpu: gpu,
              day: day,
              departments: conflictingDepts.map((d) => d.name).toList(),
            ));
          }
        }
      }
    }

    return conflicts;
  }
}

/// 스케줄 충돌 모델
class ScheduleConflict extends Equatable {
  final String gpu;
  final int day;
  final List<String> departments;

  const ScheduleConflict({
    required this.gpu,
    required this.day,
    required this.departments,
  });

  /// 요일 텍스트
  String get dayText => DepartmentModel.weekDays[day];

  /// 충돌 설명 텍스트
  String get conflictDescription =>
      '$gpu에서 $dayText요일에 ${departments.join(', ')} 부서 간 스케줄 충돌';

  @override
  List<Object?> get props => [gpu, day, departments];
}