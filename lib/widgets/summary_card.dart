import 'package:community_report_app/custom_theme.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: CustomTheme().mediumFont(
                Colors.grey,
                FontWeight.bold,
                context,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: CustomTheme().largeFont(color, FontWeight.bold, context),
            ),
          ],
        ),
      ),
    );
  }
}
