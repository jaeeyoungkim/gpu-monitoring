import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../models/gpu_model.dart';

part 'daily_cost_model.g.dart';

/// 일별 비용 데이터 엔트리
@JsonSerializable()
class DailyCostEntry extends Equatable {
  final DateTime date;
  final String userId;
  final String userName;
  final String departmentName;
  final String gpuId;
  final String gpuType;
  final String instanceType;
  final double hourlyRate;
  final double utilizationRate;
  final double dailyCost;

  const DailyCostEntry({
    required this.date,
    required this.userId,
    required this.userName,
    required this.departmentName,
    required this.gpuId,
    required this.gpuType,
    required this.instanceType,
    required this.hourlyRate,
    required this.utilizationRate,
    required this.dailyCost,
  });

  factory DailyCostEntry.fromJson(Map<String, dynamic> json) =>
      _$DailyCostEntryFromJson(json);

  Map<String, dynamic> toJson() => _$DailyCostEntryToJson(this);

  /// GPU 모델로부터 일별 비용 엔트리 생성
  factory DailyCostEntry.fromGPUModel(GPUModel gpu, DateTime date) {
    if (gpu.cloudMetadata == null) {
      throw ArgumentError('GPU must have cloud metadata for cost calculation');
    }

    final hourlyRate = gpu.cloudMetadata!.costPerGPUPerHour;
    final utilizationRate = gpu.avgUtil / 100.0;
    final dailyCost = hourlyRate * utilizationRate * 24; // 24시간 기준

    return DailyCostEntry(
      date: date,
      userId: gpu.userName ?? 'unknown',
      userName: gpu.userName ?? '미할당',
      departmentName: gpu.departmentName ?? '미할당',
      gpuId: gpu.id,
      gpuType: gpu.cloudMetadata!.gpuTypeKoreanName,
      instanceType: gpu.cloudMetadata!.instanceType,
      hourlyRate: hourlyRate,
      utilizationRate: utilizationRate,
      dailyCost: dailyCost,
    );
  }

  @override
  List<Object?> get props => [
        date,
        userId,
        userName,
        departmentName,
        gpuId,
        gpuType,
        instanceType,
        hourlyRate,
        utilizationRate,
        dailyCost,
      ];
}

/// 일별 비용 데이터 구조
@JsonSerializable()
class DailyCostData extends Equatable {
  final DateTime date;
  final Map<String, double> departmentCosts; // 부서명: 일일 비용
  final double totalCost; // 해당 일자 전체 비용

  const DailyCostData({
    required this.date,
    required this.departmentCosts,
    required this.totalCost,
  });

  factory DailyCostData.fromJson(Map<String, dynamic> json) =>
      _$DailyCostDataFromJson(json);

  Map<String, dynamic> toJson() => _$DailyCostDataToJson(this);

  /// 일별 비용 엔트리 목록으로부터 집계 데이터 생성
  factory DailyCostData.fromEntries(DateTime date, List<DailyCostEntry> entries) {
    final departmentCosts = <String, double>{};
    
    for (final entry in entries.where((e) => _isSameDate(e.date, date))) {
      departmentCosts[entry.departmentName] = 
          (departmentCosts[entry.departmentName] ?? 0) + entry.dailyCost;
    }

    final totalCost = departmentCosts.values.fold<double>(0, (sum, cost) => sum + cost);

    return DailyCostData(
      date: date,
      departmentCosts: departmentCosts,
      totalCost: totalCost,
    );
  }

  static bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  List<Object?> get props => [date, departmentCosts, totalCost];
}

/// 집계된 비용 데이터
class AggregatedCostData extends Equatable {
  final Map<String, Map<DateTime, double>> departmentDaily; // 부서 → 날짜 → 비용
  final Map<String, Map<DateTime, double>> userDaily; // 사용자 → 날짜 → 비용
  final Map<DateTime, double> totalDaily; // 날짜 → 전체 비용
  final List<String> departments; // 부서 목록
  final List<String> users; // 사용자 목록

  const AggregatedCostData({
    required this.departmentDaily,
    required this.userDaily,
    required this.totalDaily,
    required this.departments,
    required this.users,
  });

  /// 일별 비용 엔트리 목록으로부터 집계 데이터 생성
  factory AggregatedCostData.fromEntries(List<DailyCostEntry> entries) {
    final departmentDaily = <String, Map<DateTime, double>>{};
    final userDaily = <String, Map<DateTime, double>>{};
    final totalDaily = <DateTime, double>{};
    final departments = <String>{};
    final users = <String>{};

    for (final entry in entries) {
      final date = _normalizeDate(entry.date);
      
      // 부서별 집계
      departmentDaily
          .putIfAbsent(entry.departmentName, () => <DateTime, double>{})
          [date] = (departmentDaily[entry.departmentName]?[date] ?? 0) + entry.dailyCost;
      
      // 사용자별 집계
      userDaily
          .putIfAbsent(entry.userName, () => <DateTime, double>{})
          [date] = (userDaily[entry.userName]?[date] ?? 0) + entry.dailyCost;
      
      // 전체 집계
      totalDaily[date] = (totalDaily[date] ?? 0) + entry.dailyCost;
      
      departments.add(entry.departmentName);
      users.add(entry.userName);
    }

    return AggregatedCostData(
      departmentDaily: departmentDaily,
      userDaily: userDaily,
      totalDaily: totalDaily,
      departments: departments.toList()..sort(),
      users: users.toList()..sort(),
    );
  }

  /// 날짜 정규화 (시간 정보 제거)
  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 특정 기간의 데이터 필터링
  AggregatedCostData filterByDateRange(DateTime startDate, DateTime endDate) {
    final filteredDepartmentDaily = <String, Map<DateTime, double>>{};
    final filteredUserDaily = <String, Map<DateTime, double>>{};
    final filteredTotalDaily = <DateTime, double>{};

    for (final dept in departmentDaily.keys) {
      filteredDepartmentDaily[dept] = Map.fromEntries(
        departmentDaily[dept]!.entries.where((entry) =>
            entry.key.isAfter(startDate.subtract(const Duration(days: 1))) &&
            entry.key.isBefore(endDate.add(const Duration(days: 1)))),
      );
    }

    for (final user in userDaily.keys) {
      filteredUserDaily[user] = Map.fromEntries(
        userDaily[user]!.entries.where((entry) =>
            entry.key.isAfter(startDate.subtract(const Duration(days: 1))) &&
            entry.key.isBefore(endDate.add(const Duration(days: 1)))),
      );
    }

    filteredTotalDaily.addAll(Map.fromEntries(
      totalDaily.entries.where((entry) =>
          entry.key.isAfter(startDate.subtract(const Duration(days: 1))) &&
          entry.key.isBefore(endDate.add(const Duration(days: 1)))),
    ));

    return AggregatedCostData(
      departmentDaily: filteredDepartmentDaily,
      userDaily: filteredUserDaily,
      totalDaily: filteredTotalDaily,
      departments: departments,
      users: users,
    );
  }

  /// 부서 필터링
  AggregatedCostData filterByDepartments(Set<String> selectedDepartments) {
    final filteredDepartmentDaily = <String, Map<DateTime, double>>{};
    
    for (final dept in selectedDepartments) {
      if (departmentDaily.containsKey(dept)) {
        filteredDepartmentDaily[dept] = departmentDaily[dept]!;
      }
    }

    // 필터링된 부서의 총합으로 totalDaily 재계산
    final filteredTotalDaily = <DateTime, double>{};
    for (final deptData in filteredDepartmentDaily.values) {
      for (final entry in deptData.entries) {
        filteredTotalDaily[entry.key] = (filteredTotalDaily[entry.key] ?? 0) + entry.value;
      }
    }

    return AggregatedCostData(
      departmentDaily: filteredDepartmentDaily,
      userDaily: userDaily,
      totalDaily: filteredTotalDaily,
      departments: departments,
      users: users,
    );
  }

  @override
  List<Object?> get props => [
        departmentDaily,
        userDaily,
        totalDaily,
        departments,
        users,
      ];
}

/// 필터 상태 관리
class FilterState extends Equatable {
  final Set<String> selectedDepartments;
  final Set<String> selectedUsers;
  final DateRange dateRange;

  const FilterState({
    required this.selectedDepartments,
    required this.selectedUsers,
    required this.dateRange,
  });

  factory FilterState.initial() {
    return FilterState(
      selectedDepartments: <String>{},
      selectedUsers: <String>{},
      dateRange: DateRange.last30Days(),
    );
  }

  FilterState copyWith({
    Set<String>? selectedDepartments,
    Set<String>? selectedUsers,
    DateRange? dateRange,
  }) {
    return FilterState(
      selectedDepartments: selectedDepartments ?? this.selectedDepartments,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  @override
  List<Object?> get props => [selectedDepartments, selectedUsers, dateRange];
}

/// 날짜 범위
class DateRange extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final DateRangeType type;

  const DateRange({
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  factory DateRange.last30Days() {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    return DateRange(
      startDate: startDate,
      endDate: endDate,
      type: DateRangeType.last30Days,
    );
  }

  factory DateRange.last7Days() {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));
    return DateRange(
      startDate: startDate,
      endDate: endDate,
      type: DateRangeType.last7Days,
    );
  }

  factory DateRange.custom(DateTime startDate, DateTime endDate) {
    return DateRange(
      startDate: startDate,
      endDate: endDate,
      type: DateRangeType.custom,
    );
  }

  @override
  List<Object?> get props => [startDate, endDate, type];
}

enum DateRangeType {
  last30Days,
  last7Days,
  custom,
}