import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'constants.dart';

/// Material Design 3 기반 앱 테마
class AppTheme {
  // 기본 시드 색상
  static const Color _seedColor = AppConstants.primaryColor;
  
  /// 라이트 테마 생성
  static ThemeData lightTheme(ColorScheme? lightColorScheme) {
    final colorScheme = lightColorScheme ?? 
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // 타이포그래피
      textTheme: _buildTextTheme(colorScheme),
      
      // 앱바 테마
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: AppConstants.fontSizeTitle,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      
      // 카드 테마
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        margin: const EdgeInsets.all(AppConstants.spacingS),
      ),
      
      // 버튼 테마들
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      ),
      
      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingM,
        ),
      ),
      
      // 칩 테마
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: AppConstants.fontSizeM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
      ),
      
      // 다이얼로그 테마
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        elevation: 3,
      ),
      
      // 바텀 시트 테마
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXL),
          ),
        ),
        elevation: 3,
      ),
      
      // 스낵바 테마
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
      
      // 리스트 타일 테마
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
      ),
      
      // 분할선 테마
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  /// 다크 테마 생성
  static ThemeData darkTheme(ColorScheme? darkColorScheme) {
    final colorScheme = darkColorScheme ?? 
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // 타이포그래피
      textTheme: _buildTextTheme(colorScheme),
      
      // 앱바 테마
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: AppConstants.fontSizeTitle,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      
      // 카드 테마
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        margin: const EdgeInsets.all(AppConstants.spacingS),
      ),
      
      // 버튼 테마들
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      ),
      
      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingM,
        ),
      ),
      
      // 칩 테마
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: AppConstants.fontSizeM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
      ),
      
      // 다이얼로그 테마
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        elevation: 3,
      ),
      
      // 바텀 시트 테마
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXL),
          ),
        ),
        elevation: 3,
      ),
      
      // 스낵바 테마
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
      
      // 리스트 타일 테마
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
      ),
      
      // 분할선 테마
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  /// 텍스트 테마 생성
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // 헤드라인
      headlineLarge: TextStyle(
        fontSize: AppConstants.fontSizeHeading,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: AppConstants.fontSizeTitle,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: -0.25,
      ),
      headlineSmall: TextStyle(
        fontSize: AppConstants.fontSizeXXL,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      
      // 타이틀
      titleLarge: TextStyle(
        fontSize: AppConstants.fontSizeXL,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: AppConstants.fontSizeL,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: AppConstants.fontSizeM,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      
      // 바디
      bodyLarge: TextStyle(
        fontSize: AppConstants.fontSizeL,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: AppConstants.fontSizeM,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: AppConstants.fontSizeS,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
        height: 1.3,
      ),
      
      // 라벨
      labelLarge: TextStyle(
        fontSize: AppConstants.fontSizeM,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: AppConstants.fontSizeS,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontSize: AppConstants.fontSizeXS,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
  
  /// GPU 사용률 레벨별 색상 가져오기
  static Color getUtilizationColor(String level, {bool isDark = false}) {
    switch (level) {
      case 'none':
        return isDark ? Colors.grey[800]! : AppConstants.utilizationNoneColor;
      case 'low':
        return AppConstants.utilizationLowColor;
      case 'medium':
        return AppConstants.utilizationMediumColor;
      case 'high':
        return AppConstants.utilizationHighColor;
      default:
        return isDark ? Colors.grey[600]! : Colors.grey[300]!;
    }
  }
  
  /// 상태별 색상 가져오기
  static Color getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'success':
      case 'allocated':
      case 'optimized':
        return colorScheme.primary;
      case 'warning':
      case 'pending':
        return colorScheme.tertiary;
      case 'error':
      case 'failed':
        return colorScheme.error;
      case 'info':
        return colorScheme.secondary;
      default:
        return colorScheme.outline;
    }
  }
  
  /// 우선순위별 색상 가져오기
  static Color getPriorityColor(String priority, ColorScheme colorScheme) {
    switch (priority) {
      case 'critical':
        return colorScheme.error;
      case 'high':
        return colorScheme.tertiary;
      case 'medium':
        return colorScheme.secondary;
      case 'low':
        return colorScheme.outline;
      default:
        return colorScheme.surfaceVariant;
    }
  }
}

/// 테마 확장 유틸리티
extension ThemeExtensions on ThemeData {
  /// 현재 테마가 다크 모드인지 확인
  bool get isDark => brightness == Brightness.dark;
  
  /// 현재 테마가 라이트 모드인지 확인
  bool get isLight => brightness == Brightness.light;
  
  /// 그림자 색상 (투명도 적용)
  Color get shadowColor => colorScheme.shadow.withOpacity(0.1);
  
  /// 표면 색상 변형 (카드, 패널 등)
  Color get surfaceVariant => colorScheme.surfaceVariant;
  
  /// 경계선 색상
  Color get borderColor => colorScheme.outline.withOpacity(0.2);
}

/// 색상 스키마 확장
extension ColorSchemeExtensions on ColorScheme {
  /// GPU 사용률 레벨별 색상
  Color get utilizationNone => brightness == Brightness.dark 
      ? const Color(0xFF2C2C2C) 
      : AppConstants.utilizationNoneColor;
  
  Color get utilizationLow => AppConstants.utilizationLowColor;
  Color get utilizationMedium => AppConstants.utilizationMediumColor;
  Color get utilizationHigh => AppConstants.utilizationHighColor;
  
  /// 성공/경고/오류 색상
  Color get successColor => AppConstants.successColor;
  Color get warningColor => AppConstants.warningColor;
  Color get infoColor => AppConstants.infoColor;
}