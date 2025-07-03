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
    final thinBarWidth = 2.0; // width for the dummy max bar

    return BarChart(
      BarChartData(
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
          values.length + 1, // one extra bar for dummy max
          (index) {
            if (index < values.length) {
              return BarChartGroupData(
                x: index + 1,
                barRods: [
                  BarChartRodData(
                    fromY: 0,
                    toY: values[index],
                    width: barWidth,
                    color: barColor,
                  ),
                ],
              );
            } else {
              // Final thin dummy bar with value 100
              return BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    fromY: 0,
                    toY: 100,
                    width: thinBarWidth,
                    color: Colors.transparent, // make it invisible
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
