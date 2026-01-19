import 'package:site_board/core/enums/sync_status.dart';

class ProjectMaterial {
  final String id;
  final String projectId;
  final String name;
  final String unit;
  final double currentQuantity;
  final DateTime createdAt;
  final SyncStatus? syncStatus;

  const ProjectMaterial({
    required this.id,
    required this.projectId,
    required this.name,
    required this.unit,
    required this.currentQuantity,
    required this.createdAt,
    this.syncStatus,
  });

  ProjectMaterial copyWith({
    String? id,
    String? projectId,
    String? name,
    String? unit,
    double? currentQuantity,
    DateTime? createdAt,
    SyncStatus? syncStatus,
  }) {
    return ProjectMaterial(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
