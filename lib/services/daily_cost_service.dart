import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gpu_model.dart';
import '../models/daily_cost_model.dart';
import '../services/gpu_data_service.dart';

/// 일별 비용 데이터 서비스 프로바이더
final dailyCostServiceProvider = Provider<DailyCostService>((ref) {
  return DailyCostService();
});

/// 필터 상태 프로바이더
final costFilterProvider = StateNotifierProvider<CostFilterNotifier, FilterState>((ref) {
  return CostFilterNotifier();
});

/// 집계된 비용 데이터 프로바이더
final aggregatedCostDataProvider = FutureProvider<AggregatedCostData>((ref) async {
  final service = ref.watch(dailyCostServiceProvider);
  final gpuDataAsync = ref.watch(gpuDataProvider);
  
  return gpuDataAsync.when(
    data: (gpuData) => service.generateAggregatedCostData(gpuData),
    loading: () => const AggregatedCostData(
      departmentDaily: {},
      userDaily: {},
      totalDaily: {},
      departments: [],
      users: [],
    ),
    error: (error, stack) => const AggregatedCostData(
      departmentDaily: {},
      userDaily: {},
      totalDaily: {},
      departments: [],
      users: [],
    ),
  );
});

/// 필터링된 비용 데이터 프로바이더
final filteredCostDataProvider = FutureProvider<AggregatedCostData>((ref) async {
  final aggregatedData = await ref.watch(aggregatedCostDataProvider.future);
  final filterState = ref.watch(costFilterProvider);
  
  var filteredData = aggregatedData;
  
  // 부서 필터링
  if (filterState.selectedDepartments.isNotEmpty) {
    filteredData = filteredData.filterByDepartments(filterState.selectedDepartments);
  }
  
  // 날짜 범위 필터링
  filteredData = filteredData.filterByDateRange(
    filterState.dateRange.startDate,
    filterState.dateRange.endDate,
  );
  
  return filteredData;
});

/// 일별 비용 데이터 서비스
class DailyCostService {
  
  /// GPU 데이터로부터 집계된 비용 데이터 생성
  AggregatedCostData generateAggregatedCostData(List<GPUModel> gpuData) {
    final entries = <DailyCostEntry>[];
    final now = DateTime.now();
    
    // 최근 30일간의 데이터 생성
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      
      for (final gpu in gpuData) {
        if (gpu.cloudMetadata != null && gpu.departmentName != null && gpu.userName != null) {
          try {
            // 일별 사용률 시뮬레이션 (실제로는 히스토리컬 데이터에서 가져와야 함)
            final simulatedGpu = _simulateGPUUsageForDate(gpu, date, i);
            final entry = DailyCostEntry.fromGPUModel(simulatedGpu, date);
            entries.add(entry);
          } catch (e) {
            // 클라우드 메타데이터가 없는 GPU는 스킵
            continue;
          }
        }
      }
    }
    
    return AggregatedCostData.fromEntries(entries);
  }
  
  /// 특정 날짜에 대한 GPU 사용률 시뮬레이션
  GPUModel _simulateGPUUsageForDate(GPUModel gpu, DateTime date, int daysAgo) {
    // 실제 구현에서는 히스토리컬 데이터베이스에서 가져와야 함
    // 여기서는 시뮬레이션을 위해 약간의 변동을 주어 생성
    final baseUtil = gpu.avgUtil;
    final variation = (date.day + date.hour + gpu.id.hashCode) % 20 - 10; // -10 ~ +10 변동
    final simulatedUtil = (baseUtil + variation).clamp(0, 100);
    
    return gpu.copyWith(avgUtil: simulatedUtil);
  }
  
  /// 일별 비용 엔트리 목록 생성
  List<DailyCostEntry> generateDailyCostEntries(List<GPUModel> gpuData, DateRange dateRange) {
    final entries = <DailyCostEntry>[];
    final startDate = dateRange.startDate;
    final endDate = dateRange.endDate;
    
    var currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final daysDiff = endDate.difference(currentDate).inDays;
      
      for (final gpu in gpuData) {
        if (gpu.cloudMetadata != null && gpu.departmentName != null && gpu.userName != null) {
          try {
            final simulatedGpu = _simulateGPUUsageForDate(gpu, currentDate, daysDiff);
            final entry = DailyCostEntry.fromGPUModel(simulatedGpu, currentDate);
            entries.add(entry);
          } catch (e) {
            continue;
          }
        }
      }
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return entries;
  }
  
  /// 부서별 일별 비용 데이터 생성 (스택 차트용)
  List<DailyCostData> generateDailyCostDataList(List<GPUModel> gpuData, DateRange dateRange) {
    final entries = generateDailyCostEntries(gpuData, dateRange);
    final dailyDataMap = <DateTime, List<DailyCostEntry>>{};
    
    // 날짜별로 엔트리 그룹핑
    for (final entry in entries) {
      final normalizedDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      dailyDataMap.putIfAbsent(normalizedDate, () => []).add(entry);
    }
    
    // 각 날짜별로 DailyCostData 생성
    final result = <DailyCostData>[];
    for (final dateEntry in dailyDataMap.entries) {
      result.add(DailyCostData.fromEntries(dateEntry.key, dateEntry.value));
    }
    
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }
  
  /// 스택 차트용 데이터 포인트 생성
  Map<String, List<CostDataPoint>> generateStackChartData(
    List<GPUModel> gpuData, 
    DateRange dateRange,
    Set<String> selectedDepartments,
  ) {
    final entries = generateDailyCostEntries(gpuData, dateRange);
    final filteredEntries = entries.where((entry) => 
      selectedDepartments.isEmpty || selectedDepartments.contains(entry.departmentName)
    ).toList();
    
    final aggregated = AggregatedCostData.fromEntries(filteredEntries);
    final stackData = <String, List<CostDataPoint>>{};
    
    // 부서별 데이터 포인트 생성
    for (final department in aggregated.departments) {
      final deptData = aggregated.departmentDaily[department] ?? {};
      final dataPoints = <CostDataPoint>[];
      
      for (final dateEntry in deptData.entries) {
        dataPoints.add(CostDataPoint(
          date: dateEntry.key,
          cost: dateEntry.value,
          department: department,
        ));
      }
      
      dataPoints.sort((a, b) => a.date.compareTo(b.date));
      stackData[department] = dataPoints;
    }
    
    return stackData;
  }
}

/// 필터 상태 관리자
class CostFilterNotifier extends StateNotifier<FilterState> {
  CostFilterNotifier() : super(FilterState.initial());
  
  /// 부서 필터 업데이트
  void updateDepartmentFilter(Set<String> selectedDepartments) {
    state = state.copyWith(selectedDepartments: selectedDepartments);
  }
  
  /// 사용자 필터 업데이트
  void updateUserFilter(Set<String> selectedUsers) {
    state = state.copyWith(selectedUsers: selectedUsers);
  }
  
  /// 날짜 범위 업데이트
  void updateDateRange(DateRange dateRange) {
    state = state.copyWith(dateRange: dateRange);
  }
  
  /// 부서 토글
  void toggleDepartment(String department) {
    final newSelected = Set<String>.from(state.selectedDepartments);
    if (newSelected.contains(department)) {
      newSelected.remove(department);
    } else {
      newSelected.add(department);
    }
    updateDepartmentFilter(newSelected);
  }
  
  /// 사용자 토글
  void toggleUser(String user) {
    final newSelected = Set<String>.from(state.selectedUsers);
    if (newSelected.contains(user)) {
      newSelected.remove(user);
    } else {
      newSelected.add(user);
    }
    updateUserFilter(newSelected);
  }
  
  /// 모든 부서 선택
  void selectAllDepartments(List<String> departments) {
    updateDepartmentFilter(departments.toSet());
  }
  
  /// 모든 부서 해제
  void clearAllDepartments() {
    updateDepartmentFilter(<String>{});
  }
  
  /// 필터 초기화
  void resetFilters() {
    state = FilterState.initial();
  }
}

/// 스택 차트용 데이터 포인트
class CostDataPoint {
  final DateTime date;
  final double cost;
  final String department;
  
  const CostDataPoint({
    required this.date,
    required this.cost,
    required this.department,
  });
}