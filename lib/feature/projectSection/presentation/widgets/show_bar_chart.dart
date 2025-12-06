import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

class ShowBarChart extends StatelessWidget {
  final List<double> values;
  const ShowBarChart({required this.values, super.key});

  @override
  Widget build(BuildContext context) {
    final barWidth = 15.0;
    final barColor = AppPalette.gradient3;

    // Issue 7 Fix: Ensure chart has a fixed max height of 100
    // If your scores are 0-10, change maxY to 10.
    // Based on usage in project_home_page (log.workScore * 10), the input values are 0-100.
    const double maxChartY = 100.0;

    return BarChart(
      BarChartData(
        maxY: maxChartY, // Forces the Y-axis to 100
        borderData: FlBorderData(
          border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(width: 3, color: AppPalette.whiteColor),
            bottom: BorderSide(width: 3, color: AppPalette.whiteColor),
          ),
        ),
        groupsSpace: 10,
        barGroups: List.generate(
          values.length,
              (index) {
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
                      toY: maxChartY, // Light background bar to show full height potential
                      color: AppPalette.borderColor,
                    )
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}