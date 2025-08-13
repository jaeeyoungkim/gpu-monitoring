import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'cloud_instance_model.g.dart';

/// 클라우드 제공자 열거형
enum CloudProvider {
  aws,
  gcp,
  azure,
  other,
}

/// GPU 타입 열거형 (실제 하드웨어 모델)
enum GPUType {
  teslaT4,
  a100_40gb,
  a100_80gb,
  h100,
  v100,
  other,
}

/// AWS 인스턴스 패밀리 열거형
enum AWSInstanceFamily {
  g4dn,    // Tesla T4
  p4d,     // A100 40GB
  p4de,    // A100 80GB
  p5,      // H100
  p3,      // V100
  other,
}

/// 클라우드 인스턴스 메타데이터 모델
@JsonSerializable()
class CloudInstanceMetadata extends Equatable {
  final String instanceId;
  final String instanceType;
  final CloudProvider provider;
  final String region;
  final GPUType gpuType;
  final int gpuCount;
  final int gpuMemoryGB;
  final int vcpu;
  final int memoryGB;
  final double hourlyRate;     // USD per hour
  final AWSInstanceFamily? instanceFamily;
  final Map<String, dynamic>? additionalMetadata;
  
  const CloudInstanceMetadata({
    required this.instanceId,
    required this.instanceType,
    required this.provider,
    required this.region,
    required this.gpuType,
    required this.gpuCount,
    required this.gpuMemoryGB,
    required this.vcpu,
    required this.memoryGB,
    required this.hourlyRate,
    this.instanceFamily,
    this.additionalMetadata,
  });

  factory CloudInstanceMetadata.fromJson(Map<String, dynamic> json) =>
      _$CloudInstanceMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$CloudInstanceMetadataToJson(this);

  /// GPU당 시간당 비용 계산
  double get costPerGPUPerHour => hourlyRate / gpuCount;

  /// 월간 예상 비용 (720시간 기준)
  double get monthlyCost => hourlyRate * 720;

  /// GPU당 월간 예상 비용
  double get monthlyCostPerGPU => monthlyCost / gpuCount;

  /// GPU 타입 한국어 이름
  String get gpuTypeKoreanName {
    switch (gpuType) {
      case GPUType.teslaT4:
        return 'Tesla T4';
      case GPUType.a100_40gb:
        return 'A100 40GB';
      case GPUType.a100_80gb:
        return 'A100 80GB';
      case GPUType.h100:
        return 'H100';
      case GPUType.v100:
        return 'V100';
      case GPUType.other:
        return '기타';
    }
  }

  /// 클라우드 제공자 한국어 이름
  String get providerKoreanName {
    switch (provider) {
      case CloudProvider.aws:
        return 'AWS';
      case CloudProvider.gcp:
        return 'Google Cloud';
      case CloudProvider.azure:
        return 'Microsoft Azure';
      case CloudProvider.other:
        return '기타';
    }
  }

  /// 인스턴스 패밀리 설명
  String get instanceFamilyDescription {
    switch (instanceFamily) {
      case AWSInstanceFamily.g4dn:
        return 'G4dn (Tesla T4, 추론 최적화)';
      case AWSInstanceFamily.p4d:
        return 'P4d (A100 40GB, ML 훈련)';
      case AWSInstanceFamily.p4de:
        return 'P4de (A100 80GB, 대규모 ML)';
      case AWSInstanceFamily.p5:
        return 'P5 (H100, 최신 고성능)';
      case AWSInstanceFamily.p3:
        return 'P3 (V100, 범용 ML)';
      case null:
      case AWSInstanceFamily.other:
        return '기타';
    }
  }

  /// 비용 효율성 등급 (GPU당 시간당 비용 기준)
  CostEfficiencyLevel get costEfficiencyLevel {
    final costPerGpu = costPerGPUPerHour;
    if (costPerGpu <= 1.0) return CostEfficiencyLevel.excellent;
    if (costPerGpu <= 2.0) return CostEfficiencyLevel.good;
    if (costPerGpu <= 5.0) return CostEfficiencyLevel.moderate;
    return CostEfficiencyLevel.expensive;
  }

  @override
  List<Object?> get props => [
        instanceId,
        instanceType,
        provider,
        region,
        gpuType,
        gpuCount,
        gpuMemoryGB,
        vcpu,
        memoryGB,
        hourlyRate,
        instanceFamily,
        additionalMetadata,
      ];
}

/// 비용 효율성 등급
enum CostEfficiencyLevel {
  excellent,  // 우수 ($0-1/GPU/hour)
  good,       // 양호 ($1-2/GPU/hour)
  moderate,   // 보통 ($2-5/GPU/hour)
  expensive,  // 비싼 ($5+/GPU/hour)
}

/// 비용 효율성 등급 확장
extension CostEfficiencyLevelExtension on CostEfficiencyLevel {
  String get koreanName {
    switch (this) {
      case CostEfficiencyLevel.excellent:
        return '우수';
      case CostEfficiencyLevel.good:
        return '양호';
      case CostEfficiencyLevel.moderate:
        return '보통';
      case CostEfficiencyLevel.expensive:
        return '낮음';
    }
  }

  Color get color {
    switch (this) {
      case CostEfficiencyLevel.excellent:
        return const Color(0xFF4CAF50); // Green
      case CostEfficiencyLevel.good:
        return const Color(0xFF8BC34A); // Light Green
      case CostEfficiencyLevel.moderate:
        return const Color(0xFFFF9800); // Orange
      case CostEfficiencyLevel.expensive:
        return const Color(0xFFF44336); // Red
    }
  }
}

/// AWS 비용 메트릭 모델 (Prometheus 스타일)
@JsonSerializable()
class AWSCostMetric extends Equatable {
  final String resourceId;
  final String instanceType;
  final String gpuType;
  final int gpuCount;
  final String service;
  final String region;
  final double dailyCost;
  final DateTime timestamp;

  const AWSCostMetric({
    required this.resourceId,
    required this.instanceType,
    required this.gpuType,
    required this.gpuCount,
    required this.service,
    required this.region,
    required this.dailyCost,
    required this.timestamp,
  });

  factory AWSCostMetric.fromJson(Map<String, dynamic> json) =>
      _$AWSCostMetricFromJson(json);

  Map<String, dynamic> toJson() => _$AWSCostMetricToJson(this);

  /// Prometheus 메트릭 형식으로 변환
  String toPrometheusMetric() {
    return '''aws_cost_daily{
  resource_id="$resourceId",
  instance_type="$instanceType",
  gpu_type="$gpuType",
  gpu_count="$gpuCount",
  service="$service",
  region="$region"
} $dailyCost''';
  }

  @override
  List<Object?> get props => [
        resourceId,
        instanceType,
        gpuType,
        gpuCount,
        service,
        region,
        dailyCost,
        timestamp,
      ];
}