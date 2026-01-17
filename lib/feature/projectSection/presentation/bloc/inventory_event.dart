part of 'inventory_bloc.dart';

@immutable
sealed class InventoryEvent {}

final class InventoryGetMaterials extends InventoryEvent {
  final String projectId;

  InventoryGetMaterials({required this.projectId});
}

final class InventoryCreateMaterial extends InventoryEvent {
  final String projectId;
  final String name;
  final String unit;

  InventoryCreateMaterial({
    required this.projectId,
    required this.name,
    required this.unit,
  });
}

final class InventoryRestockMaterial extends InventoryEvent {
  final String materialId;
  final double quantity;
  final double unitPrice;
  final String actorId;
  final String? note;
  final String projectId; // Needed to refresh the list

  InventoryRestockMaterial({
    required this.materialId,
    required this.quantity,
    required this.unitPrice,
    required this.actorId,
    this.note,
    required this.projectId,
  });
}

// Prepared for Phase 3 but good to have defined
final class InventoryUseMaterial extends InventoryEvent {
  final String materialId;
  final double quantity;
  final String dailyLogId;
  final String actorId;
  final String projectId;

  InventoryUseMaterial({
    required this.materialId,
    required this.quantity,
    required this.dailyLogId,
    required this.actorId,
    required this.projectId,
  });
}

final class InventoryBatchUseMaterial extends InventoryEvent {
  final List<Map<String, dynamic>> usageList;
  final String dailyLogId;
  final String actorId;
  final String projectId;

  InventoryBatchUseMaterial({
    required this.usageList,
    required this.dailyLogId,
    required this.actorId,
    required this.projectId,
  });
}

final class InventoryGetTransactions extends InventoryEvent {
  final String projectId;

  InventoryGetTransactions({required this.projectId});
}
