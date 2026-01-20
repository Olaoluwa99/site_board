import 'dart:async';
import 'package:hive/hive.dart';
import 'package:async/async.dart';
import 'package:site_board/core/enums/sync_status.dart';
import 'package:site_board/feature/projectSection/data/models/material_transaction_model.dart';
import 'package:site_board/feature/projectSection/data/models/project_material_model.dart';

abstract interface class InventoryLocalDataSource {
  void uploadOfflineTransaction({
    required MaterialTransactionModel transaction,
  });
  List<MaterialTransactionModel> getTransactionsByStatus(SyncStatus status);
  void cacheTransactions({
    required List<MaterialTransactionModel> transactions,
  });
  List<MaterialTransactionModel> getLastCachedTransactions({String? projectId});
  void uploadOfflineMaterial({required ProjectMaterialModel material});
  List<ProjectMaterialModel> getMaterialsByStatus(SyncStatus status);
  void cacheMaterials({required List<ProjectMaterialModel> materials});
  List<ProjectMaterialModel> getLastCachedMaterials({String? projectId});
  Stream<int> getUnsyncedCountStream();
  Future<void> deleteTransaction(String transactionId);
  Future<void> deleteMaterial(String materialId);
  void clearData();
}

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  final Box transactionBox;
  final Box materialsBox;

  InventoryLocalDataSourceImpl(this.transactionBox, this.materialsBox);

  @override
  void uploadOfflineTransaction({
    required MaterialTransactionModel transaction,
  }) {
    transactionBox.put(transaction.id, transaction.toJson());
  }

  @override
  List<MaterialTransactionModel> getTransactionsByStatus(SyncStatus status) {
    List<MaterialTransactionModel> transactions = [];
    for (var key in transactionBox.keys) {
      final data = transactionBox.get(key);
      if (data != null) {
        final txn = MaterialTransactionModel.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (txn.syncStatus == status) {
          transactions.add(txn);
        }
      }
    }
    return transactions;
  }

  @override
  void cacheTransactions({
    required List<MaterialTransactionModel> transactions,
  }) {
    for (var txn in transactions) {
      final cachedTxn = txn.copyWith(syncStatus: SyncStatus.synced);
      transactionBox.put(
        cachedTxn.id,
        MaterialTransactionModel.fromEntity(cachedTxn).toJson(),
      );
    }
  }

  @override
  List<MaterialTransactionModel> getLastCachedTransactions({
    String? projectId,
  }) {
    List<MaterialTransactionModel> transactions = [];

    // If projectId is provided, we first need the list of materials for that project
    Set<String> validMaterialIds = {};
    if (projectId != null) {
      final projectMaterials = getLastCachedMaterials(projectId: projectId);
      validMaterialIds = projectMaterials.map((e) => e.id).toSet();
    }

    for (var key in transactionBox.keys) {
      final data = transactionBox.get(key);
      if (data != null) {
        final txn = MaterialTransactionModel.fromJson(
          Map<String, dynamic>.from(data),
        );

        // Filter: If projectId was requested, txn must belong to a material in that project
        if (projectId != null) {
          if (validMaterialIds.contains(txn.materialId)) {
            transactions.add(txn);
          }
        } else {
          // No filter requested (e.g. for sync)
          transactions.add(txn);
        }
      }
    }
    transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return transactions;
  }

  @override
  void uploadOfflineMaterial({required ProjectMaterialModel material}) {
    materialsBox.put(material.id, material.toJson());
  }

  @override
  List<ProjectMaterialModel> getMaterialsByStatus(SyncStatus status) {
    List<ProjectMaterialModel> materials = [];
    for (var key in materialsBox.keys) {
      final data = materialsBox.get(key);
      if (data != null) {
        final mat = ProjectMaterialModel.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (mat.syncStatus == status) {
          materials.add(mat);
        }
      }
    }
    return materials;
  }

  @override
  void cacheMaterials({required List<ProjectMaterialModel> materials}) {
    for (var mat in materials) {
      final cachedMat = mat.copyWith(syncStatus: SyncStatus.synced);
      materialsBox.put(
        cachedMat.id,
        ProjectMaterialModel.fromEntity(cachedMat).toJson(),
      );
    }
  }

  @override
  List<ProjectMaterialModel> getLastCachedMaterials({String? projectId}) {
    List<ProjectMaterialModel> materials = [];
    for (var key in materialsBox.keys) {
      final data = materialsBox.get(key);
      if (data != null) {
        final mat = ProjectMaterialModel.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (projectId == null || mat.projectId == projectId) {
          materials.add(mat);
        }
      }
    }
    return materials;
  }

  @override
  Stream<int> getUnsyncedCountStream() {
    // Watch both boxes
    final transactionStream = transactionBox.watch();
    final materialStream = materialsBox.watch();

    return StreamGroup.merge([transactionStream, materialStream]).map((_) {
      // Re-calculate total unsynced count on any event
      final txnCount = getTransactionsByStatus(SyncStatus.created).length;
      final matCount = getMaterialsByStatus(SyncStatus.created).length;
      return txnCount + matCount;
    });
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await transactionBox.delete(transactionId);
  }

  @override
  Future<void> deleteMaterial(String materialId) async {
    await materialsBox.delete(materialId);
  }

  @override
  void clearData() {
    transactionBox.clear();
    materialsBox.clear();
  }
}
