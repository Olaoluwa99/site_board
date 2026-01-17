part of 'inventory_bloc.dart';

@immutable
sealed class InventoryState {}

final class InventoryInitial extends InventoryState {}

final class InventoryLoading extends InventoryState {}

final class InventoryFailure extends InventoryState {
  final String error;

  InventoryFailure(this.error);
}

final class InventorySuccess extends InventoryState {
  final String message;

  InventorySuccess(this.message);
}

final class InventoryMaterialsLoaded extends InventoryState {
  final List<ProjectMaterial> materials;

  InventoryMaterialsLoaded(this.materials);
}

final class InventoryTransactionsLoaded extends InventoryState {
  final List<MaterialTransaction> transactions;

  InventoryTransactionsLoaded(this.transactions);
}
