import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ShowBarChart extends StatelessWidget {
  final List<double> values;
  const ShowBarChart({required this.values, super.key});

  @override
  Widget build(BuildContext context) {
    const double barWidth = 15.0;
    final theme = Theme.of(context);
    // Use primary color for bars, or a specific chart color from palette if preferred.
    // Using gradient2 (pink/purplish) as it stands out well in both modes, or theme primary.
    // Let's use theme.colorScheme.primary.
    final barColor = theme.colorScheme.primary;

    // Issue 7 Fix: Ensure chart has a fixed max height of 100
    // If your scores are 0-10, change maxY to 10.
    // Based on usage in project_home_page (log.workScore * 10), the input values are 0-100.
    const double maxChartY = 100.0;

    return BarChart(
      BarChartData(
        maxY: maxChartY, // Forces the Y-axis to 100
        borderData: FlBorderData(
          border: Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(width: 3, color: theme.dividerColor),
            bottom: BorderSide(width: 3, color: theme.dividerColor),
          ),
        ),
        groupsSpace: 10,
        barGroups: List.generate(values.length, (index) {
          return BarChartGroupData(
            x: index + 1,
            barRods: [
              BarChartRodData(
                fromY: 0,
                toY: values[index],
                width: barWidth,
                color: barColor,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY:
                      maxChartY, // Light background bar to show full height potential
                  color: theme.dividerColor.withOpacity(0.1),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
