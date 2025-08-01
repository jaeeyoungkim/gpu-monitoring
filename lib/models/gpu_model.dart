import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'gpu_model.g.dart';

/// GPU 성능 메트릭 모델
@JsonSerializable()
class GPUPerformance extends Equatable {
  final double latency;
  final int tps;

  const GPUPerformance({
    required this.latency,
    required this.tps,
  });

  factory GPUPerformance.fromJson(Map<String, dynamic> json) =>
      _$GPUPerformanceFromJson(json);

  Map<String, dynamic> toJson() => _$GPUPerformanceToJson(this);

  @override
  List<Object?> get props => [latency, tps];
}

/// MIG 인스턴스 모델
@JsonSerializable()
class MIGInstance extends Equatable {
  final String id;
  final int util;

  const MIGInstance({
    required this.id,
    required this.util,
  });

  factory MIGInstance.fromJson(Map<String, dynamic> json) =>
      _$MIGInstanceFromJson(json);

  Map<String, dynamic> toJson() => _$MIGInstanceToJson(this);

  @override
  List<Object?> get props => [id, util];
}

/// GPU 사용률 레벨 열거형
enum UtilizationLevel {
  none,    // 할당안됨 (0%)
  low,     // 낮음 (1-30%)
  medium,  // 보통 (31-70%)
  high,    // 높음 (71-100%)
}

/// GPU 모델 클래스
@JsonSerializable()
class GPUModel extends Equatable {
  final String id;
  final String name;
  final int avgUtil;
  final bool isMig;
  final List<MIGInstance>? migInstances;
  final GPUPerformance performance;
  final List<int> monthlyData;
  final List<int> weeklyData;
  final List<int> dailyData;
  
  // 인벤토리 관리 필드
  final String? departmentName;
  final String? userName;

  const GPUModel({
    required this.id,
    required this.name,
    required this.avgUtil,
    required this.isMig,
    this.migInstances,
    required this.performance,
    required this.monthlyData,
    required this.weeklyData,
    required this.dailyData,
    this.departmentName,
    this.userName,
  });

  factory GPUModel.fromJson(Map<String, dynamic> json) =>
      _$GPUModelFromJson(json);

  Map<String, dynamic> toJson() => _$GPUModelToJson(this);

  /// 사용률 레벨 계산
  UtilizationLevel get utilizationLevel {
    if (avgUtil == 0) return UtilizationLevel.none;
    if (avgUtil <= 30) return UtilizationLevel.low;
    if (avgUtil <= 70) return UtilizationLevel.medium;
    return UtilizationLevel.high;
  }

  /// 사용률 레벨에 따른 CSS 클래스명 (웹 버전 호환)
  String get utilizationClass {
    switch (utilizationLevel) {
      case UtilizationLevel.none:
        return 'util-none';
      case UtilizationLevel.low:
        return 'util-low';
      case UtilizationLevel.medium:
        return 'util-medium';
      case UtilizationLevel.high:
        return 'util-high';
    }
  }

  /// 사용률 레벨 한국어 텍스트
  String get utilizationLevelText {
    switch (utilizationLevel) {
      case UtilizationLevel.none:
        return '할당안됨';
      case UtilizationLevel.low:
        return '낮음';
      case UtilizationLevel.medium:
        return '보통';
      case UtilizationLevel.high:
        return '높음';
    }
  }

  /// 사용률 범위 텍스트
  String get utilizationRangeText {
    switch (utilizationLevel) {
      case UtilizationLevel.none:
        return '0%';
      case UtilizationLevel.low:
        return '1-30%';
      case UtilizationLevel.medium:
        return '31-70%';
      case UtilizationLevel.high:
        return '71-100%';
    }
  }

  /// GPU 모델 복사 (불변성 유지)
  GPUModel copyWith({
    String? id,
    String? name,
    int? avgUtil,
    bool? isMig,
    List<MIGInstance>? migInstances,
    GPUPerformance? performance,
    List<int>? monthlyData,
    List<int>? weeklyData,
    List<int>? dailyData,
    String? departmentName,
    String? userName,
  }) {
    return GPUModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avgUtil: avgUtil ?? this.avgUtil,
      isMig: isMig ?? this.isMig,
      migInstances: migInstances ?? this.migInstances,
      performance: performance ?? this.performance,
      monthlyData: monthlyData ?? this.monthlyData,
      weeklyData: weeklyData ?? this.weeklyData,
      dailyData: dailyData ?? this.dailyData,
      departmentName: departmentName ?? this.departmentName,
      userName: userName ?? this.userName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        avgUtil,
        isMig,
        migInstances,
        performance,
        monthlyData,
        weeklyData,
        dailyData,
        departmentName,
        userName,
      ];
}

/// GPU 리스트 확장 메서드
extension GPUListExtensions on List<GPUModel> {
  /// 사용률이 낮은 순으로 정렬
  List<GPUModel> sortedByUtilization() {
    final sorted = List<GPUModel>.from(this);
    sorted.sort((a, b) => a.avgUtil.compareTo(b.avgUtil));
    return sorted;
  }

  /// 특정 사용률 레벨로 필터링
  List<GPUModel> filterByUtilizationLevel(UtilizationLevel level) {
    return where((gpu) => gpu.utilizationLevel == level).toList();
  }

  /// 평균 사용률 계산
  double get averageUtilization {
    if (isEmpty) return 0.0;
    return fold<int>(0, (sum, gpu) => sum + gpu.avgUtil) / length;
  }

  /// 활성 GPU 개수 (사용률 > 0%)
  int get activeCount => where((gpu) => gpu.avgUtil > 0).length;

  /// 효율적 GPU 개수 (사용률 > 70%)
  int get efficientCount => where((gpu) => gpu.avgUtil > 70).length;
}