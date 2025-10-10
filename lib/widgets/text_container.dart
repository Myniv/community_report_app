import 'package:community_report_app/custom_theme.dart';
import 'package:flutter/material.dart';

class TextContainer extends StatelessWidget {
  final String text;
  final bool? category;
  final IconData? icon;
  final bool? useIcon;
  final Color? fontColor;
  final Color? containerColor;
  final Color? borderColor;
  final Color? iconColor;
  const TextContainer({
    Key? key,
    required this.text,
    this.category,
    this.icon,
    this.fontColor,
    this.containerColor,
    this.iconColor,
    this.borderColor,
    this.useIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color colorContainer = Colors.white;
    Color colorFont = Colors.black;
    Color colorIcon = Colors.black;
    Color colorBorder = Colors.black;
    IconData iconIcon = Icons.circle;
    switch (text) {
      case 'Pending' || 'pending':
        colorContainer = Colors.transparent;
        colorFont = Colors.grey;
        colorIcon = Colors.grey;
        colorBorder = Colors.grey;
        iconIcon = Icons.question_mark;
        break;
      case 'On Progress' || 'on progress':
        colorContainer = Colors.transparent;
        colorFont = Colors.yellow;
        colorIcon = Colors.yellow;
        colorBorder = Colors.yellow;
        iconIcon = Icons.warning;
        break;
      case 'Resolved' || 'resolved':
        colorContainer = Colors.transparent;
        colorFont = Colors.green;
        colorIcon = Colors.green;
        colorBorder = Colors.green;
        iconIcon = Icons.check;
        break;
      case 'Low' || 'low':
        colorContainer = Colors.transparent;
        colorFont = Colors.blue;
        colorIcon = Colors.blue;
        colorBorder = Colors.blue;
        break;
      case 'Medium' || 'medium':
        colorContainer = Colors.transparent;
        colorFont = Colors.orange;
        colorIcon = Colors.orange;
        colorBorder = Colors.orange;
        break;
      case 'High' || 'high':
        colorContainer = Colors.transparent;
        colorFont = Colors.red;
        colorIcon = Colors.red;
        colorBorder = Colors.red;
        break;
      default:
        colorFont = CustomTheme.green;
        colorContainer = CustomTheme.whiteKindaGreen;
        Color colorIcon = Colors.green;
        Color colorBorder = Colors.green;
    }

    if (category == true) {
      colorContainer = CustomTheme.whiteKindaGreen;
    }

    if (fontColor != null) {
      colorFont = fontColor!;
    }
    if (containerColor != null) {
      colorContainer = containerColor!;
    }

    if (iconColor != null) {
      colorIcon = iconColor!;
    }

    if (borderColor != null) {
      colorBorder = borderColor!;
    }

    return Container(
      // width: 57,
      height: 25,
      decoration: BoxDecoration(
        color: colorContainer,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: colorBorder, width: 1),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            icon != null || useIcon == true
                ? Icon(icon!, size: 20, color: colorIcon)
                : useIcon == false
                ? SizedBox()
                : Icon(iconIcon, size: 20, color: colorIcon),
            Text(
              CustomTheme().capitalizeEachWord(text),
              style: TextStyle(
                color: colorFont,
                fontSize: 13,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
