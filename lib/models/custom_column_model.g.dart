// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_column_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomColumnModel _$CustomColumnModelFromJson(Map<String, dynamic> json) =>
    CustomColumnModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$CustomColumnTypeEnumMap, json['type']),
      isRequired: json['isRequired'] as bool? ?? false,
      dropdownOptions: (json['dropdownOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      defaultValue: json['defaultValue'] as String?,
      order: (json['order'] as num).toInt(),
      isVisible: json['isVisible'] as bool? ?? true,
    );

Map<String, dynamic> _$CustomColumnModelToJson(CustomColumnModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$CustomColumnTypeEnumMap[instance.type]!,
      'isRequired': instance.isRequired,
      'dropdownOptions': instance.dropdownOptions,
      'defaultValue': instance.defaultValue,
      'order': instance.order,
      'isVisible': instance.isVisible,
    };

const _$CustomColumnTypeEnumMap = {
  CustomColumnType.text: 'text',
  CustomColumnType.number: 'number',
  CustomColumnType.dropdown: 'dropdown',
  CustomColumnType.date: 'date',
  CustomColumnType.boolean: 'boolean',
};

GPUCustomData _$GPUCustomDataFromJson(Map<String, dynamic> json) =>
    GPUCustomData(
      gpuId: json['gpuId'] as String,
      customValues: json['customValues'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GPUCustomDataToJson(GPUCustomData instance) =>
    <String, dynamic>{
      'gpuId': instance.gpuId,
      'customValues': instance.customValues,
    };
