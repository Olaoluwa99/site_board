import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/project_material_model.dart';
import '../models/material_transaction_model.dart';

abstract interface class InventoryRemoteDataSource {
  Future<ProjectMaterialModel> createMaterial(ProjectMaterialModel material);

  Future<List<ProjectMaterialModel>> getMaterials(String projectId);

  Future<void> deleteMaterial(String materialId);

  Future<void> recordTransaction({
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
              .insert(material.toJson())
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
    required String materialId,
    required double quantityChange,
    required String transactionType,
    String? dailyLogId,
    required String actorId,
    double? unitPrice,
  }) async {
    try {
      await supabaseClient.rpc(
        'record_material_transaction',
        params: {
          'p_material_id': materialId,
          'p_quantity_change': quantityChange,
          'p_transaction_type': transactionType,
          'p_daily_log_id': dailyLogId,
          'p_actor_id': actorId,
          'p_unit_price': unitPrice,
        },
      );
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
          .select('*, project_materials!inner(project_id, name)')
          .eq('project_materials.project_id', projectId)
          .order('timestamp', ascending: false);

      final List<dynamic> transactionsData = List.from(data);

      if (transactionsData.isNotEmpty) {
        // Safe Fallback: Manually fetch actor names if the join fails or isn't possible
        final actorIds =
            transactionsData
                .map((t) => t['actor_id'] as String?)
                .where((id) => id != null)
                .toSet()
                .toList();

        if (actorIds.isNotEmpty) {
          try {
            final profilesData = await supabaseClient
                .from('profiles')
                .select('id, name')
                .inFilter('id', actorIds);

            final Map<String, String> profileNames = {
              for (var p in profilesData)
                p['id'] as String: p['name'] as String,
            };

            for (var t in transactionsData) {
              final aId = t['actor_id'] as String?;
              if (aId != null && profileNames.containsKey(aId)) {
                t['profiles'] = {'name': profileNames[aId]};
              }
            }
          } catch (e) {
            // If separate profile fetch fails, we just show "Unknown" (handled by Model)
            // This prevents the whole list from crashing.
            print("Failed to fetch profiles separately: $e");
          }
        }
      }

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
