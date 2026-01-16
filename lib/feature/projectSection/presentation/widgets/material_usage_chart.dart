import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:site_board/feature/projectSection/domain/entities/material_transaction.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/material_report_control_cubit.dart';

class MaterialUsageChart extends StatelessWidget {
  const MaterialUsageChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialReportControlCubit, MaterialReportControlState>(
      builder: (context, state) {
        // Rule: Hide chart if multiple materials selected (or none explicitly selected, implying ALL)
        // Wait, prompt says: "If 'All Materials' is selected -> Hide Chart".
        // But usually "All" is empty list or special flag. In our state, empty list = all.
        // So validation:
        if (state.selectedMaterialIds.isEmpty ||
            state.selectedMaterialIds.length > 1) {
          return const SizedBox.shrink();
          // Or return a placeholder: return Center(child: Text("Select a single material to view trends"));
        }

        if (state.filteredTransactions.isEmpty) {
          return const SizedBox.shrink();
        }

        final pointsUsed = _calculateCumulativeUsage(
          state.filteredTransactions,
        );
        // For stock level, we need a baseline. But since we only have filtered txns,
        // accurate absolute stock level is hard unless we have "Opening Stock".
        // We can show "Net Change" relative to start of period.
        final pointsStock = _calculateRelativeStock(state.filteredTransactions);

        return Container(
          height: 220,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Trends (Selected Period)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          reservedSize: 30,
                          showTitles: true,
                          getTitlesWidget:
                              (val, meta) => Text(
                                val.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Usage Line (Red)
                      LineChartBarData(
                        spots: pointsUsed,
                        isCurved: true,
                        color: Colors.redAccent,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.redAccent.withOpacity(0.1),
                        ),
                      ),
                      // Stock Line (Green/Blue)
                      LineChartBarData(
                        spots: pointsStock,
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendItem(
                    color: Colors.redAccent,
                    label: "Cumulative Usage",
                  ),
                  const SizedBox(width: 16),
                  _LegendItem(
                    color: Colors.blueAccent,
                    label: "Stock Level (Relative)",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<FlSpot> _calculateCumulativeUsage(
    List<MaterialTransaction> transactions,
  ) {
    // Sort chronological
    final sorted = List<MaterialTransaction>.from(transactions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    double currentUsage = 0;
    List<FlSpot> spots = [];

    // We want X axis to be relative time? Or just index?
    // Using simple index for smoothness, or normalize time.
    // For MVP transparency, using index distribution is safer to avoid gaps.

    for (int i = 0; i < sorted.length; i++) {
      final t = sorted[i];
      if (t.type == TransactionType.OUT) {
        currentUsage += t.quantityChange;
      }
      spots.add(FlSpot(i.toDouble(), currentUsage));
    }
    return spots;
  }

  List<FlSpot> _calculateRelativeStock(List<MaterialTransaction> transactions) {
    final sorted = List<MaterialTransaction>.from(transactions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    double currentStock = 0; // Relative to 0 at start
    List<FlSpot> spots = [];

    for (int i = 0; i < sorted.length; i++) {
      final t = sorted[i];
      if (t.type == TransactionType.IN) {
        currentStock += t.quantityChange;
      } else {
        currentStock -= t.quantityChange;
      }
      spots.add(FlSpot(i.toDouble(), currentStock));
    }
    return spots;
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
