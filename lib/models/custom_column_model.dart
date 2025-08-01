import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'custom_column_model.g.dart';

/// 커스텀 컬럼 타입 열거형
enum CustomColumnType {
  text,     // 텍스트 입력
  number,   // 숫자 입력
  dropdown, // 드롭다운 선택
  date,     // 날짜 선택
  boolean,  // 체크박스
}

/// 커스텀 컬럼 모델
@JsonSerializable()
class CustomColumnModel extends Equatable {
  final String id;
  final String name;
  final CustomColumnType type;
  final bool isRequired;
  final List<String>? dropdownOptions; // 드롭다운 타입일 때 사용
  final String? defaultValue;
  final int order; // 컬럼 순서
  final bool isVisible;

  const CustomColumnModel({
    required this.id,
    required this.name,
    required this.type,
    this.isRequired = false,
    this.dropdownOptions,
    this.defaultValue,
    required this.order,
    this.isVisible = true,
  });

  factory CustomColumnModel.fromJson(Map<String, dynamic> json) =>
      _$CustomColumnModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomColumnModelToJson(this);

  /// 타입별 기본 아이콘
  String get typeIcon {
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

  /// 타입별 한국어 텍스트
  String get typeText {
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

  /// 컬럼 복사 (불변성 유지)
  CustomColumnModel copyWith({
    String? id,
    String? name,
    CustomColumnType? type,
    bool? isRequired,
    List<String>? dropdownOptions,
    String? defaultValue,
    int? order,
    bool? isVisible,
  }) {
    return CustomColumnModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      dropdownOptions: dropdownOptions ?? this.dropdownOptions,
      defaultValue: defaultValue ?? this.defaultValue,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        isRequired,
        dropdownOptions,
        defaultValue,
        order,
        isVisible,
      ];
}

/// GPU 커스텀 데이터 모델
@JsonSerializable()
class GPUCustomData extends Equatable {
  final String gpuId;
  final Map<String, dynamic> customValues; // 커스텀 컬럼 ID -> 값

  const GPUCustomData({
    required this.gpuId,
    required this.customValues,
  });

  factory GPUCustomData.fromJson(Map<String, dynamic> json) =>
      _$GPUCustomDataFromJson(json);

  Map<String, dynamic> toJson() => _$GPUCustomDataToJson(this);

  /// 특정 컬럼의 값 가져오기
  dynamic getValue(String columnId) {
    return customValues[columnId];
  }

  /// 특정 컬럼의 값 설정
  GPUCustomData setValue(String columnId, dynamic value) {
    final newValues = Map<String, dynamic>.from(customValues);
    newValues[columnId] = value;
    return copyWith(customValues: newValues);
  }

  /// 커스텀 데이터 복사
  GPUCustomData copyWith({
    String? gpuId,
    Map<String, dynamic>? customValues,
  }) {
    return GPUCustomData(
      gpuId: gpuId ?? this.gpuId,
      customValues: customValues ?? this.customValues,
    );
  }

  @override
  List<Object?> get props => [gpuId, customValues];
}

/// 커스텀 컬럼 리스트 확장 메서드
extension CustomColumnListExtensions on List<CustomColumnModel> {
  /// 순서별 정렬
  List<CustomColumnModel> sortedByOrder() {
    final sorted = List<CustomColumnModel>.from(this);
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  /// 보이는 컬럼만 필터링
  List<CustomColumnModel> get visibleColumns =>
      where((column) => column.isVisible).toList();

  /// 필수 컬럼만 필터링
  List<CustomColumnModel> get requiredColumns =>
      where((column) => column.isRequired).toList();

  /// 타입별 필터링
  List<CustomColumnModel> filterByType(CustomColumnType type) =>
      where((column) => column.type == type).toList();
}