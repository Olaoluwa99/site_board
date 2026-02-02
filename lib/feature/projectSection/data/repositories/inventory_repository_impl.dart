import 'package:fpdart/fpdart.dart';
import 'package:site_board/core/error/exceptions.dart';
import 'package:site_board/core/error/failure.dart';
import 'package:site_board/feature/projectSection/domain/entities/material_transaction.dart';
import 'package:site_board/feature/projectSection/domain/entities/project_material.dart';
import 'package:site_board/feature/projectSection/domain/repositories/inventory_repository.dart';
import '../dataSources/inventory_remote_data_source.dart';
import '../dataSources/inventory_local_data_source.dart';
import '../models/project_material_model.dart';
import 'package:site_board/core/network/connection_checker.dart';
import 'package:site_board/feature/projectSection/data/models/material_transaction_model.dart';
import 'package:site_board/core/enums/sync_status.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;
  final InventoryLocalDataSource localDataSource;
  final ConnectionChecker connectionChecker;

  InventoryRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.connectionChecker,
  );

  String? _getMaterialName(String materialId) {
    final localMaterials = localDataSource.getLastCachedMaterials();
    final material =
        localMaterials.where((m) => m.id == materialId).firstOrNull;
    return material?.name;
  }

  @override
  Future<Either<Failure, ProjectMaterial>> createMaterial({
    required ProjectMaterial material,
  }) async {
    try {
      final model = ProjectMaterialModel.fromEntity(
        material.copyWith(syncStatus: SyncStatus.created),
      );

      // 1. Optimistic Local Save
      localDataSource.uploadOfflineMaterial(material: model);

      // 2. Background Sync if connected
      await _syncCreateMaterial(model);

      return Right(model);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<void> _syncCreateMaterial(ProjectMaterialModel material) async {
    if (await connectionChecker.isConnected) {
      final createdMaterial = await remoteDataSource.createMaterial(material);

      // On success, update local with synced status
      final syncedMaterial = ProjectMaterialModel.fromEntity(
        createdMaterial.copyWith(syncStatus: SyncStatus.synced),
      );

      localDataSource.uploadOfflineMaterial(material: syncedMaterial);
    }
  }

  @override
  Future<Either<Failure, List<ProjectMaterial>>> getMaterials({
    required String projectId,
  }) async {
    try {
      if (await connectionChecker.isConnected) {
        try {
          debugPrint(
            "🔄 Fetching materials from server for project: $projectId",
          );
          final materials = await remoteDataSource.getMaterials(projectId);
          debugPrint("📥 Received ${materials.length} materials from server");
          for (var mat in materials) {
            debugPrint("   - ${mat.name}: ${mat.currentQuantity}");
          }
          localDataSource.cacheMaterials(materials: materials);
        } catch (e) {
          debugPrint("Remote fetch failed, using cache: $e");
        }
      }

      // Always load from cache (Source of Truth for UI)
      final cached = localDataSource.getLastCachedMaterials(
        projectId: projectId,
      );
      debugPrint("💿 Loaded ${cached.length} materials from cache");

      // Apply pending offline transactions to reflect current state
      final pendingTransactions = localDataSource.getTransactionsByStatus(
        SyncStatus.created,
      );
      debugPrint(
        "⏳ Found ${pendingTransactions.length} PENDING (unsynced) transactions",
      );

      final updatedMaterials =
          cached.map((material) {
            final materialTransactions = pendingTransactions.where(
              (t) => t.materialId == material.id,
            );

            double quantityChange = 0;
            for (var txn in materialTransactions) {
              quantityChange += txn.quantityChange;
              debugPrint("   Applying txn ${txn.id}: ${txn.quantityChange}");
            }

            if (quantityChange != 0) {
              debugPrint(
                "🔢 ${material.name}: ${material.currentQuantity} + $quantityChange = ${material.currentQuantity + quantityChange}",
              );
              return material.copyWith(
                currentQuantity: material.currentQuantity + quantityChange,
              );
            }
            return material;
          }).toList();
      debugPrint("📊 Final materials to display:");
      for (var mat in updatedMaterials) {
        debugPrint("   - ${mat.name}: ${mat.currentQuantity}");
      }

      updatedMaterials.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      return Right(updatedMaterials);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restockMaterial({
    required String materialId,
    required double quantity,
    required double unitPrice,
    required String actorId,
    required String actorName,
    String? note,
  }) async {
    try {
      // Fetch material name for UI
      // final localMaterials = localDataSource.getLastCachedMaterials();
      // final material =
      //     localMaterials.where((m) => m.id == materialId).firstOrNull;

      final transaction = MaterialTransactionModel(
        id: const Uuid().v4(),
        materialId: materialId,
        type: TransactionType.IN,
        quantityChange: quantity,
        actorId: actorId,
        actorName: actorName,
        unitPrice: unitPrice,
        timestamp: DateTime.now(),
        syncStatus: SyncStatus.created,
        materialName: _getMaterialName(materialId),
      );

      // Optimistic save
      debugPrint(
        "📦 Creating transaction: ${transaction.id} | Material: $materialId | Qty: +$quantity | Status: ${transaction.syncStatus}",
      );
      localDataSource.uploadOfflineTransaction(transaction: transaction);

      // Background sync
      await _syncTransaction(transaction);

      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<void> _syncTransaction(MaterialTransactionModel transaction) async {
    if (await connectionChecker.isConnected) {
      debugPrint("🌐 Syncing transaction: ${transaction.id} to server");
      await remoteDataSource.recordTransaction(
        transactionId: transaction.id,
        materialId: transaction.materialId,
        quantityChange: transaction.quantityChange,
        transactionType: transaction.type.name,
        actorId: transaction.actorId ?? '',
        unitPrice: transaction.unitPrice ?? 0,
      );
      // On success, mark as synced.
      debugPrint("✅ Transaction synced successfully: ${transaction.id}");
      final syncedTxn = transaction.copyWith(syncStatus: SyncStatus.synced);
      localDataSource.uploadOfflineTransaction(
        transaction: MaterialTransactionModel.fromEntity(syncedTxn),
      );
      debugPrint("💾 Updated local transaction to SYNCED status");
    }
  }

  @override
  Future<Either<Failure, void>> useMaterial({
    required String materialId,
    required double quantity,
    required String dailyLogId,
    required String actorId,
    required String actorName,
  }) async {
    try {
      final transaction = MaterialTransactionModel(
        id: const Uuid().v4(),
        materialId: materialId,
        type: TransactionType.OUT,
        quantityChange: -quantity,
        actorId: actorId,
        actorName: actorName,
        dailyLogId: dailyLogId,
        timestamp: DateTime.now(),
        syncStatus: SyncStatus.created,
        materialName: _getMaterialName(materialId),
      );
      debugPrint(
        "📦 Creating transaction: ${transaction.id} | Material: $materialId | Qty: $quantity (OUT) | Status: ${transaction.syncStatus}",
      );
      localDataSource.uploadOfflineTransaction(transaction: transaction);

      if (await connectionChecker.isConnected) {
        // Use generic sync
        await _syncTransaction(transaction);
        // Note: recordTransaction is enough, relying on syncTransaction logic above
      }
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> useMaterialsBatch({
    required List<Map<String, dynamic>> usageList,
    required String dailyLogId,
    required String actorId,
    required String actorName,
  }) async {
    try {
      for (final usage in usageList) {
        final mid = usage['materialId'] as String;
        final qty = usage['quantity'] as double;

        await useMaterial(
          materialId: mid,
          quantity: qty,
          dailyLogId: dailyLogId,
          actorId: actorId,
          actorName: actorName,
        );
      }
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MaterialTransaction>>> getTransactions({
    required String projectId,
  }) async {
    try {
      if (await connectionChecker.isConnected) {
        final txns = await remoteDataSource.getTransactions(projectId);
        localDataSource.cacheTransactions(transactions: txns);
        // We should merge with local unsynced transactions?
        // remoteDataSource returns "confirmed" transactions.
        // localDataSource.getLastCachedTransactions() returns ALL?
        // Let's rely on logic: fetch remote -> cache -> return cached (merged).
        return Right(
          localDataSource.getLastCachedTransactions(projectId: projectId),
        );
      } else {
        return Right(
          localDataSource.getLastCachedTransactions(projectId: projectId),
        );
      }
    } catch (e) {
      final cached = localDataSource.getLastCachedTransactions(
        projectId: projectId,
      );
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<void> syncPendingTransaction(MaterialTransaction transaction) async {
    if (transaction is MaterialTransactionModel) {
      if (transaction.syncStatus == SyncStatus.created) {
        await _syncTransaction(transaction);
      }
    }
  }

  @override
  Future<void> syncPendingMaterial(ProjectMaterial material) async {
    if (material is ProjectMaterialModel) {
      if (material.syncStatus == SyncStatus.created) {
        await _syncCreateMaterial(material);
      }
    }
  }

  @override
  Stream<int> getUnsyncedCount() {
    return localDataSource.getUnsyncedCountStream();
  }

  @override
  Future<void> deleteLocalTransaction(String transactionId) async {
    await localDataSource.deleteTransaction(transactionId);
  }

  @override
  Future<void> deleteLocalMaterial(String materialId) async {
    await localDataSource.deleteMaterial(materialId);
  }

  @override
  Future<List<MaterialTransaction>> getPendingTransactions() async {
    return localDataSource.getTransactionsByStatus(SyncStatus.created);
  }

  @override
  Future<List<ProjectMaterial>> getPendingMaterials() async {
    return localDataSource.getMaterialsByStatus(SyncStatus.created);
  }
}
