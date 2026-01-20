import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/projectSection/domain/repositories/inventory_repository.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';

class SyncStatusState {
  final int projectCount;
  final int inventoryCount;

  int get totalCount => projectCount + inventoryCount;

  SyncStatusState({this.projectCount = 0, this.inventoryCount = 0});
}

class SyncStatusCubit extends Cubit<SyncStatusState> {
  final ProjectRepository projectRepository;
  final InventoryRepository inventoryRepository;
  StreamSubscription? _projectSub;
  StreamSubscription? _inventorySub;

  SyncStatusCubit({
    required this.projectRepository,
    required this.inventoryRepository,
  }) : super(SyncStatusState()) {
    _init();
    _loadInitialCounts();
  }

  void _init() {
    _projectSub = projectRepository.getUnsyncedCount().listen((count) {
      emit(
        SyncStatusState(
          projectCount: count,
          inventoryCount: state.inventoryCount,
        ),
      );
    });
    _inventorySub = inventoryRepository.getUnsyncedCount().listen((count) {
      emit(
        SyncStatusState(
          projectCount: state.projectCount,
          inventoryCount: count,
        ),
      );
    });
  }

  Future<void> _loadInitialCounts() async {
    final pendingProjects = await projectRepository.getPendingProjects();
    final pendingTransactions =
        await inventoryRepository.getPendingTransactions();
    final pendingMaterials = await inventoryRepository.getPendingMaterials();

    emit(
      SyncStatusState(
        projectCount: pendingProjects.length,
        inventoryCount: pendingTransactions.length + pendingMaterials.length,
      ),
    );
  }

  @override
  Future<void> close() {
    _projectSub?.cancel();
    _inventorySub?.cancel();
    return super.close();
  }
}
