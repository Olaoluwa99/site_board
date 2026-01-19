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

  @override
  Future<Either<Failure, ProjectMaterial>> createMaterial({
    required ProjectMaterial material,
  }) async {
    try {
      final model = ProjectMaterialModel.fromEntity(material);
      // TODO: Implement optimistic create material if needed.
      // For now, focusing on restock as per user request.
      final createdFn = await remoteDataSource.createMaterial(model);
      return Right(createdFn);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ProjectMaterial>>> getMaterials({
    required String projectId,
  }) async {
    try {
      if (await connectionChecker.isConnected) {
        final materials = await remoteDataSource.getMaterials(projectId);
        localDataSource.cacheMaterials(materials: materials);
        return Right(materials);
      } else {
        return Right(
          localDataSource.getLastCachedMaterials(projectId: projectId),
        );
      }
    } catch (e) {
      // Return cached if available, otherwise failure
      final cached = localDataSource.getLastCachedMaterials(
        projectId: projectId,
      );
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restockMaterial({
    required String materialId,
    required double quantity,
    required double unitPrice,
    required String actorId,
    String? note,
  }) async {
    try {
      final transaction = MaterialTransactionModel(
        id: const Uuid().v4(),
        materialId: materialId,
        type: TransactionType.IN,
        quantityChange: quantity,
        actorId: actorId,
        unitPrice: unitPrice,
        timestamp: DateTime.now(),
        syncStatus: SyncStatus.created,
      );

      // Optimistic save
      localDataSource.uploadOfflineTransaction(transaction: transaction);

      // Background sync
      _syncRestockMaterial(transaction);

      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<void> _syncRestockMaterial(
    MaterialTransactionModel transaction,
  ) async {
    if (await connectionChecker.isConnected) {
      try {
        await remoteDataSource.recordTransaction(
          materialId: transaction.materialId,
          quantityChange: transaction.quantityChange,
          transactionType: 'IN',
          actorId: transaction.actorId ?? '',
          unitPrice: transaction.unitPrice ?? 0,
        );
        // On success, mark as synced.
        final syncedTxn = transaction.copyWith(syncStatus: SyncStatus.synced);
        localDataSource.uploadOfflineTransaction(
          transaction: MaterialTransactionModel.fromEntity(syncedTxn),
        );
      } catch (e) {
        debugPrint("Background sync failed for restock: $e");
      }
    }
  }

  @override
  Future<Either<Failure, void>> useMaterial({
    required String materialId,
    required double quantity,
    required String dailyLogId,
    required String actorId,
  }) async {
    try {
      final transaction = MaterialTransactionModel(
        id: const Uuid().v4(),
        materialId: materialId,
        type: TransactionType.OUT,
        quantityChange: -quantity,
        actorId: actorId,
        dailyLogId: dailyLogId,
        timestamp: DateTime.now(),
        syncStatus: SyncStatus.created,
      );
      localDataSource.uploadOfflineTransaction(transaction: transaction);

      if (await connectionChecker.isConnected) {
        await remoteDataSource.recordTransaction(
          materialId: materialId,
          quantityChange: -quantity,
          transactionType: 'OUT',
          dailyLogId: dailyLogId,
          actorId: actorId,
        );
        final syncedTxn = transaction.copyWith(syncStatus: SyncStatus.synced);
        localDataSource.uploadOfflineTransaction(
          transaction: MaterialTransactionModel.fromEntity(syncedTxn),
        );
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
        await _syncRestockMaterial(transaction);
      }
    }
  }

  @override
  Stream<int> getUnsyncedCount() {
    return localDataSource.getUnsyncedCountStream();
  }

  @override
  Future<void> deleteLocalTransaction(String transactionId) async {
    localDataSource.deleteTransaction(transactionId);
  }

  @override
  Future<List<MaterialTransaction>> getPendingTransactions() async {
    return localDataSource.getTransactionsByStatus(SyncStatus.created);
  }
}
