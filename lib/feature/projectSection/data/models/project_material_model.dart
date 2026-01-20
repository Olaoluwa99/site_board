import 'package:site_board/feature/projectSection/domain/entities/project_material.dart';

import 'package:site_board/core/enums/sync_status.dart';

class ProjectMaterialModel extends ProjectMaterial {
  const ProjectMaterialModel({
    required super.id,
    required super.projectId,
    required super.name,
    required super.unit,
    required super.currentQuantity,
    required super.createdAt,
    super.syncStatus,
  });

  factory ProjectMaterialModel.fromJson(Map<String, dynamic> json) {
    return ProjectMaterialModel(
      id: json['id'] as String? ?? '',
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      currentQuantity: (json['current_quantity'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      syncStatus:
          json['sync_status'] != null
              ? SyncStatus.values[json['sync_status'] as int]
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'project_id': projectId,
      'name': name,
      'unit': unit,
      'current_quantity': currentQuantity,
      'created_at': createdAt.toIso8601String(),
      // 'sync_status': syncStatus?.index, // Local only
    };
  }

  // Helper to create a model from an entity
  factory ProjectMaterialModel.fromEntity(ProjectMaterial entity) {
    return ProjectMaterialModel(
      id: entity.id,
      projectId: entity.projectId,
      name: entity.name,
      unit: entity.unit,
      currentQuantity: entity.currentQuantity,
      createdAt: entity.createdAt,
      syncStatus: entity.syncStatus,
    );
  }
}
