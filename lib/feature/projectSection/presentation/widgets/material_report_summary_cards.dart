import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_board/feature/projectSection/presentation/bloc/material_report_control_cubit.dart';

class MaterialReportSummaryCards extends StatelessWidget {
  const MaterialReportSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialReportControlCubit, MaterialReportControlState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: "Total Added",
                      value: "+${_formatNum(state.totalAdded)}",
                      color: Colors.green.shade700,
                      icon: Icons.download,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SummaryCard(
                      label: "Total Used",
                      value: "-${_formatNum(state.totalUsed)}",
                      color: Colors.red.shade700,
                      icon: Icons.upload,
                    ),
                  ),
                ],
              ),
              if (state.showFinancials) ...[
                const SizedBox(height: 8),
                _SummaryCard(
                  label: "Total Spend",
                  value: "\$${_formatMoney(state.totalSpend)}",
                  color: Colors.blue.shade800,
                  icon: Icons.attach_money,
                  isFullWidth: true,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatNum(double val) {
    // Remove trailing zeros if integer
    if (val % 1 == 0) return val.toInt().toString();
    return val.toStringAsFixed(1);
  }

  String _formatMoney(double val) {
    return val.toStringAsFixed(2);
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isFullWidth;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
