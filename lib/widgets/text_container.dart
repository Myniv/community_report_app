import 'package:community_report_app/custom_theme.dart';
import 'package:flutter/material.dart';

class TextContainer extends StatelessWidget {
  final String text;
  final bool? category;
  const TextContainer({Key? key, required this.text, this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color colorContainer = Colors.white;
    switch (text) {
      case 'Pending' || 'pending':
        colorContainer = Colors.grey;
        break;
      case 'On Progress' || 'on progress':
        colorContainer = Colors.yellow;
        break;
      case 'Resolved' || 'resolved':
        colorContainer = Colors.green;
        break;
      case 'Low' || 'low':
        colorContainer = Colors.blue;
        break;
      case 'Medium' || 'medium':
        colorContainer = Colors.orange;
        break;
      case 'High' || 'high':
        colorContainer = Colors.red;
        break;
      default:
        colorContainer = CustomTheme.whiteKindaGreen;
    }

    if(category == true) {
      colorContainer = CustomTheme.whiteKindaGreen;
    }
    return Container(
      // width: 57,
      height: 25,
      decoration: BoxDecoration(
        color: colorContainer,
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          CustomTheme().capitalizeEachWord(text),
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
