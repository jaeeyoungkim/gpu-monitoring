import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cloud_instance_model.dart';
import '../models/gpu_model.dart';

/// 비용 계산 서비스 프로바이더
final costCalculationServiceProvider = Provider<CostCalculationService>((ref) {
  return CostCalculationService();
});

/// 클라우드 GPU 비용 계산 서비스
class CostCalculationService {
  
  /// AWS G4dn 인스턴스 (Tesla T4) 가격표 (KRW 기준)
  static const Map<String, CloudInstanceMetadata> g4dnPricing = {
    'g4dn.xlarge': CloudInstanceMetadata(
      instanceId: 'i-example-g4dn-xlarge',
      instanceType: 'g4dn.xlarge',
      provider: CloudProvider.aws,
      region: 'us-east-1',
      gpuType: GPUType.teslaT4,
      gpuCount: 1,
      gpuMemoryGB: 16,
      vcpu: 4,
      memoryGB: 16,
      hourlyRate: 789, // 0.526 * 1500
      instanceFamily: AWSInstanceFamily.g4dn,
    ),
    'g4dn.2xlarge': CloudInstanceMetadata(
      instanceId: 'i-example-g4dn-2xlarge',
      instanceType: 'g4dn.2xlarge',
      provider: CloudProvider.aws,
      region: 'us-east-1',
      gpuType: GPUType.teslaT4,
      gpuCount: 1,
      gpuMemoryGB: 16,
      vcpu: 8,
      memoryGB: 32,
      hourlyRate: 1128, // 0.752 * 1500
      instanceFamily: AWSInstanceFamily.g4dn,
    ),
    'g4dn.4xlarge': CloudInstanceMetadata(
      instanceId: 'i-example-g4dn-4xlarge',
      instanceType: 'g4dn.4xlarge',
      provider: CloudProvider.aws,
      region: 'us-east-1',
      gpuType: GPUType.teslaT4,
      gpuCount: 1,
      gpuMemoryGB: 16,
      vcpu: 16,
      memoryGB: 64,
      hourlyRate: 1806, // 1.204 * 1500
      instanceFamily: AWSInstanceFamily.g4dn,
    ),
    'g4dn.8xlarge': CloudInstanceMetadata(
      instanceId: 'i-example-g4dn-8xlarge',
      instanceType: 'g4dn.8xlarge',
      provider: CloudProvider.aws,
      region: 'us-east-1',
      gpuType: GPUType.teslaT4,
      gpuCount: 1,
      gpuMemoryGB: 16,
      vcpu: 32,
      memoryGB: 128,
      hourlyRate: 3264, // 2.176 * 1500
      instanceFamily: AWSInstanceFamily.g4dn,
    ),
    'g4dn.12xlarge': CloudInstanceMetadata(
      instanceId: 'i-example-g4dn-12xlarge',
      instanceType: 'g4dn.12xlarge',
      provider: CloudProvider.aws,
      region: 'us-east-1',
      gpuType: GPUType.teslaT4,
      gpuCount: 4,
      gpuMemoryGB: 64,
      vcpu: 48,
      memoryGB: 192,
      hourlyRate: 5868, // 3.912 * 1500
      instanceFamily: AWSInstanceFamily.g4dn,
    ),
    'g4dn.16xlarge': CloudInstanceMetadata(
      instanceId: 'i-example-g4dn-16xlarge',
      instanceType: 'g4dn.16xlarge',
      provider: CloudProvider.aws,
      region: 'us-east-1',
      gpuType: GPUType.teslaT4,
      gpuCount: 1,
      gpuMemoryGB: 16,
      vcpu: 64,
      memoryGB: 256,
      hourlyRate: 6528, // 4.352 * 1500
      instanceFamily: AWSInstanceFamily.g4dn,
    ),
    'g4dn.metal': CloudInstanceMetadata(
      instanceId: 'i-example-g4dn-metal',
      instanceType: 'g4dn.metal',
      provider: CloudProvider.aws,
      region: 'us-east-1',
      gpuType: GPUType.teslaT4,
      gpuCount: 8,
      gpuMemoryGB: 128,
      vcpu: 96,
      memoryGB: 384,
      hourlyRate: 11736, // 7.824 * 1500
      instanceFamily: AWSInstanceFamily.g4dn,
    ),
  };

  /// AWS P4d 인스턴스 (A100 40GB) 가격표 (KRW 기준)
  static const Map<String, CloudInstanceMetadata> p4dPricing = {
    'p4d.24xlarge': CloudInstanceMetadata(
      instanceId: 'i-example-p4d-24xlarge',
      instanceType: 'p4d.24xlarge',
      provider: CloudProvider.aws,
      region: 'us-east-1',
      gpuType: GPUType.a100_40gb,
      gpuCount: 8,
      gpuMemoryGB: 320,
      vcpu: 96,
      memoryGB: 1152,
      hourlyRate: 49155, // 32.77 * 1500
      instanceFamily: AWSInstanceFamily.p4d,
    ),
  };

  /// AWS P4de 인스턴스 (A100 80GB) 가격표 (KRW 기준)
  static const Map<String, CloudInstanceMetadata> p4dePricing = {
    'p4de.24xlarge': CloudInstanceMetadata(
      instanceId: 'i-example-p4de-24xlarge',
      instanceType: 'p4de.24xlarge',
      provider: CloudProvider.aws,
      region: 'us-east-1',
      gpuType: GPUType.a100_80gb,
      gpuCount: 8,
      gpuMemoryGB: 640,
      vcpu: 96,
      memoryGB: 1152,
      hourlyRate: 61440, // 40.96 * 1500
      instanceFamily: AWSInstanceFamily.p4de,
    ),
  };

  /// AWS P5 인스턴스 (H100) 가격표 (KRW 기준)
  static const Map<String, CloudInstanceMetadata> p5Pricing = {
    'p5.48xlarge': CloudInstanceMetadata(
      instanceId: 'i-example-p5-48xlarge',
      instanceType: 'p5.48xlarge',
      provider: CloudProvider.aws,
      region: 'us-east-1',
      gpuType: GPUType.h100,
      gpuCount: 8,
      gpuMemoryGB: 640,
      vcpu: 192,
      memoryGB: 2048,
      hourlyRate: 147480, // 98.32 * 1500
      instanceFamily: AWSInstanceFamily.p5,
    ),
  };

  /// 모든 AWS 인스턴스 가격표 통합
  Map<String, CloudInstanceMetadata> get allAWSPricing => {
    ...g4dnPricing,
    ...p4dPricing,
    ...p4dePricing,
    ...p5Pricing,
  };

  /// GPU 타입에 따른 추천 인스턴스 반환
  List<CloudInstanceMetadata> getRecommendedInstancesForGPU(String gpuName) {
    final gpuNameLower = gpuName.toLowerCase();
    
    if (gpuNameLower.contains('t4') || gpuNameLower.contains('tesla t4')) {
      return g4dnPricing.values.toList();
    } else if (gpuNameLower.contains('a100')) {
      return [...p4dPricing.values, ...p4dePricing.values];
    } else if (gpuNameLower.contains('h100')) {
      return p5Pricing.values.toList();
    }
    
    // 기본적으로 Tesla T4 인스턴스 추천 (가장 저렴함)
    return g4dnPricing.values.toList();
  }

  /// 비용 최적화 추천
  CloudInstanceMetadata? getCostOptimalInstance(GPUType gpuType, int targetUtilization) {
    Map<String, CloudInstanceMetadata> relevantPricing;
    
    switch (gpuType) {
      case GPUType.teslaT4:
        relevantPricing = g4dnPricing;
        break;
      case GPUType.a100_40gb:
        relevantPricing = p4dPricing;
        break;
      case GPUType.a100_80gb:
        relevantPricing = p4dePricing;
        break;
      case GPUType.h100:
        relevantPricing = p5Pricing;
        break;
      default:
        relevantPricing = g4dnPricing;
    }

    // 사용률이 낮으면 작은 인스턴스, 높으면 큰 인스턴스 추천
    final sortedByEfficiency = relevantPricing.values.toList()
      ..sort((a, b) {
        if (targetUtilization < 30) {
          // 낮은 사용률: GPU당 비용이 낮은 순
          return a.costPerGPUPerHour.compareTo(b.costPerGPUPerHour);
        } else {
          // 높은 사용률: 전체 비용 효율성 고려
          final aEfficiency = a.gpuCount / a.hourlyRate;
          final bEfficiency = b.gpuCount / b.hourlyRate;
          return bEfficiency.compareTo(aEfficiency);
        }
      });

    return sortedByEfficiency.isNotEmpty ? sortedByEfficiency.first : null;
  }

  /// 비용 절약 시뮬레이션
  CostSavingsAnalysis analyzeCostSavings(List<GPUModel> gpus) {
    double currentMonthlyCost = 0;
    double optimizedMonthlyCost = 0;
    final recommendations = <CostOptimizationRecommendation>[];

    for (final gpu in gpus) {
      if (gpu.cloudMetadata != null) {
        currentMonthlyCost += gpu.cloudMetadata!.monthlyCostPerGPU;
        
        // 최적화된 인스턴스 찾기
        final optimal = getCostOptimalInstance(
          gpu.cloudMetadata!.gpuType, 
          gpu.avgUtil
        );
        
        if (optimal != null) {
          optimizedMonthlyCost += optimal.monthlyCostPerGPU;
          
          if (optimal.monthlyCostPerGPU < gpu.cloudMetadata!.monthlyCostPerGPU) {
            recommendations.add(CostOptimizationRecommendation(
              gpuId: gpu.id,
              currentInstance: gpu.cloudMetadata!.instanceType,
              recommendedInstance: optimal.instanceType,
              monthlySavings: gpu.cloudMetadata!.monthlyCostPerGPU - optimal.monthlyCostPerGPU,
              reason: gpu.avgUtil < 30 
                ? '낮은 사용률로 인해 더 작은 인스턴스 추천'
                : '비용 효율성 개선을 위한 인스턴스 변경 추천',
            ));
          }
        }
      }
    }

    return CostSavingsAnalysis(
      currentMonthlyCost: currentMonthlyCost,
      optimizedMonthlyCost: optimizedMonthlyCost,
      potentialSavings: currentMonthlyCost - optimizedMonthlyCost,
      savingsPercentage: currentMonthlyCost > 0 
        ? ((currentMonthlyCost - optimizedMonthlyCost) / currentMonthlyCost * 100)
        : 0,
      recommendations: recommendations,
    );
  }

  /// Prometheus 메트릭 생성
  List<AWSCostMetric> generateCostMetrics(List<GPUModel> gpus) {
    final metrics = <AWSCostMetric>[];
    final now = DateTime.now();

    for (final gpu in gpus) {
      if (gpu.cloudMetadata != null) {
        metrics.add(AWSCostMetric(
          resourceId: gpu.cloudMetadata!.instanceId,
          instanceType: gpu.cloudMetadata!.instanceType,
          gpuType: gpu.cloudMetadata!.gpuType.name,
          gpuCount: gpu.cloudMetadata!.gpuCount,
          service: 'EC2-Instance',
          region: gpu.cloudMetadata!.region,
          dailyCost: gpu.cloudMetadata!.hourlyRate * 24,
          timestamp: now,
        ));
      }
    }

    return metrics;
  }
}

/// 비용 절약 분석 결과
class CostSavingsAnalysis {
  final double currentMonthlyCost;
  final double optimizedMonthlyCost;
  final double potentialSavings;
  final double savingsPercentage;
  final List<CostOptimizationRecommendation> recommendations;

  const CostSavingsAnalysis({
    required this.currentMonthlyCost,
    required this.optimizedMonthlyCost,
    required this.potentialSavings,
    required this.savingsPercentage,
    required this.recommendations,
  });
}

/// 비용 최적화 추천
class CostOptimizationRecommendation {
  final String gpuId;
  final String currentInstance;
  final String recommendedInstance;
  final double monthlySavings;
  final String reason;

  const CostOptimizationRecommendation({
    required this.gpuId,
    required this.currentInstance,
    required this.recommendedInstance,
    required this.monthlySavings,
    required this.reason,
  });
}