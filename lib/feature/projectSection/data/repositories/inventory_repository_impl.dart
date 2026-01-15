import 'package:fpdart/fpdart.dart';
import 'package:site_board/core/error/exceptions.dart';
import 'package:site_board/core/error/failure.dart';
import 'package:site_board/feature/projectSection/domain/entities/material_transaction.dart';
import 'package:site_board/feature/projectSection/domain/entities/project_material.dart';
import 'package:site_board/feature/projectSection/domain/repositories/inventory_repository.dart';
import '../dataSources/inventory_remote_data_source.dart';
import '../models/project_material_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ProjectMaterial>> createMaterial({
    required ProjectMaterial material,
  }) async {
    try {
      final model = ProjectMaterialModel.fromEntity(material);
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
      final materials = await remoteDataSource.getMaterials(projectId);
      return Right(materials);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
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
      await remoteDataSource.recordTransaction(
        materialId: materialId,
        quantityChange: quantity,
        transactionType: 'IN',
        actorId: actorId,
        unitPrice: unitPrice,
        // Optional: We could log the note if we added a field for it to txn table
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
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
      await remoteDataSource.recordTransaction(
        materialId: materialId,
        quantityChange: quantity,
        transactionType: 'OUT',
        dailyLogId: dailyLogId,
        actorId: actorId,
      );
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
      final txns = await remoteDataSource.getTransactions(projectId);
      return Right(txns);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
