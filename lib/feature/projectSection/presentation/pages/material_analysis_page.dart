import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:site_board/core/common/widgets/loader.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/inventory_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/material_report_control_cubit.dart';
import 'package:site_board/feature/projectSection/presentation/utils/pdf_generator.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/material_period_comparison.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/material_report_filter_bar.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/material_report_summary_cards.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/material_usage_chart.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/transaction_ledger_item.dart';
import 'package:site_board/feature/projectSection/presentation/widgets/offline_toolbar.dart';
import 'package:site_board/init_dependencies.dart';

class MaterialAnalysisPage extends StatelessWidget {
  final String projectId;

  const MaterialAnalysisPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  serviceLocator<InventoryBloc>()
                    ..add(InventoryGetTransactions(projectId: projectId)),
        ),
        BlocProvider(create: (_) => MaterialReportControlCubit()),
      ],
      child: const _MaterialAnalysisView(),
    );
  }
}

class _MaterialAnalysisView extends StatelessWidget {
  const _MaterialAnalysisView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              final cubit = context.read<MaterialReportControlCubit>();
              // We can pass project ID via context or other means if needed for header,
              // but state usually suffices for data.
              // Note: The original page had hardcoded "Project Report" string or similar.
              // We'll keep it simple.
              PdfGenerator.generateAndPrint(cubit.state, "Project Analysis");
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<InventoryBloc, InventoryState>(
            listener: (context, state) {
              if (state is InventoryFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error)));
              }
              if (state is InventoryTransactionsLoaded) {
                context.read<MaterialReportControlCubit>().setTransactions(
                  state.transactions,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, inventoryState) {
            if (inventoryState is InventoryLoading) {
              return const Loader();
            }

            return BlocBuilder<
              MaterialReportControlCubit,
              MaterialReportControlState
            >(
              builder: (context, state) {
                if (state.status == ReportControlStatus.initial &&
                    inventoryState is! InventoryTransactionsLoaded) {
                  return const SizedBox.shrink();
                }

                final transactions = state.filteredTransactions;

                final Map<String, List<dynamic>> grouped;
                if (state.viewMode == ReportViewMode.trust) {
                  grouped = _groupByActor(transactions);
                } else {
                  grouped = _groupByDate(transactions);
                }

                return Column(
                  children: [
                    const OfflineToolbar(),
                    const MaterialReportSummaryCards(),
                    const MaterialReportFilterBar(),
                    const MaterialPeriodComparison(),
                    const MaterialUsageChart(),
                    const Divider(height: 1),
                    Expanded(
                      child:
                          transactions.isEmpty
                              ? const Center(
                                child: Text(
                                  "No transactions found matching filters.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: grouped.keys.length,
                                itemBuilder: (context, index) {
                                  final headerKey = grouped.keys.elementAt(
                                    index,
                                  );
                                  final txns = grouped[headerKey]!;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _SectionHeader(
                                        title: headerKey,
                                        isActor:
                                            state.viewMode ==
                                            ReportViewMode.trust,
                                      ),
                                      ...txns.map(
                                        (t) => TransactionLedgerItem(
                                          transaction: t,
                                          showFinancials: state.showFinancials,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Map<String, List<dynamic>> _groupByDate(List<dynamic> list) {
    final Map<String, List<dynamic>> map = {};
    for (var item in list) {
      final key = DateFormat('EEE, MMM d').format(item.timestamp);
      if (!map.containsKey(key)) {
        map[key] = [];
      }
      map[key]!.add(item);
    }
    return map;
  }

  Map<String, List<dynamic>> _groupByActor(List<dynamic> list) {
    final Map<String, List<dynamic>> map = {};
    for (var item in list) {
      final key = item.actorName ?? 'Unknown User';
      if (!map.containsKey(key)) {
        map[key] = [];
      }
      map[key]!.add(item);
    }
    return map;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isActor;
  const _SectionHeader({required this.title, required this.isActor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(
            isActor ? Icons.person : Icons.calendar_today,
            size: 16,
            color: Colors.blueGrey,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.blueGrey.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
