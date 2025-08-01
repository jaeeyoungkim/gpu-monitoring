import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 상수들
class AppConstants {
  // 앱 정보
  static const String appTitle = 'WhaTap GPU 통합 모니터링 대시보드';
  static const String appSubtitle = '비효율적인 GPU 자원 활용 문제 해결을 위한 통합 모니터링 환경';
  static const String appVersion = '3.0.0';
  
  // 색상 상수
  static const Color primaryColor = Color(0xFF667EEA);
  static const Color secondaryColor = Color(0xFF764BA2);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  
  // GPU 사용률 레벨별 색상
  static const Color utilizationNoneColor = Color(0xFFF5F5F5);
  static const Color utilizationLowColor = Color(0xFFF44336);
  static const Color utilizationMediumColor = Color(0xFFFF9800);
  static const Color utilizationHighColor = Color(0xFF2196F3);
  
  // 간격 상수
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // 반지름 상수
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  
  // 폰트 크기 상수
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeading = 28.0;
  
  // 애니메이션 지속시간
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  // 히트맵 관련 상수
  static const int heatmapMonthlyDays = 31;
  static const int heatmapWeeklyDays = 7;
  static const int heatmapDailyHours = 24;
  static const double heatmapCellSize = 40.0;
  static const double heatmapCellSpacing = 2.0;
  
  // GPU 관련 상수
  static const int gpuCostPerUnit = 40000000; // ₩40M per GPU
  static const int operationalCostPerYear = 12000000; // ₩12M per year
  
  // 브레이크포인트 (반응형 디자인)
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;
  
  // 요일 텍스트 (한국어)
  static const List<String> weekDaysKorean = ['월', '화', '수', '목', '금', '토', '일'];
  static const List<String> weekDaysEnglish = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  // 사용률 레벨 텍스트
  static const Map<String, String> utilizationLevelTexts = {
    'none': '할당안됨',
    'low': '낮음',
    'medium': '보통',
    'high': '높음',
  };
  
  // 사용률 범위 텍스트
  static const Map<String, String> utilizationRangeTexts = {
    'none': '0%',
    'low': '1-30%',
    'medium': '31-70%',
    'high': '71-100%',
  };
  
  // 부서 상태 텍스트
  static const Map<String, String> departmentStatusTexts = {
    'allocated': '할당됨',
    'pending': '대기중',
    'optimized': '최적화됨',
  };
  
  // 최적화 우선순위 텍스트
  static const Map<String, String> optimizationPriorityTexts = {
    'low': '낮음',
    'medium': '보통',
    'high': '높음',
    'critical': '긴급',
  };
  
  // API 관련 상수 (향후 확장용)
  static const String apiBaseUrl = 'https://api.whatap.io';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // 로컬 스토리지 키
  static const String storageKeyThemeMode = 'theme_mode';
  static const String storageKeyLastRefresh = 'last_refresh';
  static const String storageKeyUserPreferences = 'user_preferences';
}

/// 반응형 디자인을 위한 화면 크기 유틸리티
class ScreenSize {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.breakpointMobile;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.breakpointMobile && width < AppConstants.breakpointDesktop;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.breakpointDesktop;
  }
  
  static double getResponsiveWidth(BuildContext context, {
    double mobile = 1.0,
    double tablet = 0.8,
    double desktop = 0.6,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return screenWidth * mobile;
    } else if (isTablet(context)) {
      return screenWidth * tablet;
    } else {
      return screenWidth * desktop;
    }
  }
  
  static int getResponsiveColumns(BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }
}

/// 비용 포맷팅 유틸리티
class CostFormatter {
  static String formatCost(int cost) {
    if (cost >= 1000000000) {
      return '₩${(cost / 1000000000).toStringAsFixed(1)}B';
    } else if (cost >= 1000000) {
      return '₩${(cost / 1000000).toStringAsFixed(0)}M';
    } else if (cost >= 1000) {
      return '₩${(cost / 1000).toStringAsFixed(0)}K';
    } else {
      return '₩${cost.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
    }
  }
  
  static String formatPercentage(double percentage, {int decimals = 1}) {
    return '${percentage.toStringAsFixed(decimals)}%';
  }
}

/// 날짜/시간 포맷팅 유틸리티
class DateTimeFormatter {
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }
  
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return formatDate(dateTime);
    }
  }
}