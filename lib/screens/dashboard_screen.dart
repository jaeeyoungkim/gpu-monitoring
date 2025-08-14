import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gpu_model.dart';
import '../models/department_model.dart';
import '../models/optimization_model.dart';
import '../models/custom_column_model.dart';
import '../models/cloud_instance_model.dart';
import '../widgets/heatmap_widget.dart';
import '../services/gpu_data_service.dart';
import '../services/custom_column_service.dart';
import '../services/cost_calculation_service.dart';
import '../services/daily_cost_service.dart';
import '../models/daily_cost_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

/// 메인 대시보드 화면
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerSlideAnimation;
  
  // 선택된 GPU 추적
  String? _selectedGPUId;
  
  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
    
    _headerAnimationController = AnimationController(
      duration: AppConstants.animationDurationSlow,
      vsync: this,
    );
    
    _headerSlideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gpuDataAsync = ref.watch(gpuDataProvider);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            AnimatedBuilder(
              animation: _headerSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _headerSlideAnimation.value),
                  child: _buildHeader(theme),
                );
              },
            ),
            
            // 탭 바
            _buildTabBar(theme),
            
            // 콘텐츠
            Expanded(
              child: gpuDataAsync.when(
                data: (gpuData) => TabBarView(
                  controller: _tabController,
                  children: [
                    // 인벤토리 관리 탭
                    _buildInventoryTab(gpuData, theme),
                    
                    // GPU 비용 탭
                    _buildCostAnalysisTab(gpuData, theme),
                    
                    // 히트맵 탭
                    _buildHeatmapTab(gpuData, theme),
                    
                    // 최적화 탭
                    _buildOptimizationTab(gpuData, theme),
                  ],
                ),
                loading: () => _buildLoadingState(theme),
                error: (error, stack) => _buildErrorState(error, theme),
              ),
            ),
          ],
        ),
      ),
      
      // 플로팅 액션 버튼
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.15)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  Icons.memory,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      AppConstants.appSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // 새로고침 버튼
              IconButton(
                onPressed: () => ref.refresh(gpuDataProvider),
                icon: Icon(
                  Icons.refresh,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                tooltip: '데이터 새로고침',
              ),
            ],
          ),
          
        ],
      ),
    );
  }

  Widget _buildKPICards(ThemeData theme) {
    final gpuDataAsync = ref.watch(gpuDataProvider);
    
    return gpuDataAsync.when(
      data: (gpuData) {
        final totalGPUs = gpuData.length;
        final activeGPUs = gpuData.activeCount;
        final efficientGPUs = gpuData.efficientCount;
        final avgUtilization = gpuData.averageUtilization;
        
        return Row(
          children: [
            Expanded(
              child: _buildKPICard(
                'Total GPUs',
                totalGPUs.toString(),
                Icons.memory,
                theme.colorScheme.onPrimary,
                theme,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: _buildKPICard(
                'Active',
                activeGPUs.toString(),
                Icons.play_circle_filled,
                theme.colorScheme.onPrimary,
                theme,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: _buildKPICard(
                'Efficient',
                efficientGPUs.toString(),
                Icons.trending_up,
                theme.colorScheme.onPrimary,
                theme,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: _buildKPICard(
                'Avg Util',
                '${avgUtilization.toStringAsFixed(1)}%',
                Icons.analytics,
                theme.colorScheme.onPrimary,
                theme,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 60),
      error: (_, __) => const SizedBox(height: 60),
    );
  }

  Widget _buildKPICard(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(
            icon: Icon(Icons.inventory),
            text: '인벤토리 관리',
          ),
          Tab(
            icon: Icon(Icons.attach_money),
            text: 'GPU 비용',
          ),
          Tab(
            icon: Icon(Icons.grid_view),
            text: 'GPU 히트맵',
          ),
          Tab(
            icon: Icon(Icons.tune),
            text: '스케줄링 최적화',
          ),
        ],
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }

  Widget _buildHeatmapTab(List<GPUModel> gpuData, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        children: [
          // 히트맵 위젯
          GPUHeatmapWidget(
            gpuData: gpuData,
            currentDate: DateTime.now(),
            onGPUTap: _onGPUTap,
            onCellTap: _onHeatmapCellTap,
            onAnalyzeOptimization: _onAnalyzeOptimization,
          ),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // 추가 정보 카드들
          _buildAdditionalInfoCards(gpuData, theme),
        ],
      ),
    );
  }

  Widget _buildOptimizationTab(List<GPUModel> gpuData, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        children: [
          // 최적화 분석 결과
          _buildOptimizationAnalysis(gpuData, theme),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // 스케줄링 시나리오
          _buildSchedulingScenarios(theme),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // 추천사항
          _buildRecommendations(theme),
        ],
      ),
    );
  }

  Widget _buildCostAnalysisTab(List<GPUModel> gpuData, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ' GPU 비용 분석',
                      style: theme.textTheme.headlineMedium,
                    ),
                    Text(
                      '부서별/사용자별 GPU 사용 비용 추이',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // 필터 섹션
          _buildCostFilterSection(gpuData, theme),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // 스택 라인 차트
          _buildStackLineChart(gpuData, theme),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // 비용 요약 카드들
          _buildCostSummaryCards(gpuData, theme),
        ],
      ),
    );
  }

  Widget _buildCostFilterSection(List<GPUModel> gpuData, ThemeData theme) {
    final departments = gpuData
        .where((gpu) => gpu.departmentName != null)
        .map((gpu) => gpu.departmentName!)
        .toSet()
        .toList()
        ..sort();
    
    final users = gpuData
        .where((gpu) => gpu.userName != null)
        .map((gpu) => gpu.userName!)
        .toSet()
        .toList()
        ..sort();

    final filterState = ref.watch(costFilterProvider);
    final filterNotifier = ref.read(costFilterProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '필터',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // 전체 선택/해제 버튼
                TextButton.icon(
                  onPressed: () {
                    if (filterState.selectedDepartments.length == departments.length) {
                      filterNotifier.clearAllDepartments();
                    } else {
                      filterNotifier.selectAllDepartments(departments);
                    }
                  },
                  icon: Icon(
                    filterState.selectedDepartments.length == departments.length
                        ? Icons.deselect
                        : Icons.select_all,
                    size: 16,
                  ),
                  label: Text(
                    filterState.selectedDepartments.length == departments.length
                        ? '전체 해제'
                        : '전체 선택',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    filterNotifier.resetFilters();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text('초기화', style: theme.textTheme.labelSmall),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            Row(
              children: [
                // 부서 필터
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '부서 (${filterState.selectedDepartments.length}/${departments.length})',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 140),
                        padding: const EdgeInsets.all(AppConstants.spacingS),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: departments.map((dept) => CheckboxListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.zero,
                              title: Text(dept, style: theme.textTheme.bodySmall),
                              value: filterState.selectedDepartments.contains(dept),
                              onChanged: (value) {
                                filterNotifier.toggleDepartment(dept);
                              },
                              activeColor: theme.colorScheme.primary,
                            )).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                // 사용자 필터
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '사용자 (${filterState.selectedUsers.length}/${users.length})',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 140),
                        padding: const EdgeInsets.all(AppConstants.spacingS),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: users.map((user) => CheckboxListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.zero,
                              title: Text(user, style: theme.textTheme.bodySmall),
                              value: filterState.selectedUsers.contains(user),
                              onChanged: (value) {
                                filterNotifier.toggleUser(user);
                              },
                              activeColor: theme.colorScheme.secondary,
                            )).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                // 기간 필터
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '기간 필터',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingS),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<DateRangeType>(
                              dense: true,
                              title: Text(' 최근30일', style: theme.textTheme.bodySmall),
                              value: DateRangeType.last30Days,
                              groupValue: filterState.dateRange.type,
                              onChanged: (value) {
                                if (value != null) {
                                  filterNotifier.updateDateRange(DateRange.last30Days());
                                }
                              },
                            ),
                            RadioListTile<DateRangeType>(
                              dense: true,
                              title: Text(' 최근7일', style: theme.textTheme.bodySmall),
                              value: DateRangeType.last7Days,
                              groupValue: filterState.dateRange.type,
                              onChanged: (value) {
                                if (value != null) {
                                  filterNotifier.updateDateRange(DateRange.last7Days());
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            // 현재 필터 상태 표시
            Wrap(
              spacing: AppConstants.spacingS,
              runSpacing: AppConstants.spacingS,
              children: [
                if (filterState.selectedDepartments.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingS,
                      vertical: AppConstants.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      '부서: ${filterState.selectedDepartments.length}개 선택',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                if (filterState.selectedUsers.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingS,
                      vertical: AppConstants.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
                    ),
                    child: Text(
                      '사용자: ${filterState.selectedUsers.length}개 선택',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    border: Border.all(color: theme.colorScheme.tertiary.withOpacity(0.3)),
                  ),
                  child: Text(
                    '기간: ${_getDateRangeLabel(filterState.dateRange)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDateRangeLabel(DateRange dateRange) {
    switch (dateRange.type) {
      case DateRangeType.last30Days:
        return '최근 30일';
      case DateRangeType.last7Days:
        return '최근 7일';
      case DateRangeType.custom:
        return '${dateRange.startDate.month}/${dateRange.startDate.day} - ${dateRange.endDate.month}/${dateRange.endDate.day}';
    }
  }

  Widget _buildStackLineChart(List<GPUModel> gpuData, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '부서별 일별 비용 추이',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.show_chart,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            // 차트 영역
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  final filteredDataAsync = ref.watch(filteredCostDataProvider);
                  final filterState = ref.watch(costFilterProvider);
                  final filterNotifier = ref.read(costFilterProvider.notifier);
                  
                  return filteredDataAsync.when(
                    data: (aggregatedData) => _buildActualStackChart(aggregatedData, filterState, filterNotifier, theme),
                    loading: () => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: AppConstants.spacingM),
                          Text(
                            '비용 데이터 로딩 중...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: AppConstants.spacingM),
                          Text(
                            '데이터 로딩 실패',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          Text(
                            error.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActualStackChart(AggregatedCostData aggregatedData, FilterState filterState, CostFilterNotifier filterNotifier, ThemeData theme) {
    if (aggregatedData.departmentDaily.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.data_usage_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              '표시할 데이터가 없습니다',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '부서를 선택하거나 필터를 조정해 주세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // 부서별 색상 정의
    final departmentColors = <String, Color>{};
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      const Color(0xFFFF9800), // Orange
      const Color(0xFF4CAF50), // Green
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF5722), // Deep Orange
    ];
    
    int colorIndex = 0;
    for (final dept in aggregatedData.departments) {
      departmentColors[dept] = colors[colorIndex % colors.length];
      colorIndex++;
    }

    // 날짜 범위에서 모든 날짜 가져오기
    final allDates = aggregatedData.totalDaily.keys.toList()..sort();
    if (allDates.isEmpty) {
      return Center(
        child: Text(
          '선택된 기간에 데이터가 없습니다',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        children: [
          // 범례 (탭하여 부서 토글)
          Wrap(
            spacing: AppConstants.spacingM,
            runSpacing: AppConstants.spacingS,
            children: aggregatedData.departments.map((dept) {
              final isActive = filterState.selectedDepartments.isEmpty || filterState.selectedDepartments.contains(dept);
              final baseColor = departmentColors[dept]!;
              final legendColor = isActive ? baseColor : baseColor.withOpacity(0.35);
              return InkWell(
                onTap: () {
                  filterNotifier.toggleDepartment(dept);
                },
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: legendColor,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: baseColor.withOpacity(0.6)),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingXS),
                    Text(
                      dept,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isActive
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spacingM),
          // 차트
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: _niceGridIntervalKRW(aggregatedData.totalDaily.values),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: (allDates.length / 6).ceil().toDouble(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < allDates.length) {
                          final date = allDates[index];
                          return Text(
                            '${date.month}/${date.day}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) => Text(
                        _formatKRW(value),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                lineBarsData: _generateStackedLines(aggregatedData, allDates, departmentColors, theme),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final date = allDates[touchedSpot.x.toInt()];
                        final dept = aggregatedData.departments[touchedSpot.barIndex];
                        final cost = touchedSpot.y;
                        
                        return LineTooltipItem(
                          '$dept\n${date.month}/${date.day}: ${_formatKRW(cost)}',
                          TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<LineChartBarData> _generateStackedLines(
    AggregatedCostData aggregatedData,
    List<DateTime> allDates,
    Map<String, Color> departmentColors,
    ThemeData theme,
  ) {
    final lines = <LineChartBarData>[];
    final stackedValues = <int, double>{}; // index -> accumulated value

    for (int deptIndex = 0; deptIndex < aggregatedData.departments.length; deptIndex++) {
      final department = aggregatedData.departments[deptIndex];
      final deptData = aggregatedData.departmentDaily[department] ?? {};
      final spots = <FlSpot>[];

      for (int dateIndex = 0; dateIndex < allDates.length; dateIndex++) {
        final date = allDates[dateIndex];
        final cost = deptData[date] ?? 0;
        final stackedBase = stackedValues[dateIndex] ?? 0;
        
        spots.add(FlSpot(dateIndex.toDouble(), stackedBase + cost));
        stackedValues[dateIndex] = stackedBase + cost;
      }

      lines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: departmentColors[department],
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: departmentColors[department]!.withOpacity(0.18),
          ),
        ),
      );
    }

    // 총합(전체) 오버레이 라인 추가
    final totalSpots = <FlSpot>[];
    for (int dateIndex = 0; dateIndex < allDates.length; dateIndex++) {
      totalSpots.add(FlSpot(dateIndex.toDouble(), (stackedValues[dateIndex] ?? 0)));
    }
    lines.add(
      LineChartBarData(
        spots: totalSpots,
        isCurved: true,
        color: theme.colorScheme.onSurface.withOpacity(0.85),
        barWidth: 2.6,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ),
    );

    return lines;
  }

  double _calculateGridInterval(Iterable<double> values) {
    if (values.isEmpty) return 100;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 100) return 20;
    if (maxValue <= 500) return 100;
    if (maxValue <= 1000) return 200;
    if (maxValue <= 5000) return 1000;
    return 2000;
  }

  // KRW 축에 어울리는 "nice" 간격 계산 (1-2-5 스텝)
  double _niceGridIntervalKRW(Iterable<double> values) {
    if (values.isEmpty) return 1000;
    final maxValue = values.reduce((a, b) => a > b ? a : b).abs();
    if (maxValue == 0) return 1000;

    // 목표 그리드 라인 개수
    const targetLines = 6;
    final rough = maxValue / targetLines;

    final magnitude = math.pow(10, (math.log(rough) / math.ln10).floor());
    final residual = rough / magnitude;

    double niceResidual;
    if (residual < 1.5) {
      niceResidual = 1;
    } else if (residual < 3) {
      niceResidual = 2;
    } else if (residual < 7) {
      niceResidual = 5;
    } else {
      niceResidual = 10;
    }

    final step = niceResidual * magnitude;

    // 최소 1,000원 단위 이상으로 표시 (축 눈금 가독성)
    final minStep = 1000.0;
    return step < minStep ? minStep : step;
  }

  Widget _buildCostSummaryCards(List<GPUModel> gpuData, ThemeData theme) {
    final gpusWithCost = gpuData.where((gpu) => gpu.cloudMetadata != null);
    final totalHourlyRate = gpusWithCost.fold<double>(
      0, (sum, gpu) => sum + gpu.cloudMetadata!.hourlyRate);
    final totalMonthlyRate = totalHourlyRate * 720;
    final activeGpuCount = gpuData.where((gpu) => gpu.avgUtil > 0).length;
    final totalGpuCount = gpuData.length;
    final avgDailyCost = totalHourlyRate * 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '비용 요약 카드',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildCostSummaryCard(
                '총 월 비용',
                _formatKRW(totalMonthlyRate),
                '720시간 기준',
                Icons.calendar_month,
                theme.colorScheme.primary,
                theme,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: _buildCostSummaryCard(
                '일 평균 비용',
                _formatKRW(avgDailyCost),
                '24시간 기준',
                Icons.today,
                theme.colorScheme.secondary,
                theme,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: _buildCostSummaryCard(
                '활성 GPU',
                '$activeGpuCount/$totalGpuCount',
                '사용률 > 0%',
                Icons.power,
                theme.colorScheme.tertiary,
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCostSummaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTab(List<GPUModel> gpuData, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                Icons.inventory,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GPU 인벤토리 관리',
                      style: theme.textTheme.headlineMedium,
                    ),
                    Text(
                      '부서별 GPU 할당 및 사용자 관리',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // 통계 카드들
          _buildInventoryStats(gpuData, theme),
          
          const SizedBox(height: AppConstants.spacingL),
          
          // GPU 목록
          _buildGPUInventoryList(gpuData, theme),
        ],
      ),
    );
  }

  Widget _buildInventoryStats(List<GPUModel> gpuData, ThemeData theme) {
    final totalGPUs = gpuData.length;
    final assignedGPUs = gpuData.where((gpu) => gpu.departmentName != null).length;
    final unassignedGPUs = totalGPUs - assignedGPUs;
    final departments = gpuData
        .where((gpu) => gpu.departmentName != null)
        .map((gpu) => gpu.departmentName!)
        .toSet()
        .length;
    

    return Row(
      children: [
        Expanded(
          child: _buildInventoryStatCard(
            '전체 GPU',
            totalGPUs.toString(),
            Icons.memory,
            theme.colorScheme.primary,
            theme,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _buildInventoryStatCard(
            '할당된 GPU',
            assignedGPUs.toString(),
            Icons.assignment_turned_in,
            theme.colorScheme.secondary,
            theme,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _buildInventoryStatCard(
            '미할당 GPU',
            unassignedGPUs.toString(),
            Icons.assignment_late,
            theme.colorScheme.tertiary,
            theme,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _buildInventoryStatCard(
            '활성 부서',
            departments.toString(),
            Icons.business,
            theme.colorScheme.outline,
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGPUInventoryList(List<GPUModel> gpuData, ThemeData theme) {
    final customColumns = ref.watch(customColumnProvider);
    final visibleCustomColumns = customColumns.where((col) => col.isVisible).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더와 컬럼 관리 버튼
            Row(
              children: [
                Expanded(
                  child: Text(
                    'GPU 할당 현황',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showColumnManagementDialog(theme),
                  icon: const Icon(Icons.view_column),
                  tooltip: '컬럼 관리',
                ),
                IconButton(
                  onPressed: () => _showAddColumnDialog(theme),
                  icon: const Icon(Icons.add),
                  tooltip: '컬럼 추가',
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            
            // 수평 스크롤 가능한 테이블
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Column(
                  children: [
                    // 테이블 헤더
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppConstants.radiusM),
                        ),
                      ),
                      child: Row(
                        children: [
                          // 기본 컬럼들
                          SizedBox(
                            width: 150,
                            child: Text(
                              'GPU 이름',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              '부서명',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              '사용자명',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              '사용률',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          // 클라우드 비용 정보 컬럼들
                          SizedBox(
                            width: 120,
                            child: Text(
                              '인스턴스 타입',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              'GPU 타입',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              '시간당 단가',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          // 커스텀 컬럼들
                          ...visibleCustomColumns.map((column) => SizedBox(
                            width: 120,
                            child: Text(
                              column.name,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )),
                          
                          const SizedBox(width: 60), // 액션 버튼 공간
                        ],
                      ),
                    ),
                    
                    // GPU 목록
                    ...gpuData.map((gpu) => _buildGPUInventoryRow(gpu, theme, visibleCustomColumns)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGPUInventoryRow(GPUModel gpu, ThemeData theme, List<CustomColumnModel> visibleCustomColumns) {
    final customDataNotifier = ref.read(gpuCustomDataProvider.notifier);
    final isSelected = _selectedGPUId == gpu.id;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: isSelected 
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 0.5,
          ),
          left: isSelected 
              ? BorderSide(
                  color: theme.colorScheme.primary,
                  width: 4,
                )
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          // GPU 이름
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gpu.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  gpu.id,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // 부서명
          SizedBox(
            width: 120,
            child: Text(
              gpu.departmentName ?? '미할당',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: gpu.departmentName != null 
                    ? theme.colorScheme.onSurface 
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          
          // 사용자명
          SizedBox(
            width: 120,
            child: Text(
              gpu.userName ?? '미할당',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: gpu.userName != null 
                    ? theme.colorScheme.onSurface 
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          
          // 사용률
          SizedBox(
            width: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingS,
                vertical: AppConstants.spacingXS,
              ),
              decoration: BoxDecoration(
                color: _getUtilizationColor(gpu.avgUtil, theme),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Text(
                '${gpu.avgUtil}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // 클라우드 비용 정보 컬럼들
          // 인스턴스 타입
          SizedBox(
            width: 120,
            child: Text(
              gpu.instanceType ?? '-',
              style: theme.textTheme.bodySmall?.copyWith(
                color: gpu.cloudMetadata != null 
                    ? theme.colorScheme.onSurface 
                    : theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // GPU 타입 (하드웨어)
          SizedBox(
            width: 100,
            child: Text(
              gpu.hardwareGpuType ?? '-',
              style: theme.textTheme.bodySmall?.copyWith(
                color: gpu.cloudMetadata != null 
                    ? theme.colorScheme.onSurface 
                    : theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 시간당 단가
          SizedBox(
            width: 120,
            child: gpu.costPerHour != null 
                ? Text(
                    _formatHourlyRateKRW(gpu.costPerHour!),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    '-',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          
          // 커스텀 컬럼들
          ...visibleCustomColumns.map((column) {
            final value = customDataNotifier.getGPUCustomValue(gpu.id, column.id);
            return SizedBox(
              width: 120,
              child: _buildCustomColumnCell(gpu.id, column, value, theme),
            );
          }),
          
          const SizedBox(width: AppConstants.spacingM),
          IconButton(
            onPressed: () => _showEditAssignmentDialog(gpu),
            icon: const Icon(Icons.edit),
            tooltip: '할당 편집',
          ),
        ],
      ),
    );
  }

  Color _getUtilizationColor(int utilization, ThemeData theme) {
    if (utilization == 0) return theme.colorScheme.outline;
    if (utilization <= 30) return theme.colorScheme.error;
    if (utilization <= 70) return theme.colorScheme.tertiary;
    return theme.colorScheme.primary;
  }

  /// KRW 통화 포맷팅 헬퍼 함수
  String _formatKRW(double amount) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '₩${formatter.format(amount.round())}';
  }

  /// 시간당 단가 전용 포맷팅 (천단위로 표시)
  String _formatHourlyRateKRW(double amount) {
    if (amount >= 1000) {
      final thousands = amount / 1000;
      if (thousands == thousands.round()) {
        return '₩${thousands.round()}천';
      } else {
        return '₩${thousands.toStringAsFixed(1)}천';
      }
    } else {
      return '₩${amount.round()}';
    }
  }

  Color _getCostColor(double monthlyCost, ThemeData theme) {
    // KRW 기준으로 색상 기준 조정 (기존 USD * 1300)
    if (monthlyCost <= 650000) return const Color(0xFF4CAF50); // Green for low cost
    if (monthlyCost <= 2600000) return const Color(0xFFFF9800); // Orange for medium cost
    return const Color(0xFFF44336); // Red for high cost
  }



  Widget _buildCostOverviewCards(List<GPUModel> gpuData, ThemeData theme) {
    final gpusWithCost = gpuData.where((gpu) => gpu.cloudMetadata != null);
    final totalHourlyRate = gpusWithCost.fold<double>(
      0, (sum, gpu) => sum + gpu.cloudMetadata!.hourlyRate);
    final totalMonthlyRate = totalHourlyRate * 720;
    final activeGpuCount = gpuData.where((gpu) => gpu.avgUtil > 0).length;
    final totalGpuCount = gpuData.length;

    return Row(
      children: [
        Expanded(
          child: _buildCostOverviewCard(
            '총 시간당 비용',
            _formatKRW(totalHourlyRate),
            '모든 인스턴스 합계',
            Icons.schedule,
            theme.colorScheme.primary,
            theme,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _buildCostOverviewCard(
            '예상 월 비용',
            _formatKRW(totalMonthlyRate),
            '720시간 기준',
            Icons.calendar_month,
            theme.colorScheme.secondary,
            theme,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _buildCostOverviewCard(
            '활성 GPU',
            '$activeGpuCount / $totalGpuCount',
            '사용률 > 0%',
            Icons.power,
            theme.colorScheme.tertiary,
            theme,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _buildCostOverviewCard(
            '평균 GPU당 시간당',
            gpusWithCost.isNotEmpty 
                ? _formatKRW(totalHourlyRate / gpusWithCost.fold<int>(0, (sum, gpu) => sum + gpu.cloudMetadata!.gpuCount))
                : '-',
            'GPU 단위 평균',
            Icons.memory,
            const Color(0xFFFF9800),
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildCostOverviewCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstancePricingTable(ThemeData theme) {
    final costService = CostCalculationService();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AWS 인스턴스 요금표',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'GPU 1장당 1시간 사용 시 평균 비용',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  theme.colorScheme.surfaceVariant.withOpacity(0.5),
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      'GPU 타입',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      '인스턴스',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'GPU 개수',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      '시간당 전체',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'GPU당 시간당',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'GPU당 월간',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    numeric: true,
                  ),
                ],
                rows: costService.allAWSPricing.values.map((instance) {
                  return DataRow(
                    cells: [
                      DataCell(Text(instance.gpuTypeKoreanName)),
                      DataCell(Text(instance.instanceType)),
                      DataCell(Text(instance.gpuCount.toString())),
                      DataCell(Text(_formatKRW(instance.hourlyRate))),
                      DataCell(
                        Text(
                          _formatKRW(instance.costPerGPUPerHour),
                          style: TextStyle(
                            color: _getCostColor(instance.costPerGPUPerHour * 720, theme),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          _formatKRW(instance.monthlyCostPerGPU),
                          style: TextStyle(
                            color: _getCostColor(instance.monthlyCostPerGPU, theme),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCostBreakdown(List<GPUModel> gpuData, ThemeData theme) {
    final userGpus = gpuData.where((gpu) => 
        gpu.userName != null && gpu.cloudMetadata != null).toList();
    
    if (userGpus.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '사용자별 비용 상세',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              '개별 사용자의 GPU 사용 비용 계산 과정',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            
            ...userGpus.map((gpu) {
              final hourlyRate = gpu.cloudMetadata!.costPerGPUPerHour;
              final monthlyRate = gpu.cloudMetadata!.monthlyCostPerGPU;
              final utilizationHours = (gpu.avgUtil / 100) * 720; // 한달 예상 사용 시간
              final actualMonthlyCost = hourlyRate * utilizationHours;
              
              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${gpu.userName} (${gpu.departmentName})',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                gpu.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                            vertical: AppConstants.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          ),
                          child: Text(
                            '${_formatKRW(actualMonthlyCost)}/월',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.spacingM),
                    
                    // 비용 계산 과정
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 비용 계산 과정:',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingS),
                          Text(
                            '1. AWS ${gpu.cloudMetadata!.instanceType} 인스턴스의 ${gpu.hardwareGpuType} GPU',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '2. GPU 1장당 시간당 비용: ${_formatKRW(hourlyRate)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '3. ${gpu.userName}의 평균 사용률: ${gpu.avgUtil}%',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '4. 월 예상 사용 시간: ${utilizationHours.toStringAsFixed(0)}시간 (720시간 × ${gpu.avgUtil}%)',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '5. 실제 월 비용: ${_formatKRW(hourlyRate)} × ${utilizationHours.toStringAsFixed(0)}시간 = ${_formatKRW(actualMonthlyCost)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentCostSummary(List<GPUModel> gpuData, ThemeData theme) {
    final departmentCosts = <String, List<GPUModel>>{};
    
    for (final gpu in gpuData) {
      if (gpu.departmentName != null && gpu.cloudMetadata != null) {
        departmentCosts.putIfAbsent(gpu.departmentName!, () => []).add(gpu);
      }
    }
    
    if (departmentCosts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '부서별 비용 집계',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              '부서별 GPU 사용 비용 요약',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            
            ...departmentCosts.entries.map((entry) {
              final department = entry.key;
              final gpus = entry.value;
              final totalMonthlyCost = gpus.fold<double>(0, (sum, gpu) {
                final hourlyRate = gpu.cloudMetadata!.costPerGPUPerHour;
                final utilizationHours = (gpu.avgUtil / 100) * 720;
                return sum + (hourlyRate * utilizationHours);
              });
              
              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            department,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'GPU ${gpus.length}개 사용중',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingS),
                          Text(
                            '사용자: ${gpus.map((g) => g.userName).where((u) => u != null).toSet().join(', ')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingL,
                        vertical: AppConstants.spacingM,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _formatKRW(totalMonthlyCost),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '월 예상 비용',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// 커스텀 컬럼 셀 빌드
  Widget _buildCustomColumnCell(String gpuId, CustomColumnModel column, dynamic value, ThemeData theme) {
    switch (column.type) {
      case CustomColumnType.text:
        return Text(
          value?.toString() ?? '-',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case CustomColumnType.number:
        return Text(
          value?.toString() ?? '-',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case CustomColumnType.dropdown:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingS,
            vertical: AppConstants.spacingXS,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          child: Text(
            value?.toString() ?? '-',
            style: theme.textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        );
      case CustomColumnType.date:
        return Text(
          value?.toString() ?? '-',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case CustomColumnType.boolean:
        return Icon(
          value == true ? Icons.check_circle : Icons.cancel,
          color: value == true ? theme.colorScheme.primary : theme.colorScheme.outline,
          size: 20,
        );
    }
  }

  /// 컬럼 관리 다이얼로그
  void _showColumnManagementDialog(ThemeData theme) {
    final customColumns = ref.read(customColumnProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('컬럼 관리'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView.builder(
            itemCount: customColumns.length,
            itemBuilder: (context, index) {
              final column = customColumns[index];
              return ListTile(
                leading: Text(column.typeIcon),
                title: Text(column.name),
                subtitle: Text(column.typeText),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: column.isVisible,
                      onChanged: (value) {
                        ref.read(customColumnProvider.notifier).toggleColumnVisibility(column.id);
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        ref.read(customColumnProvider.notifier).removeColumn(column.id);
                      },
                      icon: const Icon(Icons.delete),
                      iconSize: 20,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  /// 컬럼 추가 다이얼로그
  void _showAddColumnDialog(ThemeData theme) {
    final nameController = TextEditingController();
    CustomColumnType selectedType = CustomColumnType.text;
    final dropdownOptionsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('새 컬럼 추가'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '컬럼 이름',
                    hintText: '예: 프로젝트 코드',
                  ),
                ),
                const SizedBox(height: AppConstants.spacingM),
                DropdownButtonFormField<CustomColumnType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: '컬럼 타입',
                  ),
                  items: CustomColumnType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Text(_getTypeIcon(type)),
                          const SizedBox(width: AppConstants.spacingS),
                          Text(_getTypeText(type)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                if (selectedType == CustomColumnType.dropdown) ...[
                  const SizedBox(height: AppConstants.spacingM),
                  TextField(
                    controller: dropdownOptionsController,
                    decoration: const InputDecoration(
                      labelText: '드롭다운 옵션',
                      hintText: '옵션1,옵션2,옵션3',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final customColumns = ref.read(customColumnProvider);
                  final newColumn = CustomColumnModel(
                    id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    type: selectedType,
                    order: customColumns.length + 1,
                    dropdownOptions: selectedType == CustomColumnType.dropdown
                        ? dropdownOptionsController.text.split(',').map((e) => e.trim()).toList()
                        : null,
                  );
                  
                  ref.read(customColumnProvider.notifier).addColumn(newColumn);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  /// 타입별 아이콘 가져오기
  String _getTypeIcon(CustomColumnType type) {
    switch (type) {
      case CustomColumnType.text:
        return '📝';
      case CustomColumnType.number:
        return '🔢';
      case CustomColumnType.dropdown:
        return '📋';
      case CustomColumnType.date:
        return '📅';
      case CustomColumnType.boolean:
        return '☑️';
    }
  }

  /// 타입별 텍스트 가져오기
  String _getTypeText(CustomColumnType type) {
    switch (type) {
      case CustomColumnType.text:
        return '텍스트';
      case CustomColumnType.number:
        return '숫자';
      case CustomColumnType.dropdown:
        return '드롭다운';
      case CustomColumnType.date:
        return '날짜';
      case CustomColumnType.boolean:
        return '체크박스';
    }
  }

  void _showEditAssignmentDialog(GPUModel gpu) {
    // TODO: 할당 편집 다이얼로그 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${gpu.name} 할당 편집 (구현 예정)'),
        action: SnackBarAction(
          label: '확인',
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCards(List<GPUModel> gpuData, ThemeData theme) {
    final unassignedGPUs = gpuData.filterByUtilizationLevel(UtilizationLevel.none);
    final underutilizedGPUs = gpuData.filterByUtilizationLevel(UtilizationLevel.low);
    final highUtilGPUs = gpuData.filterByUtilizationLevel(UtilizationLevel.high);
    
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            '미할당 GPU',
            unassignedGPUs.length.toString(),
            '활용 가능한 GPU 자원',
            theme.colorScheme.surfaceVariant,
            theme,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _buildInfoCard(
            '저활용 GPU',
            underutilizedGPUs.length.toString(),
            '최적화 기회',
            theme.colorScheme.tertiaryContainer,
            theme,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _buildInfoCard(
            '고활용 GPU',
            highUtilGPUs.length.toString(),
            '효율적 사용 중',
            theme.colorScheme.primaryContainer,
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    String subtitle,
    Color backgroundColor,
    ThemeData theme,
  ) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationAnalysis(List<GPUModel> gpuData, ThemeData theme) {
    final optimizationAsync = ref.watch(optimizationAnalysisProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.spacingM),
                Text(
                  '히트맵 기반 최적화 분석',
                  style: theme.textTheme.headlineMedium,
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.spacingL),
            
            optimizationAsync.when(
              data: (analysis) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '미할당 GPU ${analysis.unassigned.length}개, 저활용 GPU ${analysis.underutilized.length}개, 고활용 GPU ${analysis.highUtilization.length}개 발견',
                    style: theme.textTheme.bodyLarge,
                  ),
                  
                  const SizedBox(height: AppConstants.spacingM),
                  
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.savings,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppConstants.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '총 절약 가능액: ${analysis.totalPotentialSavingsFormatted}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${analysis.totalOpportunities}개의 최적화 기회 발견',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.spacingL),
                  
                  // 최적화 기회 목록
                  ...analysis.optimizationOpportunities.take(3).map((opportunity) => 
                    _buildOptimizationOpportunityCard(opportunity, theme)
                  ),
                ],
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Text(
                '분석 중 오류가 발생했습니다: $error',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationOpportunityCard(OptimizationOpportunity opportunity, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingS),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Text(
              opportunity.displayIcon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        opportunity.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingS,
                        vertical: AppConstants.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(opportunity.priority, theme),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Text(
                        opportunity.priorityText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  opportunity.description,
                  style: theme.textTheme.bodyMedium,
                ),
                if (opportunity.gpus.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    'GPU: ${opportunity.gpusText}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppConstants.spacingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    '절약 가능: ${opportunity.potentialSavingsFormatted}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(OptimizationPriority priority, ThemeData theme) {
    switch (priority) {
      case OptimizationPriority.critical:
        return theme.colorScheme.error;
      case OptimizationPriority.high:
        return Colors.orange;
      case OptimizationPriority.medium:
        return theme.colorScheme.tertiary;
      case OptimizationPriority.low:
        return theme.colorScheme.outline;
    }
  }

  Widget _buildSchedulingScenarios(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GPU 스케줄링 시나리오',
                        style: theme.textTheme.headlineMedium,
                      ),
                      Text(
                        '예산 최적화를 위한 GPU 자원 공유 및 재할당 방안',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),
            
            // 현재 상황 섹션
            _buildCurrentSituationSection(theme),
            
            const SizedBox(height: AppConstants.spacingL),
            
            // 최적화 솔루션 섹션
            _buildOptimizationSolutionSection(theme),
            
            const SizedBox(height: AppConstants.spacingL),
            
            // 비용 절감 효과 섹션
            _buildCostSavingsSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSituationSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                '현재 문제 상황',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildDepartmentRequirement('C 부서', '1주일에 한번 (금요일)', '예측 작업', '새로운 GPU 요청', theme),
          const SizedBox(height: AppConstants.spacingS),
          _buildDepartmentRequirement('D 부서', '7일 내내', 'Inference 작업', '새로운 GPU 요청', theme),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            '현재 GPU 사용 현황:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          _buildCurrentGPUUsage('GPU-xxxx', 'A 부서', '월, 수', theme),
          const SizedBox(height: AppConstants.spacingXS),
          _buildCurrentGPUUsage('GPU-yyyy', 'B 부서', '화, 목', theme),
        ],
      ),
    );
  }

  Widget _buildOptimizationSolutionSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                '최적화 솔루션',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildSolutionStep('1', 'GPU-xxxx를 A, B, C 부서가 공유', '월(A), 화(B), 수(A), 목(B), 금(C)', theme),
          const SizedBox(height: AppConstants.spacingS),
          _buildSolutionStep('2', 'GPU-yyyy를 D 부서에게 할당', '7일 내내 Inference 작업 전용', theme),
          const SizedBox(height: AppConstants.spacingM),
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: AppConstants.spacingS),
                Expanded(
                  child: Text(
                    '결과: 기존 2장의 GPU로 모든 부서의 요구사항 충족',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSavingsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.savings,
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                '예상 비용 절감 효과',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildSavingsCard('GPU 구매 비용 절약', '₩160M', '2장 × ₩80M', theme),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: _buildSavingsCard('운영 비용 절약', '₩24M/년', '전력, 냉각, 유지보수', theme),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Column(
              children: [
                Text(
                  '총 절약 효과',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  '₩184M',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '(첫 해 기준)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentRequirement(String department, String schedule, String workType, String request, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppConstants.spacingS),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$department: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: '$schedule $workType 필요 → '),
                TextSpan(
                  text: request,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentGPUUsage(String gpuId, String department, String schedule, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppConstants.spacingS),
        Text(
          '$gpuId ($department) - $schedule 사용',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSolutionStep(String stepNumber, String title, String description, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingXS),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsCard(String title, String amount, String description, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            amount,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXS),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(ThemeData theme) {
    final optimizationAsync = ref.watch(optimizationAnalysisProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.spacingM),
                Text(
                  '최적화 추천사항',
                  style: theme.textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),
            
            optimizationAsync.when(
              data: (analysis) {
                final highPriorityOpportunities = analysis.highPriorityOpportunities;
                
                if (highPriorityOpportunities.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: AppConstants.spacingM),
                        Text(
                          '현재 GPU 사용률이 최적화되어 있습니다',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spacingS),
                        Text(
                          '추가 최적화 기회가 발견되면 알려드리겠습니다',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: [
                    Text(
                      '${highPriorityOpportunities.length}개의 우선순위 높은 최적화 기회',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                    
                    ...highPriorityOpportunities.map((opportunity) => 
                      _buildRecommendationItem(
                        opportunity.displayIcon,
                        opportunity.title,
                        opportunity.description,
                        '${opportunity.potentialSavingsFormatted} 절약 가능',
                        theme,
                        priority: opportunity.priority,
                      )
                    ),
                    
                    if (analysis.optimizationOpportunities.length > highPriorityOpportunities.length) ...[
                      const SizedBox(height: AppConstants.spacingM),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: 전체 최적화 기회 보기 화면으로 이동
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          '${analysis.optimizationOpportunities.length - highPriorityOpportunities.length}개 추가 기회 보기',
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Text(
                  '추천사항을 불러오는 중 오류가 발생했습니다: $error',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(
    String icon,
    String title,
    String description,
    String benefit,
    ThemeData theme, {
    OptimizationPriority? priority,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    benefit,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            'GPU 데이터를 불러오는 중...',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            '데이터를 불러올 수 없습니다',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            error.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingL),
          FilledButton.icon(
            onPressed: () => ref.refresh(gpuDataProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: _onAnalyzeOptimization,
      icon: const Icon(Icons.analytics),
      label: const Text('분석 실행'),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
    );
  }

  // 이벤트 핸들러들
  void _onGPUTap(GPUModel gpu) {
    // 선택된 GPU 설정 및 인벤토리 탭으로 이동
    setState(() {
      _selectedGPUId = gpu.id;
    });
    
    // 인벤토리 관리 탭으로 전환 (첫 번째 탭)
    _tabController.animateTo(0);
    
    // 사용자에게 피드백 제공
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${gpu.name}을(를) 인벤토리에서 확인하세요'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: '확인',
          onPressed: () {},
        ),
      ),
    );
  }

  void _onHeatmapCellTap(GPUModel gpu, int index) {
    // 히트맵 셀 상세 정보
    final period = _tabController.index == 0 ? '시간' : '기간';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${gpu.id} - $period $index: ${gpu.avgUtil}%'),
      ),
    );
  }

  void _onAnalyzeOptimization() {
    // 최적화 분석 실행
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 최적화 분석을 실행 중입니다...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // 최적화 탭으로 전환 (세 번째 탭, 인덱스 2)
    _tabController.animateTo(2);
  }
}