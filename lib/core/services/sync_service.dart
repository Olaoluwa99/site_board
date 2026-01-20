import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:site_board/core/enums/sync_status.dart';
import 'package:site_board/feature/projectSection/data/dataSources/inventory_local_data_source.dart';
import 'package:site_board/feature/projectSection/data/dataSources/project_local_data_source.dart';
import 'package:site_board/feature/projectSection/domain/repositories/inventory_repository.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';

class SyncService {
  final InternetConnection internetConnection;
  final ProjectLocalDataSource projectLocalDataSource;
  final InventoryLocalDataSource inventoryLocalDataSource;
  final ProjectRepository projectRepository;
  final InventoryRepository inventoryRepository;

  SyncService({
    required this.internetConnection,
    required this.projectLocalDataSource,
    required this.inventoryLocalDataSource,
    required this.projectRepository,
    required this.inventoryRepository,
  }) {
    _init();
  }

  void _init() {
    internetConnection.onStatusChange.listen((status) {
      if (status == InternetStatus.connected) {
        syncAll();
      }
    });
  }

  Future<void> syncAll() async {
    await syncProjects();
    await projectRepository.syncPendingLogs();
    await syncInventory();
  }

  Future<void> syncProjects() async {
    final pendingProjects = projectLocalDataSource.getProjectsByStatus(
      SyncStatus.created,
    );
    for (final project in pendingProjects) {
      await projectRepository.syncPendingProject(project);
    }
  }

  Future<void> syncInventory() async {
    final pendingTransactions = inventoryLocalDataSource
        .getTransactionsByStatus(SyncStatus.created);
    for (final transaction in pendingTransactions) {
      await inventoryRepository.syncPendingTransaction(transaction);
    }

    final pendingMaterials = inventoryLocalDataSource.getMaterialsByStatus(
      SyncStatus.created,
    );
    for (final material in pendingMaterials) {
      await inventoryRepository.syncPendingMaterial(material);
    }
  }
}
