import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/project_material.dart';
import '../entities/material_transaction.dart';

abstract interface class InventoryRepository {
  /// Defines a new material for the project.
  Future<Either<Failure, ProjectMaterial>> createMaterial({
    required ProjectMaterial material,
  });

  /// Retrieves all materials for a project.
  Future<Either<Failure, List<ProjectMaterial>>> getMaterials({
    required String projectId,
  });

  /// Adds stock to a material (Restock).
  Future<Either<Failure, void>> restockMaterial({
    required String materialId,
    required double quantity,
    required double unitPrice,
    required String actorId,
    required String actorName,
    String? note,
  });

  /// Consumes stock from a material (Usage).
  /// Fails if stock is insufficient.
  Future<Either<Failure, void>> useMaterial({
    required String materialId,
    required double quantity,
    required String dailyLogId,
    required String actorId,
    required String actorName,
  });

  /// Consumes stock from multiple materials in a single batch.
  Future<Either<Failure, void>> useMaterialsBatch({
    required List<Map<String, dynamic>>
    usageList, // List of {materialId, quantity}
    required String dailyLogId,
    required String actorId,
    required String actorName,
  });

  /// Gets the transaction history for a project.
  Future<Either<Failure, List<MaterialTransaction>>> getTransactions({
    required String projectId,
  });

  Future<void> syncPendingTransaction(MaterialTransaction transaction);
  Future<void> syncPendingMaterial(ProjectMaterial material);

  Stream<int> getUnsyncedCount();
  Future<void> deleteLocalTransaction(String transactionId);
  Future<void> deleteLocalMaterial(String materialId);
  Future<List<MaterialTransaction>> getPendingTransactions();
  Future<List<ProjectMaterial>> getPendingMaterials();
}
