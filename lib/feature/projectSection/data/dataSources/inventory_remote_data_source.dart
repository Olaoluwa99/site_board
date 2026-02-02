import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/project_material_model.dart';
import '../models/material_transaction_model.dart';

abstract interface class InventoryRemoteDataSource {
  Future<ProjectMaterialModel> createMaterial(ProjectMaterialModel material);

  Future<List<ProjectMaterialModel>> getMaterials(String projectId);

  Future<void> deleteMaterial(String materialId);

  Future<void> recordTransaction({
    required String transactionId,
    required String materialId,
    required double quantityChange,
    required String transactionType, // "IN" or "OUT"
    String? dailyLogId,
    required String actorId,
    double? unitPrice,
  });

  Future<List<MaterialTransactionModel>> getTransactions(String projectId);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final SupabaseClient supabaseClient;

  InventoryRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<ProjectMaterialModel> createMaterial(
    ProjectMaterialModel material,
  ) async {
    try {
      final data =
          await supabaseClient
              .from('project_materials')
              .upsert(material.toJson())
              .select()
              .single();
      return ProjectMaterialModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ProjectMaterialModel>> getMaterials(String projectId) async {
    try {
      final data = await supabaseClient
          .from('project_materials')
          .select()
          .eq('project_id', projectId)
          .order('name', ascending: true);

      return (data as List)
          .map((e) => ProjectMaterialModel.fromJson(e))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteMaterial(String materialId) async {
    try {
      await supabaseClient
          .from('project_materials')
          .delete()
          .eq('id', materialId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> recordTransaction({
    required String transactionId,
    required String materialId,
    required double quantityChange,
    required String transactionType, // "IN" or "OUT"
    String? dailyLogId,
    required String actorId,
    double? unitPrice,
  }) async {
    try {
      final data = {
        'id': transactionId,
        'material_id': materialId,
        'quantity_change': quantityChange,
        'type': transactionType,
        'daily_log_id': dailyLogId,
        'actor_id': actorId,
        'unit_price': unitPrice,
        'timestamp':
            DateTime.now().toIso8601String(), // Ensure timestamp is set
      };

      await supabaseClient.from('material_transactions').upsert(data).select();
    } on PostgrestException catch (e) {
      // Catch specific DB constraint errors (e.g. check constraint)
      if (e.code == '23514') {
        // check_violation
        throw const ServerException('Insufficient stock available.');
      }
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MaterialTransactionModel>> getTransactions(
    String projectId,
  ) async {
    try {
      final data = await supabaseClient
          .from('material_transactions')
          .select(
            '*, project_materials!inner(project_id, name), profiles(name)',
          )
          .eq('project_materials.project_id', projectId)
          .order('timestamp', ascending: false);

      final List<dynamic> transactionsData = List.from(data);

      return transactionsData
          .map((e) => MaterialTransactionModel.fromJson(e))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
