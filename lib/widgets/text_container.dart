import 'package:community_report_app/custom_theme.dart';
import 'package:flutter/material.dart';

class TextContainer extends StatelessWidget {
  final String text;
  final bool? category;
  const TextContainer({Key? key, required this.text, this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color colorContainer = Colors.white;
    Color colorFont = Colors.black;
    switch (text) {
      case 'Pending' || 'pending':
        colorContainer = Colors.grey;
        colorFont = CustomTheme.whiteKindaGreen;
        break;
      case 'On Progress' || 'on progress':
        colorContainer = Colors.yellow;
        colorFont = Colors.black;
        break;
      case 'Resolved' || 'resolved':
        colorContainer = Colors.green;
        colorFont = CustomTheme.whiteKindaGreen;
        break;
      case 'Low' || 'low':
        colorContainer = Colors.blue;
        colorFont = CustomTheme.whiteKindaGreen;
        break;
      case 'Medium' || 'medium':
        colorFont = CustomTheme.whiteKindaGreen;
        colorContainer = Colors.orange;
        break;
      case 'High' || 'high':
        colorFont = CustomTheme.whiteKindaGreen;
        colorContainer = Colors.red;
        break;
      default:
        colorFont = CustomTheme.green;
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
            color: colorFont,
            fontSize: 13,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
