enum TransactionType { IN, OUT }

class MaterialTransaction {
  final String id;
  final String materialId;
  final TransactionType type;
  final double quantityChange;
  final String? dailyLogId;
  final String? actorId;
  final DateTime timestamp;
  final String? materialName;
  final double? unitPrice;
  final String? actorName;

  const MaterialTransaction({
    required this.id,
    required this.materialId,
    required this.type,
    required this.quantityChange,
    this.dailyLogId,
    this.actorId,
    required this.timestamp,
    this.materialName,
    this.unitPrice,
    this.actorName,
  });

  MaterialTransaction copyWith({
    String? id,
    String? materialId,
    TransactionType? type,
    double? quantityChange,
    String? dailyLogId,
    String? actorId,
    DateTime? timestamp,
    String? materialName,
    double? unitPrice,
    String? actorName,
  }) {
    return MaterialTransaction(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      type: type ?? this.type,
      quantityChange: quantityChange ?? this.quantityChange,
      dailyLogId: dailyLogId ?? this.dailyLogId,
      actorId: actorId ?? this.actorId,
      timestamp: timestamp ?? this.timestamp,
      materialName: materialName ?? this.materialName,
      unitPrice: unitPrice ?? this.unitPrice,
      actorName: actorName ?? this.actorName,
    );
  }
}
