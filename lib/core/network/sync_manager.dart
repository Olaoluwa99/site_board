import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:site_board/feature/projectSection/domain/repositories/inventory_repository.dart';
import 'package:site_board/feature/projectSection/domain/repositories/project_repository.dart';

class SyncManager {
  final ProjectRepository projectRepository;
  final InventoryRepository inventoryRepository;
  final Connectivity connectivity;

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  SyncManager({
    required this.projectRepository,
    required this.inventoryRepository,
    required this.connectivity,
  });

  void initialize() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((
      result,
    ) {
      if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet)) {
        startSync();
      }
    });
  }

  Future<void> startSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      debugPrint("SyncManager: Starting sync process...");

      // 1. Sync Pending Projects
      final pendingProjects = await projectRepository.getPendingProjects();
      for (final project in pendingProjects) {
        await projectRepository.syncPendingProject(project);
      }

      // 2. Sync Pending Transactions
      final pendingTransactions =
          await inventoryRepository.getPendingTransactions();
      for (final txn in pendingTransactions) {
        await inventoryRepository.syncPendingTransaction(txn);
      }

      debugPrint("SyncManager: Sync completed.");
    } catch (e) {
      debugPrint("SyncManager: Error during sync: $e");
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
