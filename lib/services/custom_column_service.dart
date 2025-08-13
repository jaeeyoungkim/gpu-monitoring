import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/custom_column_model.dart';

/// 커스텀 컬럼 서비스 프로바이더
final customColumnProvider = StateNotifierProvider<CustomColumnNotifier, List<CustomColumnModel>>((ref) {
  return CustomColumnNotifier();
});

/// GPU 커스텀 데이터 프로바이더
final gpuCustomDataProvider = StateNotifierProvider<GPUCustomDataNotifier, List<GPUCustomData>>((ref) {
  return GPUCustomDataNotifier();
});

/// 커스텀 컬럼 관리 서비스
class CustomColumnNotifier extends StateNotifier<List<CustomColumnModel>> {
  CustomColumnNotifier() : super(_getDefaultColumns());

  /// 기본 커스텀 컬럼들
  static List<CustomColumnModel> _getDefaultColumns() {
    return [
      CustomColumnModel(
        id: 'project',
        name: '프로젝트',
        type: CustomColumnType.text,
        order: 1,
        isVisible: true,
      ),
    ];
  }

  /// 새 커스텀 컬럼 추가
  void addColumn(CustomColumnModel column) {
    state = [...state, column];
  }

  /// 커스텀 컬럼 업데이트
  void updateColumn(String columnId, CustomColumnModel updatedColumn) {
    state = state.map((column) {
      return column.id == columnId ? updatedColumn : column;
    }).toList();
  }

  /// 커스텀 컬럼 삭제
  void removeColumn(String columnId) {
    state = state.where((column) => column.id != columnId).toList();
  }

  /// 컬럼 순서 변경
  void reorderColumns(int oldIndex, int newIndex) {
    final columns = List<CustomColumnModel>.from(state);
    final column = columns.removeAt(oldIndex);
    columns.insert(newIndex, column);
    
    // 순서 재정렬
    for (int i = 0; i < columns.length; i++) {
      columns[i] = columns[i].copyWith(order: i + 1);
    }
    
    state = columns;
  }

  /// 컬럼 가시성 토글
  void toggleColumnVisibility(String columnId) {
    state = state.map((column) {
      return column.id == columnId 
          ? column.copyWith(isVisible: !column.isVisible)
          : column;
    }).toList();
  }

  /// 보이는 컬럼들만 가져오기
  List<CustomColumnModel> get visibleColumns {
    return state.where((column) => column.isVisible).toList()..sort((a, b) => a.order.compareTo(b.order));
  }
}

/// GPU 커스텀 데이터 관리 서비스
class GPUCustomDataNotifier extends StateNotifier<List<GPUCustomData>> {
  GPUCustomDataNotifier() : super(_getDefaultCustomData());

  /// 기본 GPU 커스텀 데이터
  static List<GPUCustomData> _getDefaultCustomData() {
    return [
      GPUCustomData(
        gpuId: 'Nvidia A100-GPU3',
        customValues: {
          'project': 'AI 모델 학습',
          'priority': '높음',
          'deadline': '2025-09-01',
          'cost_center': 'AI-001',
          'is_production': false,
        },
      ),
      GPUCustomData(
        gpuId: 'Nvidia A100-GPU4',
        customValues: {
          'project': '데이터 분석',
          'priority': '보통',
          'deadline': '2025-08-15',
          'cost_center': 'DS-002',
          'is_production': true,
        },
      ),
      GPUCustomData(
        gpuId: 'Nvidia H100-GPU5',
        customValues: {
          'project': '머신러닝 실험',
          'priority': '낮음',
          'deadline': '2025-10-01',
          'cost_center': 'ML-003',
          'is_production': false,
        },
      ),
      GPUCustomData(
        gpuId: 'Nvidia A100-GPU6',
        customValues: {
          'project': '컴퓨터 비전',
          'priority': '높음',
          'deadline': '2025-08-30',
          'cost_center': 'CV-004',
          'is_production': true,
        },
      ),
      GPUCustomData(
        gpuId: 'Nvidia H100-GPU7',
        customValues: {
          'project': 'NLP 연구',
          'priority': '보통',
          'deadline': '2025-09-15',
          'cost_center': 'NLP-005',
          'is_production': false,
        },
      ),
    ];
  }

  /// GPU의 커스텀 데이터 가져오기
  GPUCustomData? getGPUCustomData(String gpuId) {
    try {
      return state.firstWhere((data) => data.gpuId == gpuId);
    } catch (e) {
      return null;
    }
  }

  /// GPU의 커스텀 값 업데이트
  void updateGPUCustomValue(String gpuId, String columnId, dynamic value) {
    final existingDataIndex = state.indexWhere((data) => data.gpuId == gpuId);
    
    if (existingDataIndex != -1) {
      // 기존 데이터 업데이트
      final updatedData = state[existingDataIndex].setValue(columnId, value);
      state = [
        ...state.sublist(0, existingDataIndex),
        updatedData,
        ...state.sublist(existingDataIndex + 1),
      ];
    } else {
      // 새 데이터 추가
      final newData = GPUCustomData(
        gpuId: gpuId,
        customValues: {columnId: value},
      );
      state = [...state, newData];
    }
  }

  /// GPU의 특정 컬럼 값 가져오기
  dynamic getGPUCustomValue(String gpuId, String columnId) {
    final customData = getGPUCustomData(gpuId);
    return customData?.getValue(columnId);
  }

  /// GPU 커스텀 데이터 삭제
  void removeGPUCustomData(String gpuId) {
    state = state.where((data) => data.gpuId != gpuId).toList();
  }
}