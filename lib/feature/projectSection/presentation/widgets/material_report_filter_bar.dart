import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/material_report_control_cubit.dart';

class MaterialReportFilterBar extends StatelessWidget {
  const MaterialReportFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialReportControlCubit, MaterialReportControlState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Date Filter
              ActionChip(
                avatar: const Icon(Icons.calendar_today, size: 16),
                label: Text(state.dateRangeLabel),
                onPressed: () => _pickDateRange(context),
              ),
              const SizedBox(width: 8),

              // Transaction Type Filter
              PopupMenuButton<TransactionFilterType>(
                initialValue: state.filterType,
                onSelected:
                    (val) => context
                        .read<MaterialReportControlCubit>()
                        .setFilterType(val),
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: TransactionFilterType.all,
                        child: Text("All Transactions"),
                      ),
                      const PopupMenuItem(
                        value: TransactionFilterType.onlyIn,
                        child: Text("Restocks Only (IN)"),
                      ),
                      const PopupMenuItem(
                        value: TransactionFilterType.onlyOut,
                        child: Text("Usage Only (OUT)"),
                      ),
                    ],
                child: Chip(
                  label: Text(_getTypeLabel(state.filterType)),
                  deleteIcon: const Icon(Icons.arrow_drop_down, size: 18),
                  onDeleted: () {}, // Just for the icon
                ),
              ),
              const SizedBox(width: 8),

              // Materials Filter
              FilterChip(
                label: Text(
                  state.selectedMaterialIds.isEmpty
                      ? "Materials"
                      : "${state.selectedMaterialIds.length} Selected",
                ),
                selected: state.selectedMaterialIds.isNotEmpty,
                onSelected: (_) => _showMaterialFilterDialog(context, state),
              ),
              const SizedBox(width: 8),

              // Financials Toggle
              FilterChip(
                label: const Text('Show Money'),
                selected: state.showFinancials,
                onSelected:
                    (val) =>
                        context
                            .read<MaterialReportControlCubit>()
                            .toggleFinancials(),
                selectedColor: Colors.green.withOpacity(0.2),
                checkmarkColor: Colors.green,
              ),
              const SizedBox(width: 8),

              // View Mode Toggle (Ledger / Trust)
              ChoiceChip(
                label: Text(
                  state.viewMode == ReportViewMode.ledger
                      ? "Ledger View"
                      : "Trust View",
                ),
                avatar: Icon(
                  state.viewMode == ReportViewMode.ledger
                      ? Icons.list
                      : Icons.verified_user,
                  size: 16,
                ),
                selected: state.viewMode == ReportViewMode.trust,
                onSelected: (val) {
                  context.read<MaterialReportControlCubit>().setViewMode(
                    val ? ReportViewMode.trust : ReportViewMode.ledger,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTypeLabel(TransactionFilterType type) {
    switch (type) {
      case TransactionFilterType.all:
        return "All Types";
      case TransactionFilterType.onlyIn:
        return "Restocks";
      case TransactionFilterType.onlyOut:
        return "Usage";
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final cubit = context.read<MaterialReportControlCubit>();
    final initialDateRange = DateTimeRange(
      start:
          cubit.state.startDate ??
          DateTime.now().subtract(const Duration(days: 30)),
      end: cubit.state.endDate ?? DateTime.now(),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialDateRange,
    );

    if (picked != null) {
      final label =
          "${DateFormat('MMM d').format(picked.start)} - ${DateFormat('MMM d').format(picked.end)}";
      cubit.updateDateRange(picked.start, picked.end, label);
    }
  }

  void _showMaterialFilterDialog(
    BuildContext context,
    MaterialReportControlState initialState,
  ) {
    // Extract unique materials from all transactions
    final Map<String, String> materialMap = {};
    for (var t in initialState.allTransactions) {
      if (t.materialName != null) {
        materialMap[t.materialId] = t.materialName!;
      } else {
        materialMap.putIfAbsent(
          t.materialId,
          () => "Unknown (${t.materialId.substring(0, 4)}...)",
        );
      }
    }

    if (materialMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No material records found to filter.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        // We use BlocBuilder here so the dialog rebuilds when selection changes.
        // We capture the cubit from the parent context.
        final cubit = context.read<MaterialReportControlCubit>();

        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<
            MaterialReportControlCubit,
            MaterialReportControlState
          >(
            builder: (context, state) {
              return AlertDialog(
                title: const Text("Filter by Material"),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children:
                        materialMap.entries.map((entry) {
                          final isSelected = state.selectedMaterialIds.contains(
                            entry.key,
                          );
                          return CheckboxListTile(
                            title: Text(entry.value),
                            value: isSelected,
                            activeColor: Colors.blueGrey,
                            onChanged: (val) {
                              cubit.toggleMaterial(entry.key);
                            },
                          );
                        }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text("Done"),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
