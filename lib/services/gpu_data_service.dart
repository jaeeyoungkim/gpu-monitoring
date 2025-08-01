import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gpu_model.dart';
import '../models/department_model.dart';
import '../models/optimization_model.dart';
import '../utils/constants.dart';

/// GPU 데이터 서비스 프로바이더
final gpuDataProvider = FutureProvider<List<GPUModel>>((ref) async {
  final service = GPUDataService();
  return service.generateMockGPUData();
});

/// 부서 데이터 서비스 프로바이더
final departmentDataProvider = FutureProvider<SchedulingData>((ref) async {
  final service = GPUDataService();
  final gpuData = await ref.watch(gpuDataProvider.future);
  return service.generateDepartmentDataFromHeatmap(gpuData);
});

/// 최적화 분석 서비스 프로바이더
final optimizationAnalysisProvider = FutureProvider<HeatmapAnalysis>((ref) async {
  final service = GPUDataService();
  final gpuData = await ref.watch(gpuDataProvider.future);
  return service.analyzeHeatmapForOptimization(gpuData);
});

/// GPU 데이터 서비스 클래스
class GPUDataService {
  final Random _random = Random();

  /// 모의 GPU 데이터 생성 (JavaScript 코드 기반)
  Future<List<GPUModel>> generateMockGPUData() async {
    // 실제 서비스에서는 네트워크 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 800));

    final gpus = <GPUModel>[
      // 할당안됨 (0% utilization)
      GPUModel(
        id: 'Nvidia A100-GPU0',
        name: 'Nvidia A100-GPU0',
        avgUtil: 0,
        isMig: false,
        performance: const GPUPerformance(latency: 0, tps: 0),
        monthlyData: _generateTimeSeriesData(0, 31),
        weeklyData: _generateTimeSeriesData(0, 7),
        dailyData: _generateTimeSeriesData(0, 24),
        departmentName: null,
        userName: null,
      ),
      GPUModel(
        id: 'Nvidia H100-GPU1',
        name: 'Nvidia H100-GPU1',
        avgUtil: 0,
        isMig: false,
        performance: const GPUPerformance(latency: 0, tps: 0),
        monthlyData: _generateTimeSeriesData(0, 31),
        weeklyData: _generateTimeSeriesData(0, 7),
        dailyData: _generateTimeSeriesData(0, 24),
        departmentName: null,
        userName: null,
      ),
      GPUModel(
        id: 'Nvidia A100-GPU2',
        name: 'Nvidia A100-GPU2',
        avgUtil: 0,
        isMig: false,
        performance: const GPUPerformance(latency: 0, tps: 0),
        monthlyData: _generateTimeSeriesData(0, 31),
        weeklyData: _generateTimeSeriesData(0, 7),
        dailyData: _generateTimeSeriesData(0, 24),
        departmentName: null,
        userName: null,
      ),

      // 낮음 (1-30% utilization)
      GPUModel(
        id: 'Nvidia A100-GPU3',
        name: 'Nvidia A100-GPU3',
        avgUtil: 15,
        isMig: false,
        performance: const GPUPerformance(latency: 25, tps: 800),
        monthlyData: _generateTimeSeriesData(15, 31),
        weeklyData: _generateTimeSeriesData(15, 7),
        dailyData: _generateTimeSeriesData(15, 24),
        departmentName: 'AI 연구팀',
        userName: '김개발',
      ),
      GPUModel(
        id: 'Nvidia A100-GPU4',
        name: 'Nvidia A100-GPU4',
        avgUtil: 25,
        isMig: false,
        performance: const GPUPerformance(latency: 40, tps: 650),
        monthlyData: _generateTimeSeriesData(25, 31),
        weeklyData: _generateTimeSeriesData(25, 7),
        dailyData: _generateTimeSeriesData(25, 24),
        departmentName: '데이터 사이언스팀',
        userName: '박분석',
      ),

      // 보통 (31-70% utilization)
      GPUModel(
        id: 'Nvidia H100-GPU5',
        name: 'Nvidia H100-GPU5',
        avgUtil: 35,
        isMig: true,
        migInstances: const [
          MIGInstance(id: 'MIG-1', util: 60),
          MIGInstance(id: 'MIG-2', util: 20),
          MIGInstance(id: 'MIG-3', util: 25),
        ],
        performance: const GPUPerformance(latency: 80, tps: 400),
        monthlyData: _generateTimeSeriesData(35, 31),
        weeklyData: _generateTimeSeriesData(35, 7),
        dailyData: _generateTimeSeriesData(35, 24),
        departmentName: '머신러닝팀',
        userName: '이모델',
      ),
      GPUModel(
        id: 'Nvidia A100-GPU6',
        name: 'Nvidia A100-GPU6',
        avgUtil: 45,
        isMig: false,
        performance: const GPUPerformance(latency: 55, tps: 550),
        monthlyData: _generateTimeSeriesData(45, 31),
        weeklyData: _generateTimeSeriesData(45, 7),
        dailyData: _generateTimeSeriesData(45, 24),
        departmentName: '컴퓨터비전팀',
        userName: '최비전',
      ),
      GPUModel(
        id: 'Nvidia H100-GPU7',
        name: 'Nvidia H100-GPU7',
        avgUtil: 55,
        isMig: true,
        migInstances: const [
          MIGInstance(id: 'MIG-1', util: 90),
          MIGInstance(id: 'MIG-2', util: 40),
          MIGInstance(id: 'MIG-3', util: 35),
        ],
        performance: const GPUPerformance(latency: 120, tps: 350),
        monthlyData: _generateTimeSeriesData(55, 31),
        weeklyData: _generateTimeSeriesData(55, 7),
        dailyData: _generateTimeSeriesData(55, 24),
        departmentName: 'NLP팀',
        userName: '정언어',
      ),
      GPUModel(
        id: 'Nvidia A100-GPU8',
        name: 'Nvidia A100-GPU8',
        avgUtil: 65,
        isMig: false,
        performance: const GPUPerformance(latency: 90, tps: 420),
        monthlyData: _generateTimeSeriesData(65, 31),
        weeklyData: _generateTimeSeriesData(65, 7),
        dailyData: _generateTimeSeriesData(65, 24),
        departmentName: '추천시스템팀',
        userName: '강추천',
      ),

      // 높음 (71-100% utilization)
      GPUModel(
        id: 'Nvidia H100-GPU9',
        name: 'Nvidia H100-GPU9',
        avgUtil: 75,
        isMig: true,
        migInstances: const [
          MIGInstance(id: 'MIG-1', util: 95),
          MIGInstance(id: 'MIG-2', util: 80),
          MIGInstance(id: 'MIG-3', util: 50),
        ],
        performance: const GPUPerformance(latency: 150, tps: 280),
        monthlyData: _generateTimeSeriesData(75, 31),
        weeklyData: _generateTimeSeriesData(75, 7),
        dailyData: _generateTimeSeriesData(75, 24),
        departmentName: '딥러닝팀',
        userName: '신딥러닝',
      ),
      GPUModel(
        id: 'Nvidia A100-GPU10',
        name: 'Nvidia A100-GPU10',
        avgUtil: 85,
        isMig: false,
        performance: const GPUPerformance(latency: 180, tps: 200),
        monthlyData: _generateTimeSeriesData(85, 31),
        weeklyData: _generateTimeSeriesData(85, 7),
        dailyData: _generateTimeSeriesData(85, 24),
        departmentName: '강화학습팀',
        userName: '오강화',
      ),
      GPUModel(
        id: 'Nvidia H100-GPU11',
        name: 'Nvidia H100-GPU11',
        avgUtil: 95,
        isMig: true,
        migInstances: const [
          MIGInstance(id: 'MIG-1', util: 98),
          MIGInstance(id: 'MIG-2', util: 92),
        ],
        performance: const GPUPerformance(latency: 220, tps: 150),
        monthlyData: _generateTimeSeriesData(95, 31),
        weeklyData: _generateTimeSeriesData(95, 7),
        dailyData: _generateTimeSeriesData(95, 24),
        departmentName: '생성AI팀',
        userName: '한생성',
      ),
      GPUModel(
        id: 'Nvidia A100-GPU12',
        name: 'Nvidia A100-GPU12',
        avgUtil: 88,
        isMig: false,
        performance: const GPUPerformance(latency: 200, tps: 180),
        monthlyData: _generateTimeSeriesData(88, 31),
        weeklyData: _generateTimeSeriesData(88, 7),
        dailyData: _generateTimeSeriesData(88, 24),
        departmentName: '로보틱스팀',
        userName: '조로봇',
      ),
    ];

    // 평균 사용률이 낮은 순으로 정렬
    gpus.sort((a, b) => a.avgUtil.compareTo(b.avgUtil));

    return gpus;
  }

  /// 시계열 데이터 생성 (JavaScript 코드 기반)
  List<int> _generateTimeSeriesData(int baseUtil, int periods) {
    final data = <int>[];
    
    for (int i = 0; i < periods; i++) {
      // 할당안됨 상태 (0% utilization)는 항상 0으로 유지
      if (baseUtil == 0) {
        data.add(0);
        continue;
      }

      // 기본 사용률 주변에서 랜덤 변동
      final variation = (_random.nextDouble() - 0.5) * 30;
      var util = (baseUtil + variation).clamp(0.0, 100.0);

      // 특정 시간대에 패턴 추가
      if (periods == 24) { // 일간 데이터
        if (i >= 9 && i <= 17) { // 업무시간
          util = (util + 20).clamp(0.0, 100.0);
        } else if (i >= 22 || i <= 6) { // 야간
          util = (util - 15).clamp(0.0, 100.0);
        }
      }

      data.add(util.round());
    }
    
    return data;
  }

  /// 히트맵 기반 최적화 분석
  Future<HeatmapAnalysis> analyzeHeatmapForOptimization(List<GPUModel> gpuData) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final underutilizedGPUs = gpuData.where((gpu) => gpu.avgUtil <= 30 && gpu.avgUtil > 0).toList();
    final unassignedGPUs = gpuData.where((gpu) => gpu.avgUtil == 0).toList();
    final highUtilGPUs = gpuData.where((gpu) => gpu.avgUtil > 70).toList();

    final opportunities = _identifyOptimizationOpportunities(underutilizedGPUs, unassignedGPUs);

    return HeatmapAnalysis(
      underutilized: underutilizedGPUs,
      unassigned: unassignedGPUs,
      highUtilization: highUtilGPUs,
      optimizationOpportunities: opportunities,
      analyzedAt: DateTime.now(),
    );
  }

  /// 최적화 기회 식별
  List<OptimizationOpportunity> _identifyOptimizationOpportunities(
    List<GPUModel> underutilized,
    List<GPUModel> unassigned,
  ) {
    final opportunities = <OptimizationOpportunity>[];

    // 할당되지 않은 GPU가 있는 경우
    if (unassigned.isNotEmpty) {
      opportunities.add(OptimizationOpportunity(
        type: OptimizationOpportunityType.assignment,
        title: '미할당 GPU 활용',
        description: '${unassigned.length}개의 미할당 GPU를 새로운 워크로드에 할당하여 자원 활용도 향상',
        gpus: unassigned.map((gpu) => gpu.id).toList(),
        potentialSavings: unassigned.length * AppConstants.gpuCostPerUnit,
        priority: OptimizationPriority.high,
        icon: '🎯',
      ));
    }

    // 저활용 GPU가 있는 경우
    if (underutilized.length > 1) {
      opportunities.add(OptimizationOpportunity(
        type: OptimizationOpportunityType.consolidation,
        title: 'GPU 워크로드 통합',
        description: '${underutilized.length}개의 저활용 GPU 워크로드를 통합하여 ${(underutilized.length / 2).floor()}개 GPU 절약 가능',
        gpus: underutilized.map((gpu) => gpu.id).toList(),
        potentialSavings: (underutilized.length / 2).floor() * AppConstants.gpuCostPerUnit,
        priority: OptimizationPriority.medium,
        icon: '🔄',
      ));
    }

    // 모니터링 추천
    opportunities.add(OptimizationOpportunity(
      type: OptimizationOpportunityType.monitoring,
      title: '사용률 모니터링',
      description: '최적화 후 GPU 사용률을 지속적으로 모니터링하여 추가 최적화 기회 발굴',
      gpus: [],
      potentialSavings: 0,
      priority: OptimizationPriority.low,
      icon: '📊',
    ));

    return opportunities;
  }

  /// 히트맵 데이터 기반 부서별 GPU 사용 패턴 데이터 생성
  Future<SchedulingData> generateDepartmentDataFromHeatmap(List<GPUModel> gpuData) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final analysis = await analyzeHeatmapForOptimization(gpuData);
    final underutilizedGPUs = analysis.underutilized;
    final unassignedGPUs = analysis.unassigned;

    // 실제 히트맵 데이터를 기반으로 부서 시나리오 생성
    final availableGPUs = [...underutilizedGPUs, ...unassignedGPUs];
    if (availableGPUs.length < 2) {
      // 충분한 GPU가 없는 경우 기본 GPU 사용
      availableGPUs.addAll(gpuData.take(4));
    }

    final currentScenario = SchedulingScenario(
      departments: [
        DepartmentModel(
          name: 'A 부서',
          gpu: availableGPUs.isNotEmpty ? availableGPUs[0].id : 'GPU-7',
          assignment: '${availableGPUs.isNotEmpty ? availableGPUs[0].id : 'GPU-7'} 전용',
          schedule: const [true, false, true, false, false, false, false],
          utilization: availableGPUs.isNotEmpty ? availableGPUs[0].avgUtil : 15,
          status: DepartmentStatus.allocated,
          heatmapRef: availableGPUs.isNotEmpty ? availableGPUs[0].id : null,
        ),
        DepartmentModel(
          name: 'B 부서',
          gpu: availableGPUs.length > 1 ? availableGPUs[1].id : 'GPU-4',
          assignment: '${availableGPUs.length > 1 ? availableGPUs[1].id : 'GPU-4'} 전용',
          schedule: const [false, true, false, true, false, false, false],
          utilization: availableGPUs.length > 1 ? availableGPUs[1].avgUtil : 25,
          status: DepartmentStatus.allocated,
          heatmapRef: availableGPUs.length > 1 ? availableGPUs[1].id : null,
        ),
        const DepartmentModel(
          name: 'C 부서',
          gpu: 'new',
          assignment: '신규 GPU 요청',
          schedule: [false, false, false, false, true, false, false],
          utilization: 0,
          status: DepartmentStatus.pending,
        ),
        const DepartmentModel(
          name: 'D 부서',
          gpu: 'new',
          assignment: '신규 GPU 요청',
          schedule: [true, true, true, true, true, true, true],
          utilization: 0,
          status: DepartmentStatus.pending,
        ),
      ],
      totalGPUs: 4,
      newGPUsNeeded: 2,
      totalCost: 80000000,
    );

    final optimizedScenario = _generateOptimizedScenario(availableGPUs);

    return SchedulingData(
      current: currentScenario,
      optimized: optimizedScenario,
    );
  }

  /// 최적화된 시나리오 생성
  SchedulingScenario _generateOptimizedScenario(List<GPUModel> availableGPUs) {
    final sharedGPU = availableGPUs.isNotEmpty ? availableGPUs[0] : null;
    final dedicatedGPU = availableGPUs.length > 1 ? availableGPUs[1] : null;

    final departments = [
      DepartmentModel(
        name: 'A 부서',
        gpu: sharedGPU?.id ?? 'GPU-7',
        assignment: '${sharedGPU?.id ?? 'GPU-7'} 공유',
        schedule: const [true, false, true, false, false, false, false],
        utilization: sharedGPU?.avgUtil ?? 15,
        status: DepartmentStatus.optimized,
        heatmapRef: sharedGPU?.id,
      ),
      DepartmentModel(
        name: 'B 부서',
        gpu: sharedGPU?.id ?? 'GPU-7',
        assignment: '${sharedGPU?.id ?? 'GPU-7'} 공유',
        schedule: const [false, true, false, true, false, false, false],
        utilization: sharedGPU?.avgUtil ?? 15,
        status: DepartmentStatus.optimized,
        heatmapRef: sharedGPU?.id,
      ),
      DepartmentModel(
        name: 'C 부서',
        gpu: sharedGPU?.id ?? 'GPU-7',
        assignment: '${sharedGPU?.id ?? 'GPU-7'} 공유',
        schedule: const [false, false, false, false, true, false, false],
        utilization: ((sharedGPU?.avgUtil ?? 15) * 0.5).round(),
        status: DepartmentStatus.optimized,
        heatmapRef: sharedGPU?.id,
      ),
      DepartmentModel(
        name: 'D 부서',
        gpu: dedicatedGPU?.id ?? 'GPU-4',
        assignment: '${dedicatedGPU?.id ?? 'GPU-4'} 전용',
        schedule: const [true, true, true, true, true, true, true],
        utilization: 100,
        status: DepartmentStatus.optimized,
        heatmapRef: dedicatedGPU?.id,
      ),
    ];

    final improvements = <String, GPUImprovement>{};
    if (sharedGPU != null) {
      improvements[sharedGPU.id.toLowerCase()] = GPUImprovement(
        before: sharedGPU.avgUtil,
        after: (sharedGPU.avgUtil + 45).clamp(0, 100),
        improvement: 45,
      );
    }
    if (dedicatedGPU != null) {
      improvements[dedicatedGPU.id.toLowerCase()] = GPUImprovement(
        before: dedicatedGPU.avgUtil,
        after: 100,
        improvement: 100 - dedicatedGPU.avgUtil,
      );
    }

    return SchedulingScenario(
      departments: departments,
      totalGPUs: 2,
      newGPUsNeeded: 0,
      totalCost: 0,
      savings: const OptimizationSavings(
        gpusSaved: 2,
        costSaved: 80000000,
        operationalSavings: 12000000,
        totalSavings: 92000000,
      ),
      improvements: improvements,
    );
  }

  /// 스케줄 충돌 검사
  List<ScheduleConflict> checkScheduleConflicts(List<DepartmentModel> departments) {
    final conflicts = <ScheduleConflict>[];
    final gpuSchedules = <String, List<DepartmentModel>>{};

    // GPU별로 부서들을 그룹화
    for (final dept in departments) {
      if (!gpuSchedules.containsKey(dept.gpu)) {
        gpuSchedules[dept.gpu] = [];
      }
      gpuSchedules[dept.gpu]!.add(dept);
    }

    // 각 GPU별로 스케줄 충돌 검사
    for (final entry in gpuSchedules.entries) {
      final gpu = entry.key;
      final depts = entry.value;

      if (depts.length > 1) {
        for (int day = 0; day < 7; day++) {
          final conflictingDepts = depts
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

  /// 최적화 추천사항 생성
  Future<List<OptimizationRecommendation>> generateOptimizationRecommendations(
    List<GPUModel> gpuData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final analysis = await analyzeHeatmapForOptimization(gpuData);
    final recommendations = <OptimizationRecommendation>[];

    for (final opportunity in analysis.optimizationOpportunities) {
      recommendations.add(OptimizationRecommendation(
        title: opportunity.title,
        description: opportunity.description,
        benefit: opportunity.potentialSavingsFormatted,
        actionItems: _generateActionItems(opportunity),
        priority: opportunity.priority,
        affectedGPUs: opportunity.gpus,
        estimatedSavings: opportunity.potentialSavings,
      ));
    }

    return recommendations;
  }

  /// 액션 아이템 생성
  List<String> _generateActionItems(OptimizationOpportunity opportunity) {
    switch (opportunity.type) {
      case OptimizationOpportunityType.assignment:
        return [
          '미할당 GPU 목록 확인',
          '새로운 워크로드 요구사항 분석',
          'GPU 할당 계획 수립',
          '할당 실행 및 모니터링',
        ];
      case OptimizationOpportunityType.consolidation:
        return [
          '저활용 GPU 워크로드 분석',
          '통합 가능성 검토',
          '워크로드 마이그레이션 계획',
          '통합 실행 및 검증',
        ];
      case OptimizationOpportunityType.monitoring:
        return [
          '모니터링 대시보드 설정',
          '알림 임계값 구성',
          '정기 리포트 생성',
          '최적화 기회 지속 발굴',
        ];
      default:
        return ['상세 분석 수행', '실행 계획 수립', '구현 및 검증'];
    }
  }
}