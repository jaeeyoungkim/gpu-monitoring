// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_instance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloudInstanceMetadata _$CloudInstanceMetadataFromJson(
        Map<String, dynamic> json) =>
    CloudInstanceMetadata(
      instanceId: json['instanceId'] as String,
      instanceType: json['instanceType'] as String,
      provider: $enumDecode(_$CloudProviderEnumMap, json['provider']),
      region: json['region'] as String,
      gpuType: $enumDecode(_$GPUTypeEnumMap, json['gpuType']),
      gpuCount: (json['gpuCount'] as num).toInt(),
      gpuMemoryGB: (json['gpuMemoryGB'] as num).toInt(),
      vcpu: (json['vcpu'] as num).toInt(),
      memoryGB: (json['memoryGB'] as num).toInt(),
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      instanceFamily: $enumDecodeNullable(
          _$AWSInstanceFamilyEnumMap, json['instanceFamily']),
      additionalMetadata: json['additionalMetadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CloudInstanceMetadataToJson(
        CloudInstanceMetadata instance) =>
    <String, dynamic>{
      'instanceId': instance.instanceId,
      'instanceType': instance.instanceType,
      'provider': _$CloudProviderEnumMap[instance.provider]!,
      'region': instance.region,
      'gpuType': _$GPUTypeEnumMap[instance.gpuType]!,
      'gpuCount': instance.gpuCount,
      'gpuMemoryGB': instance.gpuMemoryGB,
      'vcpu': instance.vcpu,
      'memoryGB': instance.memoryGB,
      'hourlyRate': instance.hourlyRate,
      'instanceFamily': _$AWSInstanceFamilyEnumMap[instance.instanceFamily],
      'additionalMetadata': instance.additionalMetadata,
    };

const _$CloudProviderEnumMap = {
  CloudProvider.aws: 'aws',
  CloudProvider.gcp: 'gcp',
  CloudProvider.azure: 'azure',
  CloudProvider.other: 'other',
};

const _$GPUTypeEnumMap = {
  GPUType.teslaT4: 'teslaT4',
  GPUType.a100_40gb: 'a100_40gb',
  GPUType.a100_80gb: 'a100_80gb',
  GPUType.h100: 'h100',
  GPUType.v100: 'v100',
  GPUType.other: 'other',
};

const _$AWSInstanceFamilyEnumMap = {
  AWSInstanceFamily.g4dn: 'g4dn',
  AWSInstanceFamily.p4d: 'p4d',
  AWSInstanceFamily.p4de: 'p4de',
  AWSInstanceFamily.p5: 'p5',
  AWSInstanceFamily.p3: 'p3',
  AWSInstanceFamily.other: 'other',
};

AWSCostMetric _$AWSCostMetricFromJson(Map<String, dynamic> json) =>
    AWSCostMetric(
      resourceId: json['resourceId'] as String,
      instanceType: json['instanceType'] as String,
      gpuType: json['gpuType'] as String,
      gpuCount: (json['gpuCount'] as num).toInt(),
      service: json['service'] as String,
      region: json['region'] as String,
      dailyCost: (json['dailyCost'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$AWSCostMetricToJson(AWSCostMetric instance) =>
    <String, dynamic>{
      'resourceId': instance.resourceId,
      'instanceType': instance.instanceType,
      'gpuType': instance.gpuType,
      'gpuCount': instance.gpuCount,
      'service': instance.service,
      'region': instance.region,
      'dailyCost': instance.dailyCost,
      'timestamp': instance.timestamp.toIso8601String(),
    };
