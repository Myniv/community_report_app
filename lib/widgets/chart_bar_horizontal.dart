import 'package:community_report_app/custom_theme.dart';
import 'package:flutter/material.dart';

class ChartBarHorizontal extends StatelessWidget {
  final Map<String, int> data;
  final String title;
  final Map<String, Color>? customColors;
  final int? maxItems;

  const ChartBarHorizontal({
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
            ...processedData.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final maxValue = processedData.values.isEmpty
                  ? 1
                  : processedData.values.reduce((a, b) => a > b ? a : b);
              final double percentage = maxValue > 0
                  ? data.value / maxValue
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data.key,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${data.value}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getColor(data.key, index),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getColor(data.key, index),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
