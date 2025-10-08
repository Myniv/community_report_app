import 'package:community_report_app/custom_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartBarVertical extends StatelessWidget {
  final Map<String, int> data;
  final String title;
  final Map<String, Color>? customColors;
  final int? maxItems;

  const ChartBarVertical({
    Key? key,
    required this.data,
    required this.title,
    this.customColors,
    this.maxItems,
  }) : super(key: key);

  static const List<Color> defaultColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.indigo,
  ];

  Color _getColor(String key, int index) {
    if (customColors != null && customColors!.containsKey(key)) {
      return customColors![key]!;
    }
    return defaultColors[index % defaultColors.length];
  }

  @override
  Widget build(BuildContext context) {
    var entries = data.entries.toList();
    if (maxItems != null && maxItems! < entries.length) {
      entries = entries.take(maxItems!).toList();
    }
    final processedData = Map.fromEntries(entries);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: CustomTheme().smallFont(
                Colors.black,
                FontWeight.bold,
                context,
              ),
            ),

            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: processedData.isNotEmpty
                  ? BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(processedData),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final key = processedData.keys.elementAt(
                                groupIndex,
                              );
                              return BarTooltipItem(
                                '$key\n${rod.toY.toInt()}',
                                TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 &&
                                    index < processedData.length) {
                                  final key = processedData.keys.elementAt(
                                    index,
                                  );
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      key,
                                      style: TextStyle(fontSize: 10),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }
                                return Text('');
                              },
                              reservedSize: 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _createBarGroups(processedData),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),
                      ),
                    )
                  : Center(child: Text('No data available')),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(Map<String, int> data) {
    if (data.isEmpty) return 10;
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    return (maxValue + 2).toDouble();
  }

  List<BarChartGroupData> _createBarGroups(Map<String, int> data) {
    return data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final dataEntry = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: dataEntry.value.toDouble(),
            color: _getColor(dataEntry.key, index),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }
}
