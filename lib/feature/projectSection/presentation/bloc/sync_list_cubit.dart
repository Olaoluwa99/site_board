import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/projectSection/domain/repositories/inventory_repository.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';
import 'package:site_board/core/enums/sync_status.dart';

abstract class SyncListState {}

class SyncListInitial extends SyncListState {}

class SyncListLoading extends SyncListState {}

enum SyncItemType { project, transaction, material, dailyLog, unknown }

class SyncItem {
  final String id;
  final String title;
  final String subtitle;
  final SyncItemType type;
  final dynamic originalObject;

  SyncItem({
    required this.id,
    required this.title,
    this.subtitle = 'Waiting for connection...',
    required this.type,
    required this.originalObject,
  });
}

class SyncListLoaded extends SyncListState {
  final List<SyncItem> items;

  SyncListLoaded({required this.items});
}

class SyncListError extends SyncListState {
  final String message;

  SyncListError(this.message);
}

class SyncListCubit extends Cubit<SyncListState> {
  final ProjectRepository projectRepository;
  final InventoryRepository inventoryRepository;

  SyncListCubit({
    required this.projectRepository,
    required this.inventoryRepository,
  }) : super(SyncListInitial());

  Future<void> loadPendingItems() async {
    emit(SyncListLoading());
    try {
      final projects = await projectRepository.getPendingProjects();
      final dailyLogs = await projectRepository.getPendingDailyLogs();
      final transactions = await inventoryRepository.getPendingTransactions();
      final materials = await inventoryRepository.getPendingMaterials();

      final List<SyncItem> items = [];

      for (var p in projects) {
        items.add(
          SyncItem(
            id: p.id,
            title: "Project: ${p.projectName}",
            subtitle: "New Project Creation",
            type: SyncItemType.project,
            originalObject: p,
          ),
        );
      }

      for (var log in dailyLogs) {
        String subtitle =
            "Workers: ${log.numberOfWorkers}, Weather: ${log.weatherCondition}";
        if (log.syncStatus == SyncStatus.updated) {
          subtitle = "Modified Locally (Waiting for sync)";
        } else if (log.syncStatus == SyncStatus.created) {
          subtitle = "New Log (Waiting for sync)";
        }

        items.add(
          SyncItem(
            id: log.id,
            title: "Daily Log",
            subtitle: subtitle,
            type: SyncItemType.dailyLog,
            originalObject: log,
          ),
        );
      }

      for (var t in transactions) {
        String title = "Transaction";
        String subtitle = "Waiting for connection...";

        if (t.type.toString().contains('IN')) {
          title = "Restock: ${t.materialName ?? 'Unknown Material'}";
          subtitle = "Added ${t.quantityChange} to stock";
        } else {
          title = "Used: ${t.materialName ?? 'Unknown Material'}";
          subtitle = "Used ${t.quantityChange.abs()} from stock";
        }

        items.add(
          SyncItem(
            id: t.id,
            title: title,
            subtitle: subtitle,
            type: SyncItemType.transaction,
            originalObject: t,
          ),
        );
      }

      for (var m in materials) {
        items.add(
          SyncItem(
            id: m.id,
            title: "New Material: ${m.name}",
            subtitle: "Unit: ${m.unit}, Qty: ${m.currentQuantity}",
            type: SyncItemType.material,
            originalObject: m,
          ),
        );
      }

      emit(SyncListLoaded(items: items));
    } catch (e) {
      emit(SyncListError(e.toString()));
    }
  }

  Future<void> deleteItem(SyncItem item) async {
    emit(SyncListLoading());
    try {
      if (item.type == SyncItemType.project) {
        await projectRepository.deleteLocalProject(item.id);
      } else if (item.type == SyncItemType.dailyLog) {
        await projectRepository.deleteLocalDailyLog(item.id);
      } else if (item.type == SyncItemType.transaction) {
        await inventoryRepository.deleteLocalTransaction(item.id);
      } else if (item.type == SyncItemType.material) {
        await inventoryRepository.deleteLocalMaterial(item.id);
      }
      await loadPendingItems(); // Reload
    } catch (e) {
      emit(SyncListError(e.toString()));
    }
  }
}
