import 'package:site_board/core/enums/sync_status.dart';
import 'package:site_board/feature/projectSection/domain/entities/material_transaction.dart';

class MaterialTransactionModel extends MaterialTransaction {
  const MaterialTransactionModel({
    required super.id,
    required super.materialId,
    required super.type,
    required super.quantityChange,
    super.dailyLogId,
    super.actorId,
    required super.timestamp,
    super.materialName,
    super.unitPrice,
    super.actorName,
    super.syncStatus,
  });

  factory MaterialTransactionModel.fromJson(Map<String, dynamic> json) {
    return MaterialTransactionModel(
      id: json['id'] as String,
      materialId: json['material_id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.IN, // Default fallback if needed
      ),
      quantityChange: (json['quantity_change'] as num).toDouble(),
      dailyLogId: json['daily_log_id'] as String?,
      actorId: json['actor_id'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      materialName:
          json['project_materials'] != null
              ? json['project_materials']['name'] as String?
              : json['material_name'] as String?,
      unitPrice:
          json['unit_price'] != null
              ? (json['unit_price'] as num).toDouble()
              : null,
      actorName:
          json['profiles'] != null
              ? json['profiles']['name'] as String?
              : json['actor_name'] as String?,
      syncStatus:
          json['sync_status'] != null
              ? SyncStatus.values[json['sync_status'] as int]
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Note: This toJson is likely used for inserts/updates if we were using it that way.
    // But transactions are inserted via RPC.
    return {
      'id': id,
      'material_id': materialId,
      'type': type.name, // "IN" or "OUT"
      'quantity_change': quantityChange,
      'daily_log_id': dailyLogId,
      'actor_id': actorId,
      'timestamp': timestamp.toIso8601String(),
      'unit_price': unitPrice,
      'material_name': materialName,
      'actor_name': actorName,
      'sync_status': syncStatus?.index,
    };
  }

  factory MaterialTransactionModel.fromEntity(MaterialTransaction entity) {
    return MaterialTransactionModel(
      id: entity.id,
      materialId: entity.materialId,
      type: entity.type,
      quantityChange: entity.quantityChange,
      dailyLogId: entity.dailyLogId,
      actorId: entity.actorId,
      timestamp: entity.timestamp,
      materialName: entity.materialName,
      unitPrice: entity.unitPrice,
      actorName: entity.actorName,
      syncStatus: entity.syncStatus,
    );
  }
}
