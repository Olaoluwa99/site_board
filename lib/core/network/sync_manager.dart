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
      try {
        final pendingProjects = await projectRepository.getPendingProjects();
        for (final project in pendingProjects) {
          try {
            await projectRepository.syncPendingProject(project);
          } catch (e) {
            debugPrint("Failed to sync project ${project.id}: $e");
          }
        }
      } catch (e) {
        debugPrint("Error fetching/syncing projects: $e");
      }

      // 1.5 Sync Pending Materials
      try {
        final pendingMaterials =
            await inventoryRepository.getPendingMaterials();
        for (final material in pendingMaterials) {
          try {
            await inventoryRepository.syncPendingMaterial(material);
          } catch (e) {
            debugPrint("Failed to sync material ${material.id}: $e");
          }
        }
      } catch (e) {
        debugPrint("Error fetching/syncing materials: $e");
      }

      // 2. Sync Pending Logs
      try {
        await projectRepository.syncPendingLogs();
      } catch (e) {
        debugPrint("Error syncing logs: $e");
      }

      // 3. Sync Pending Transactions
      try {
        final pendingTransactions =
            await inventoryRepository.getPendingTransactions();
        for (final txn in pendingTransactions) {
          try {
            await inventoryRepository.syncPendingTransaction(txn);
          } catch (e) {
            debugPrint("Failed to sync transaction ${txn.id}: $e");
          }
        }
      } catch (e) {
        debugPrint("Error fetching/syncing transactions: $e");
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
