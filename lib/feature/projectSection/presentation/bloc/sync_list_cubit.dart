import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/projectSection/domain/repositories/inventory_repository.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';

abstract class SyncListState {}

class SyncListInitial extends SyncListState {}

class SyncListLoading extends SyncListState {}

enum SyncItemType { project, transaction, dailyLog, unknown }

class SyncItem {
  final String id;
  final String title;
  final SyncItemType type;
  final dynamic originalObject;

  SyncItem({
    required this.id,
    required this.title,
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
      final transactions = await inventoryRepository.getPendingTransactions();

      final List<SyncItem> items = [];

      for (var p in projects) {
        items.add(
          SyncItem(
            id: p.id,
            title: "Project: ${p.projectName}",
            type: SyncItemType.project,
            originalObject: p,
          ),
        );
      }

      for (var t in transactions) {
        String title = "Transaction";
        if (t.type.toString().contains('IN')) {
          title = "Restock Material";
        } else {
          title = "Used Material";
        }
        items.add(
          SyncItem(
            id: t.id,
            title: title,
            type: SyncItemType.transaction,
            originalObject: t,
          ),
        );
      }

      emit(SyncListLoaded(items: items));
    } catch (e) {
      emit(SyncListError(e.toString()));
    }
  }

  Future<void> deleteItem(SyncItem item) async {
    try {
      if (item.type == SyncItemType.project) {
        await projectRepository.deleteLocalProject(item.id);
      } else if (item.type == SyncItemType.transaction) {
        await inventoryRepository.deleteLocalTransaction(item.id);
      }
      loadPendingItems(); // Reload
    } catch (e) {
      emit(SyncListError(e.toString()));
    }
  }
}
