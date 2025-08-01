import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gpu_model.dart';
import '../models/department_model.dart';
import '../models/optimization_model.dart';
import '../models/custom_column_model.dart';
import '../widgets/heatmap_widget.dart';
import '../services/gpu_data_service.dart';
import '../services/custom_column_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

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
    
    _tabController = TabController(length: 3, vsync: this);
    
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
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  Icons.memory,
                  size: 32,
                  color: theme.colorScheme.onPrimary,
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
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      AppConstants.appSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.9),
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
                  color: theme.colorScheme.onPrimary,
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
        tabs: const [
          Tab(
            icon: Icon(Icons.inventory),
            text: '인벤토리 관리',
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
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
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
            Text(
              'GPU 스케줄링 시나리오',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              '부서별 GPU 공유 및 재할당을 통한 최적화 방안',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            
            // 시나리오 구현은 다음 단계에서...
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Center(
                child: Text(
                  '스케줄링 시나리오 위젯\n(다음 단계에서 구현)',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
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