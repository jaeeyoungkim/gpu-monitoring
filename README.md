# WhaTap GPU 통합 모니터링 대시보드 - Flutter 버전

> 비효율적인 GPU 자원 활용 문제 해결을 위한 통합 모니터링 환경

## 📱 프로젝트 개요

기존 웹 기반 GPU 모니터링 대시보드를 Flutter로 완전히 재구현한 모바일/데스크톱 크로스 플랫폼 애플리케이션입니다. Material Design 3를 적용하여 현대적이고 직관적인 UI/UX를 제공하며, 반응형 디자인으로 다양한 화면 크기를 지원합니다.

### ✨ 주요 특징

- 🎯 **4단계 히트맵 시스템**: 할당안됨, 낮음, 보통, 높음으로 GPU 사용률 시각화
- 📊 **실시간 모니터링**: GPU 사용률, 성능 메트릭, KPI 대시보드
- 🔄 **스케줄링 최적화**: CFO 시나리오 기반 GPU 공유 및 재할당 최적화
- 💰 **비용 절감 분석**: 최적화를 통한 예상 비용 절감액 계산
- 📱 **크로스 플랫폼**: iOS, Android, Web, Desktop 지원
- 🎨 **Material Design 3**: 현대적이고 일관된 디자인 시스템
- ⚡ **고성능**: Flutter의 네이티브 성능과 부드러운 애니메이션

## 🚀 빠른 시작

### 필수 요구사항

- **Flutter SDK**: 3.10.0 이상
- **Dart SDK**: 3.0.0 이상
- **IDE**: VS Code, Android Studio, 또는 IntelliJ IDEA

### 설치 및 실행

1. **Flutter 설치 확인**
   ```bash
   flutter --version
   flutter doctor
   ```

2. **프로젝트 클론**
   ```bash
   git clone [repository-url]
   cd gpu-heatmap-dashboard/flutter_app
   ```

3. **의존성 설치**
   ```bash
   flutter pub get
   ```

4. **코드 생성 (필요시)**
   ```bash
   flutter packages pub run build_runner build
   ```

5. **앱 실행**
   ```bash
   # 웹에서 실행
   flutter run -d chrome
   
   # 모바일 에뮬레이터에서 실행
   flutter run
   
   # 데스크톱에서 실행 (macOS)
   flutter run -d macos
   ```

## 📁 프로젝트 구조

```
flutter_app/
├── lib/
│   ├── main.dart                 # 앱 진입점
│   ├── models/                   # 데이터 모델
│   │   ├── gpu_model.dart
│   │   ├── department_model.dart
│   │   └── optimization_model.dart
│   ├── screens/                  # 화면 위젯
│   │   └── dashboard_screen.dart
│   ├── widgets/                  # 재사용 가능한 위젯
│   │   └── heatmap_widget.dart
│   ├── services/                 # 비즈니스 로직 및 데이터 서비스
│   │   └── gpu_data_service.dart
│   └── utils/                    # 유틸리티 및 상수
│       ├── constants.dart
│       └── theme.dart
├── assets/                       # 리소스 파일
│   ├── images/
│   └── fonts/
├── test/                        # 테스트 파일
├── pubspec.yaml                 # 프로젝트 설정 및 의존성
└── README.md                    # 이 파일
```

## 🎯 핵심 기능

### 1. GPU 사용률 히트맵

- **4단계 분류 시스템**
  - 할당안됨 (0%): 회색
  - 낮음 (1-30%): 빨강
  - 보통 (31-70%): 주황
  - 높음 (71-100%): 파랑

- **기간별 뷰**
  - 월간: 31일 × GPU 매트릭스
  - 주간: 7일 × GPU 매트릭스
  - 일간: 24시간 × GPU 매트릭스

- **인터랙티브 기능**
  - 호버 툴팁으로 상세 정보 표시
  - 클릭으로 GPU 상세 모달 열기
  - 기간 네비게이션 (이전/다음)

### 2. 스케줄링 최적화

- **CFO 시나리오 기반 최적화**
  - 부서별 GPU 사용 패턴 분석
  - 공유 및 재할당을 통한 비용 절감
  - 실시간 절감 효과 계산

- **최적화 추천**
  - 미할당 GPU 활용 방안
  - 저활용 GPU 통합 기회
  - 지속적인 모니터링 권장

### 3. 실시간 대시보드

- **KPI 카드**
  - Total GPUs, Active, Efficient, Avg Utilization
  - 실시간 데이터 업데이트
  - 시각적 인디케이터

- **분석 결과**
  - 최적화 기회 식별
  - 예상 비용 절감액
  - 액션 아이템 제공

## 🛠️ 기술 스택

### Frontend
- **Flutter**: 3.10.0+
- **Dart**: 3.0.0+
- **Material Design 3**: 현대적 UI/UX

### 상태 관리
- **Riverpod**: 2.4.9+ (반응형 상태 관리)
- **Provider**: 6.1.1+ (의존성 주입)

### 데이터 시각화
- **FL Chart**: 0.65.0+ (차트 및 그래프)
- **Syncfusion Charts**: 23.2.7+ (고급 차트)

### 유틸리티
- **Intl**: 0.19.0+ (국제화 및 날짜 포맷)
- **Equatable**: 2.0.5+ (객체 비교)
- **Animations**: 2.0.8+ (고급 애니메이션)

## 🎨 디자인 시스템

### 색상 팔레트
- **Primary**: #667EEA (보라-파랑 그라데이션)
- **Secondary**: #764BA2
- **Success**: #4CAF50 (초록)
- **Warning**: #FF9800 (주황)
- **Error**: #F44336 (빨강)

### 타이포그래피
- **Font Family**: Pretendard (한국어 최적화)
- **Font Sizes**: 10px ~ 28px (반응형)
- **Font Weights**: 400, 500, 600, 700

### 간격 시스템
- **XS**: 4px, **S**: 8px, **M**: 16px
- **L**: 24px, **XL**: 32px, **XXL**: 48px

## 📊 데이터 모델

### GPU 모델
```dart
class GPUModel {
  final String id;
  final String name;
  final int avgUtil;
  final bool isMig;
  final GPUPerformance performance;
  final List<int> monthlyData;
  final List<int> weeklyData;
  final List<int> dailyData;
}
```

### 부서 모델
```dart
class DepartmentModel {
  final String name;
  final String gpu;
  final String assignment;
  final List<bool> schedule;
  final int utilization;
  final DepartmentStatus status;
}
```

## 🧪 테스트

### 테스트 실행
```bash
# 모든 테스트 실행
flutter test

# 특정 테스트 파일 실행
flutter test test/models/gpu_model_test.dart

# 커버리지 포함 테스트
flutter test --coverage
```

### 테스트 구조
- **Unit Tests**: 모델 및 서비스 로직 테스트
- **Widget Tests**: UI 컴포넌트 테스트
- **Integration Tests**: 전체 플로우 테스트

## 🚀 빌드 및 배포

### 웹 빌드
```bash
flutter build web --release
```

### 모바일 빌드
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

### 데스크톱 빌드
```bash
# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

## 🔧 개발 가이드

### 코딩 컨벤션
- **Dart Style Guide** 준수
- **Effective Dart** 권장사항 적용
- **Linting**: flutter_lints 사용

### 상태 관리 패턴
```dart
// Riverpod Provider 정의
final gpuDataProvider = FutureProvider<List<GPUModel>>((ref) async {
  final service = GPUDataService();
  return service.generateMockGPUData();
});

// Consumer Widget에서 사용
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpuDataAsync = ref.watch(gpuDataProvider);
    return gpuDataAsync.when(
      data: (data) => DataWidget(data),
      loading: () => LoadingWidget(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### 새로운 기능 추가
1. **모델 정의**: `lib/models/` 에 데이터 모델 추가
2. **서비스 구현**: `lib/services/` 에 비즈니스 로직 추가
3. **위젯 생성**: `lib/widgets/` 에 UI 컴포넌트 추가
4. **화면 통합**: `lib/screens/` 에서 위젯 조합
5. **테스트 작성**: `test/` 에 테스트 코드 추가

## 🐛 문제 해결

### 일반적인 문제

1. **Flutter SDK 버전 불일치**
   ```bash
   flutter upgrade
   flutter pub get
   ```

2. **의존성 충돌**
   ```bash
   flutter pub deps
   flutter pub upgrade
   ```

3. **빌드 오류**
   ```bash
   flutter clean
   flutter pub get
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Hot Reload 문제**
   ```bash
   # 앱 재시작
   r (in terminal)
   # Hot Restart
   R (in terminal)
   ```

### 성능 최적화

- **이미지 최적화**: WebP 형식 사용
- **번들 크기 최적화**: `--split-per-abi` 옵션 사용
- **메모리 관리**: dispose() 메서드 적절히 구현
- **렌더링 최적화**: const 생성자 사용

## 📚 추가 리소스

### 공식 문서
- [Flutter 공식 문서](https://flutter.dev/docs)
- [Dart 언어 가이드](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)

### 패키지 문서
- [Riverpod](https://riverpod.dev/)
- [FL Chart](https://github.com/imaNNeo/fl_chart)
- [Syncfusion Flutter](https://help.syncfusion.com/flutter/introduction/overview)

### 개발 도구
- [Flutter Inspector](https://flutter.dev/docs/development/tools/flutter-inspector)
- [Dart DevTools](https://dart.dev/tools/dart-devtools)
- [Flutter Performance](https://flutter.dev/docs/perf)

## 🤝 기여 가이드

1. **이슈 생성**: 새로운 기능이나 버그 리포트
2. **브랜치 생성**: `feature/기능명` 또는 `fix/버그명`
3. **개발 및 테스트**: 관련 테스트 코드 포함
4. **Pull Request**: 상세한 설명과 스크린샷 포함
5. **코드 리뷰**: 팀원 리뷰 후 머지

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 📞 지원

- **이슈 리포트**: GitHub Issues
- **기술 문의**: 개발팀 연락처
- **문서 업데이트**: Pull Request 환영

---

**개발팀**: WhaTap GPU 모니터링 팀  
**버전**: 3.0.0  
**최종 업데이트**: 2025년 7월 31일