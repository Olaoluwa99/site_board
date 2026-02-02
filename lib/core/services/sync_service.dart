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
    // 1. Critical Parents: Projects
    // Must succeed for everything else to find a home.
    await syncProjects();

    // 2. Members
    // Must succeed for attribution.
    await syncMembers();

    // 3. Inventory Materials
    // Must succeed for transactions to reference valid materials.
    await syncMaterials();

    // 4. Daily Logs (Parents for Transactions)
    // Includes Images & Tasks.
    await projectRepository.syncPendingLogs();

    // 5. Inventory Transactions
    // Links Material + Log.
    await syncTransactions();
  }

  Future<void> syncProjects() async {
    final pendingProjects = projectLocalDataSource.getProjectsByStatus(
      SyncStatus.created,
    );
    // Also consider 'updated' projects if we add that feature later
    // pendingProjects.addAll(projectLocalDataSource.getProjectsByStatus(SyncStatus.updated));

    for (final project in pendingProjects) {
      try {
        await projectRepository.syncPendingProject(project);
      } catch (e) {
        // Log error but continue? Or stop?
        // If a project fails to sync, its logs will likely fail.
        // But other projects might succeed.
        // We continue.
      }
    }
  }

  Future<void> syncMembers() async {
    // We don't have a direct 'getMembersByStatus' on projectLocalDataSource yet,
    // usually members are part of ProjectModel.
    // But if we have standalone member updates (e.g. invites), they might be handled here.
    // For now, if members are embedded in Project, syncPendingProject handles them.
    // IF we separate them in Phase 3/4, we add logic here.

    // NOTE: Current architecture seems to bundle members with Project or sync them immediately in UI.
    // We should adding a dedicated 'syncPendingMembers' if we move to offline member management.
    // For now, relying on 'Project' sync might be sufficient if members are part of project structure.

    // However, the User removed _uploadCreatorStatus, implying we rely on Project Sync.
    // If we support "Add Member" offline later, we need code here.
  }

  Future<void> syncMaterials() async {
    final pendingMaterials = inventoryLocalDataSource.getMaterialsByStatus(
      SyncStatus.created,
    );
    for (final material in pendingMaterials) {
      try {
        await inventoryRepository.syncPendingMaterial(material);
      } catch (e) {
        // Continue
      }
    }
  }

  Future<void> syncTransactions() async {
    final pendingTransactions = inventoryLocalDataSource
        .getTransactionsByStatus(SyncStatus.created);
    for (final transaction in pendingTransactions) {
      try {
        await inventoryRepository.syncPendingTransaction(transaction);
      } catch (e) {
        // Continue
      }
    }
  }
}
