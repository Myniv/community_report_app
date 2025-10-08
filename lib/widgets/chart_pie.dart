import 'package:community_report_app/custom_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartPie extends StatefulWidget {
  final Map<String, int> data;
  final String title;
  final Map<String, Color>? customColors;
  final double centerSpaceRadius; // 0 = pie, >0 = doughnut
  final bool showLegend;
  final bool showPercentage;

  const ChartPie({
    Key? key,
    required this.data,
    required this.title,
    this.customColors,
    this.centerSpaceRadius = 40, 
    this.showLegend = true,
    this.showPercentage = true,
  }) : super(key: key);

  @override
  State<ChartPie> createState() => _ChartPieState();
}

class _ChartPieState extends State<ChartPie> {
  int touchedIndex = -1;

  // Default color palette
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
    if (widget.customColors != null && widget.customColors!.containsKey(key)) {
      return widget.customColors![key]!;
    }
    return defaultColors[index % defaultColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.data.values.fold(0, (sum, value) => sum + value);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
               style: CustomTheme().smallFont(
                Colors.black,
                FontWeight.bold,
                context,
              ),
            ),
            SizedBox(height: 16),

            _buildLegend(),

            SizedBox(height: 16),

            SizedBox(
              height: 250,
              child: total > 0
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                            ),
                            sections: _createSections(),
                            sectionsSpace: 2,
                            centerSpaceRadius: widget.centerSpaceRadius,
                            borderData: FlBorderData(show: false),
                          ),
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

  List<PieChartSectionData> _createSections() {
    final total = widget.data.values.fold(0, (sum, value) => sum + value);
    final entries = widget.data.entries.toList();

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched
          ? (widget.centerSpaceRadius > 0 ? 65.0 : 110.0)
          : (widget.centerSpaceRadius > 0 ? 55.0 : 100.0);

      final percentage = total > 0 ? (data.value / total * 100) : 0;
      final displayText = widget.showPercentage
          ? '${percentage.toStringAsFixed(1)}%'
          : '${data.value}';

      return PieChartSectionData(
        color: _getColor(data.key, index),
        value: data.value.toDouble(),
        title: displayText,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.data.entries.toList().asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getColor(data.key, index),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Text('${data.key}: ${data.value}', style: TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }
}
