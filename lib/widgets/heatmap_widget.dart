import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';

import '../models/gpu_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// 히트맵 기간 타입
enum HeatmapPeriod {
  month,
  week,
  day,
}

/// 히트맵 기간 확장
extension HeatmapPeriodExtension on HeatmapPeriod {
  String get displayName {
    switch (this) {
      case HeatmapPeriod.month:
        return '월';
      case HeatmapPeriod.week:
        return '주';
      case HeatmapPeriod.day:
        return '일';
    }
  }
  
  int get periodCount {
    switch (this) {
      case HeatmapPeriod.month:
        return AppConstants.heatmapMonthlyDays;
      case HeatmapPeriod.week:
        return AppConstants.heatmapWeeklyDays;
      case HeatmapPeriod.day:
        return AppConstants.heatmapDailyHours;
    }
  }
  
  List<String> get headers {
    switch (this) {
      case HeatmapPeriod.month:
        return List.generate(31, (i) => '${i + 1}');
      case HeatmapPeriod.week:
        return AppConstants.weekDaysKorean;
      case HeatmapPeriod.day:
        return List.generate(24, (i) => i.toString().padLeft(2, '0'));
    }
  }
}

/// GPU 히트맵 위젯
class GPUHeatmapWidget extends ConsumerStatefulWidget {
  final List<GPUModel> gpuData;
  final HeatmapPeriod initialPeriod;
  final DateTime currentDate;
  final Function(GPUModel)? onGPUTap;
  final Function(GPUModel, int)? onCellTap;
  final VoidCallback? onAnalyzeOptimization;

  const GPUHeatmapWidget({
    super.key,
    required this.gpuData,
    this.initialPeriod = HeatmapPeriod.month,
    required this.currentDate,
    this.onGPUTap,
    this.onCellTap,
    this.onAnalyzeOptimization,
  });

  @override
  ConsumerState<GPUHeatmapWidget> createState() => _GPUHeatmapWidgetState();
}

class _GPUHeatmapWidgetState extends ConsumerState<GPUHeatmapWidget>
    with TickerProviderStateMixin {
  late HeatmapPeriod _currentPeriod;
  late DateTime _currentDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentPeriod = widget.initialPeriod;
    _currentDate = widget.currentDate;
    
    _animationController = AnimationController(
      duration: AppConstants.animationDurationMedium,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sortedGPUs = widget.gpuData.sortedByUtilization();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildHeader(theme),
            
            const SizedBox(height: AppConstants.spacingL),
            
            // 기간 선택 및 네비게이션
            _buildPeriodControls(theme),
            
            const SizedBox(height: AppConstants.spacingL),
            
            // 범례
            _buildLegend(theme),
            
            const SizedBox(height: AppConstants.spacingL),
            
            // 히트맵
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildHeatmap(sortedGPUs, theme),
            ),
            
            const SizedBox(height: AppConstants.spacingL),
            
            // 최적화 분석 버튼
            if (widget.onAnalyzeOptimization != null)
              _buildOptimizationButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.grid_view,
          size: 28,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GPU 사용률 트렌드 (히트맵)',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppConstants.spacingXS),
              Text(
                '시간대별 GPU 사용률을 4단계로 시각화',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodControls(ThemeData theme) {
    return Row(
      children: [
        // 기간 토글 버튼
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: HeatmapPeriod.values.map((period) {
              final isSelected = _currentPeriod == period;
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: Material(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    onTap: () => _changePeriod(period),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingM,
                        vertical: AppConstants.spacingS,
                      ),
                      child: Text(
                        period.displayName,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isSelected 
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected 
                              ? FontWeight.w600 
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        const Spacer(),
        
        // 기간 네비게이션
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _navigatePeriod(-1),
                icon: const Icon(Icons.chevron_left),
                tooltip: '이전 기간',
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                ),
                child: Text(
                  _formatCurrentPeriod(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _navigatePeriod(1),
                icon: const Icon(Icons.chevron_right),
                tooltip: '다음 기간',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        children: [
          Text(
            '범례: ',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Wrap(
              spacing: AppConstants.spacingL,
              runSpacing: AppConstants.spacingS,
              children: [
                _buildLegendItem(
                  '할당안됨: 0%',
                  AppTheme.getUtilizationColor('none', isDark: theme.isDark),
                  theme,
                ),
                _buildLegendItem(
                  '낮음: 1-30%',
                  AppTheme.getUtilizationColor('low'),
                  theme,
                ),
                _buildLegendItem(
                  '보통: 31-70%',
                  AppTheme.getUtilizationColor('medium'),
                  theme,
                ),
                _buildLegendItem(
                  '높음: 71-100%',
                  AppTheme.getUtilizationColor('high'),
                  theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingS),
        Text(
          text,
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }

  Widget _buildHeatmap(List<GPUModel> gpus, ThemeData theme) {
    final headers = _currentPeriod.headers;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: Column(
            children: [
              // 헤더 행
              _buildHeaderRow(headers, theme),
              
              // GPU 데이터 행들
              ...gpus.map((gpu) => _buildGPURow(gpu, headers, theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(List<String> headers, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusM),
        ),
      ),
      child: Row(
        children: [
          // GPU 라벨 헤더
          Container(
            width: 120,
            padding: const EdgeInsets.all(AppConstants.spacingS),
            child: Text(
              'GPU (ID)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 기간 헤더들
          ...headers.map((header) => Container(
            width: AppConstants.heatmapCellSize,
            margin: const EdgeInsets.all(1), // 히트맵 셀과 동일한 마진 적용
            padding: const EdgeInsets.all(AppConstants.spacingXS),
            child: Text(
              header,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildGPURow(GPUModel gpu, List<String> headers, ThemeData theme) {
    final data = _getGPUDataForPeriod(gpu);
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // GPU 라벨
          Container(
            width: 120,
            padding: const EdgeInsets.all(AppConstants.spacingS),
            child: InkWell(
              onTap: () => widget.onGPUTap?.call(gpu),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingS,
                  vertical: AppConstants.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Column(
                  children: [
                    Text(
                      gpu.id,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${gpu.avgUtil}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 데이터 셀들
          ...data.asMap().entries.map((entry) {
            final index = entry.key;
            final utilization = entry.value;
            return _buildHeatmapCell(
              gpu, 
              index, 
              utilization, 
              headers[index], 
              theme,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeatmapCell(
    GPUModel gpu,
    int index,
    int utilization,
    String period,
    ThemeData theme,
  ) {
    final utilizationLevel = _getUtilizationLevel(utilization);
    final color = AppTheme.getUtilizationColor(
      utilizationLevel,
      isDark: theme.isDark,
    );

    return Container(
      width: AppConstants.heatmapCellSize,
      height: 35,
      margin: const EdgeInsets.all(1),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          onTap: () => widget.onCellTap?.call(gpu, index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Center(
              child: Text(
                '■',
                style: TextStyle(
                  color: _getTextColor(color),
                  fontSize: AppConstants.fontSizeS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizationButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            '히트맵 기반 최적화 분석',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          FilledButton.icon(
            onPressed: widget.onAnalyzeOptimization,
            icon: const Icon(Icons.analytics),
            label: const Text('📊 분석 실행'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // 유틸리티 메서드들
  void _changePeriod(HeatmapPeriod period) {
    if (_currentPeriod != period) {
      setState(() {
        _currentPeriod = period;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _navigatePeriod(int direction) {
    setState(() {
      switch (_currentPeriod) {
        case HeatmapPeriod.month:
          _currentDate = DateTime(
            _currentDate.year,
            _currentDate.month + direction,
            1,
          );
          break;
        case HeatmapPeriod.week:
          _currentDate = _currentDate.add(Duration(days: direction * 7));
          break;
        case HeatmapPeriod.day:
          _currentDate = _currentDate.add(Duration(days: direction));
          break;
      }
    });
  }

  String _formatCurrentPeriod() {
    switch (_currentPeriod) {
      case HeatmapPeriod.month:
        return '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}';
      case HeatmapPeriod.week:
        final weekStart = _currentDate.subtract(
          Duration(days: _currentDate.weekday - 1),
        );
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${weekStart.month}/${weekStart.day} ~ ${weekEnd.month}/${weekEnd.day}';
      case HeatmapPeriod.day:
        return '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.day.toString().padLeft(2, '0')}';
    }
  }

  List<int> _getGPUDataForPeriod(GPUModel gpu) {
    switch (_currentPeriod) {
      case HeatmapPeriod.month:
        return gpu.monthlyData;
      case HeatmapPeriod.week:
        return gpu.weeklyData;
      case HeatmapPeriod.day:
        return gpu.dailyData;
    }
  }

  String _getUtilizationLevel(int utilization) {
    if (utilization == 0) return 'none';
    if (utilization <= 30) return 'low';
    if (utilization <= 70) return 'medium';
    return 'high';
  }

  Color _getTextColor(Color backgroundColor) {
    // 배경색의 밝기에 따라 텍스트 색상 결정
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}