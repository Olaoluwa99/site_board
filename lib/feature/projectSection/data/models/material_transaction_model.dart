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
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material_id': materialId,
      'type': type.name, // "IN" or "OUT"
      'quantity_change': quantityChange,
      'daily_log_id': dailyLogId,
      'actor_id': actorId,
      'timestamp': timestamp.toIso8601String(),
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
    );
  }
}
