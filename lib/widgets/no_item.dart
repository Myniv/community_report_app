import 'package:community_report_app/custom_theme.dart';
import 'package:flutter/material.dart';

class NoItem extends StatelessWidget {
  final String title;
  final String subTitle;

  const NoItem({Key? key, required this.title, required this.subTitle})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.warning, size: 48, color: Colors.greenAccent),
          Text(
            title,
            style: CustomTheme().mediumFont(Colors.white, null, context),
          ),
          SizedBox(height: 8),
          Text(
            subTitle,
            style: CustomTheme().smallFont(Colors.grey, null, context),
          ),
        ],
      ),
    );
  }
}
