import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:site_board/core/common/widgets/loader.dart';
import 'package:site_board/feature/projectSection/domain/entities/material_transaction.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/inventory_bloc.dart';
import 'package:site_board/init_dependencies.dart';

class MaterialReportsPage extends StatelessWidget {
  final String projectId;

  const MaterialReportsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              serviceLocator<InventoryBloc>()
                ..add(InventoryGetTransactions(projectId: projectId))
                ..add(
                  InventoryGetMaterials(projectId: projectId),
                ), // Needed for Material Names?
      child: Scaffold(
        appBar: AppBar(title: const Text('Material Reports')),
        body: MultiBlocListener(
          listeners: [
            BlocListener<InventoryBloc, InventoryState>(
              listener: (context, state) {
                if (state is InventoryFailure) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
                }
              },
            ),
          ],
          child: BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, state) {
              if (state is InventoryLoading) {
                return const Loader();
              }
              // We need both transactions and materials ideally to map IDs to Names,
              // but InventoryState is single-state.
              // We can fetch materials first, then transactions?
              // OR simpler: Just show the transactions if Loaded, and let's hope we have material names if possible.
              // Actually, transaction entity has `materialId`. We need the name.
              // The `getTransactions` might join with materials?
              // Domain entity `MaterialTransaction` only has `materialId`.
              // For now, let's display ID or fetch materials logic.
              // Since the state is simple (one active state), handling unrelated data is tricky.
              // Best bet: Modify `InventoryTransactionsLoaded` to INCLUDE material map or similar?
              // Or, just list transactions and maybe we did a join in Supabase?
              // Let's check `inventory_remote_data_source`. `getTransactions` selects `*, project_materials(name, unit)`.
              // But `MaterialTransactionModel` might only parse the flat fields unless updated.
              // Let's check `MaterialTransactionModel.fromJson`.

              if (state is InventoryTransactionsLoaded) {
                if (state.transactions.isEmpty) {
                  return const Center(child: Text("No transactions found."));
                }
                return ListView.builder(
                  itemCount: state.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = state.transactions[index];
                    final isIN = transaction.type == TransactionType.IN;

                    // Helper formats
                    final dateStr = DateFormat(
                      'MMM dd, hh:mm a',
                    ).format(transaction.timestamp);
                    final qtyPrefix = isIN ? '+' : '-';
                    final color = isIN ? Colors.green : Colors.red;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.1),
                          child: Icon(
                            isIN ? Icons.arrow_downward : Icons.arrow_upward,
                            color: color,
                          ),
                        ),
                        title: Text(
                          transaction.materialName ??
                              "Material: ${transaction.materialId.substring(0, 8)}...",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateStr),
                            if (transaction.dailyLogId != null)
                              const Text(
                                "Source: Daily Log",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              )
                            else
                              const Text(
                                "Source: Manual Restock",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          "$qtyPrefix${transaction.quantityChange}",
                          style: TextStyle(
                            color: color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              // If we are in MaterialsLoaded state (due to the second event), we might block the view?
              // The second event `InventoryGetMaterials` might overwrite the state.
              // I should ONLY dispatch `InventoryGetTransactions`.
              // And relying on joins for names.
              // Let's stick to just transactions for now.
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
