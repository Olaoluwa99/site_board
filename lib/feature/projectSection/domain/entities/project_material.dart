class ProjectMaterial {
  final String id;
  final String projectId;
  final String name;
  final String unit;
  final double currentQuantity;
  final DateTime createdAt;

  const ProjectMaterial({
    required this.id,
    required this.projectId,
    required this.name,
    required this.unit,
    required this.currentQuantity,
    required this.createdAt,
  });

  ProjectMaterial copyWith({
    String? id,
    String? projectId,
    String? name,
    String? unit,
    double? currentQuantity,
    DateTime? createdAt,
  }) {
    return ProjectMaterial(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
