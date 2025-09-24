import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomTheme {
  static const Color primaryColor = Color(0xFF249A00);
  static const Color secondaryColor = const Color(0xFFE4FFDC);

  Widget _submitButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'Submit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
