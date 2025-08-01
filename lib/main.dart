import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/dashboard_screen.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 한국어 로케일 초기화
  await initializeDateFormatting('ko_KR', null);
  
  runApp(
    const ProviderScope(
      child: GPUHeatmapDashboardApp(),
    ),
  );
}

class GPUHeatmapDashboardApp extends ConsumerWidget {
  const GPUHeatmapDashboardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: AppConstants.appTitle,
          debugShowCheckedModeBanner: false,
          
          // 테마 설정
          theme: AppTheme.lightTheme(lightDynamic),
          darkTheme: AppTheme.darkTheme(darkDynamic),
          themeMode: ThemeMode.system,
          
          // 로케일 설정
          locale: const Locale('ko', 'KR'),
          supportedLocales: const [
            Locale('ko', 'KR'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          
          // 홈 화면
          home: const DashboardScreen(),
          
          // 라우트 설정
          routes: {
            '/dashboard': (context) => const DashboardScreen(),
          },
          
          // 글로벌 설정
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0, // 텍스트 크기 고정
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}

/// 앱 전역 설정을 위한 위젯
class AppWrapper extends StatelessWidget {
  final Widget child;
  
  const AppWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: child,
      ),
    );
  }
}