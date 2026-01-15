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
    String? note,
  });

  /// Consumes stock from a material (Usage).
  /// Fails if stock is insufficient.
  Future<Either<Failure, void>> useMaterial({
    required String materialId,
    required double quantity,
    required String dailyLogId,
    required String actorId,
  });

  /// Gets the transaction history for a project.
  Future<Either<Failure, List<MaterialTransaction>>> getTransactions({
    required String projectId,
  });
}
