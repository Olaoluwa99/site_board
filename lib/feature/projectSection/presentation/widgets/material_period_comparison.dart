import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/material_report_control_cubit.dart';

class MaterialPeriodComparison extends StatelessWidget {
  const MaterialPeriodComparison({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialReportControlCubit, MaterialReportControlState>(
      builder: (context, state) {
        // Only show if we have a valid date range selected
        if (state.startDate == null || state.endDate == null) {
          return const SizedBox.shrink();
        }

        final currentUsed = state.totalUsed;
        final previousUsed = state.previousTotalUsed;

        // Avoid division by zero
        double percentChange = 0;
        if (previousUsed > 0) {
          percentChange = ((currentUsed - previousUsed) / previousUsed) * 100;
        } else if (currentUsed > 0) {
          percentChange =
              100; // technically infinite, but 100% growth from 0 is a fair simplistic rep
        }

        final isIncrease = percentChange > 0;
        final isDecrease = percentChange < 0;
        final isFlat = percentChange == 0;

        final icon =
            isIncrease
                ? Icons.arrow_upward
                : (isDecrease ? Icons.arrow_downward : Icons.remove);
        // Note: For "Usage", Increase is bad/intense (Orange), Decrease is good/slow (Green).

        final displayColor =
            isIncrease
                ? Colors.orange.shade800
                : (isDecrease ? Colors.green.shade700 : Colors.grey);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: displayColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: displayColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: displayColor),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Usage Trend (${state.dateRangeLabel})",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        "${percentChange.abs().toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: displayColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isFlat
                            ? "No change"
                            : (isIncrease
                                ? "Increase vs prev. period"
                                : "Decrease vs prev. period"),
                        style: TextStyle(fontSize: 12, color: displayColor),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Prev: ${_formatQty(previousUsed)}",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    "Curr: ${_formatQty(currentUsed)}",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatQty(double val) {
    if (val % 1 == 0) return val.toInt().toString();
    return val.toStringAsFixed(1);
  }
}
