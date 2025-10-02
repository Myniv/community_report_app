import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class CustomTheme {
  static const Color green = Color(0xFF249A00);
  static const Color lightGreen = Color.fromARGB(255, 102, 235, 61);
  static const Color whiteKindaGreen = const Color(0xFFE4FFDC);

  static const BorderRadius borderRadius = BorderRadius.all(
    Radius.circular(15),
  );

  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final shortestSide = screenWidth < screenHeight
        ? screenWidth
        : screenHeight;

    final scaleFactor = shortestSide / 375.0;

    return (baseFontSize * scaleFactor).clamp(
      baseFontSize * 0.8,
      baseFontSize * 1.5,
    );
  }

  TextStyle superSmallFont2(
    Color color, [
    FontWeight? fontWeight,
    BuildContext? context,
  ]) {
    double fontSize = 10;
    if (context != null) {
      fontSize = _getResponsiveFontSize(context, 10);
    }

    return TextStyle(
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontSize: fontSize,
    );
  }

  TextStyle superSmallFont(
    Color color, [
    FontWeight? fontWeight,
    BuildContext? context,
  ]) {
    double fontSize = 12;
    if (context != null) {
      fontSize = _getResponsiveFontSize(context, 12);
    }

    return TextStyle(
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontSize: fontSize,
    );
  }

  TextStyle smallFont(
    Color color, [
    FontWeight? fontWeight,
    BuildContext? context,
  ]) {
    double fontSize = 14; // Body text
    if (context != null) {
      fontSize = _getResponsiveFontSize(context, 14);
    }

    return TextStyle(
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontSize: fontSize,
    );
  }

  TextStyle mediumFont(
    Color color, [
    FontWeight? fontWeight,
    BuildContext? context,
  ]) {
    double fontSize = 16; // Subtitle/Large body text
    if (context != null) {
      fontSize = _getResponsiveFontSize(context, 16);
    }

    return TextStyle(
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontSize: fontSize,
    );
  }

  TextStyle largeFont(
    Color color, [
    FontWeight? fontWeight,
    BuildContext? context,
  ]) {
    double fontSize = 20; // Title/Heading
    if (context != null) {
      fontSize = _getResponsiveFontSize(context, 20);
    }

    return TextStyle(
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontSize: fontSize,
      letterSpacing: 1.5,
    );
  }

  TextStyle superLargeFont(
    Color color, [
    FontWeight? fontWeight,
    BuildContext? context,
  ]) {
    double fontSize = 26; // Title/Heading
    if (context != null) {
      fontSize = _getResponsiveFontSize(context, 26);
    }

    return TextStyle(
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontSize: fontSize,
    );
  }

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return "${diff.inSeconds} seconds ago";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} minutes ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hours ago";
    } else if (diff.inDays < 30) {
      return "${diff.inDays} days ago";
    } else if (diff.inDays < 365) {
      return "${(diff.inDays / 30).floor()} months ago";
    } else {
      return "${(diff.inDays / 365).floor()} years ago";
    }
  }

  Widget customTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    Color? iconColor,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(borderRadius: CustomTheme.borderRadius),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        obscureText: obscureText,
        style: superSmallFont(Colors.black87, FontWeight.w400, context),
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: iconColor ?? CustomTheme.green)
              : null,
          labelText: label,
          hintText: hint,
          labelStyle: superSmallFont(Colors.black87, FontWeight.w400, context),
          hintStyle: superSmallFont(Colors.black54, FontWeight.w400, context),
          border: OutlineInputBorder(borderRadius: CustomTheme.borderRadius),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CustomTheme.green),
            borderRadius: CustomTheme.borderRadius,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: iconColor ?? CustomTheme.green,
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
        ),
        validator: validator,
      ),
    );
  }

  Widget customDropdown<T>({
    required BuildContext context,
    required T? value,
    required List<T> items,
    required String label,
    required String hint,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(borderRadius: CustomTheme.borderRadius),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  item.toString(),
                  style: superSmallFont(
                    Colors.black87,
                    FontWeight.w400,
                    context,
                  ),
                ),
              ),
            )
            .toList(),
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: iconColor ?? CustomTheme.green)
              : null,
          labelText: label,
          hintText: hint,
          labelStyle: superSmallFont(Colors.black87, FontWeight.w400, context),
          hintStyle: superSmallFont(Colors.black54, FontWeight.w400, context),
          border: OutlineInputBorder(borderRadius: CustomTheme.borderRadius),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CustomTheme.green),
            borderRadius: CustomTheme.borderRadius,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
        ),
        dropdownColor: Colors.white,
        onChanged: onChanged,
        validator: validator,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: iconColor ?? CustomTheme.green,
          size: 24,
        ),
      ),
    );
  }

  Widget customSelectDate({
    required BuildContext context,
    required String label,
    required String hint,
    required DateTime? selectedDate,
    required VoidCallback onPressed,
    IconData? icon,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: iconColor ?? CustomTheme.green)
              : Icon(Icons.calendar_month, color: CustomTheme.green),
          labelText: label,
          hintText: hint,
          labelStyle: superSmallFont(Colors.black87, FontWeight.w400, context),
          hintStyle: superSmallFont(Colors.black54, FontWeight.w400, context),
          border: OutlineInputBorder(borderRadius: CustomTheme.borderRadius),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CustomTheme.green),
            borderRadius: CustomTheme.borderRadius,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('MMM dd, yyyy').format(selectedDate)
              : 'No date selected',
          style: superSmallFont(Colors.black87, FontWeight.w400, context),
        ),
      ),
    );
  }

  Widget customSelectImage({
    required BuildContext context,
    required VoidCallback onPressed,
    String? profilePicturePath,
    File? selectedImageFile,
    String? label,
    bool isUploadingPhoto = false,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(borderRadius: CustomTheme.borderRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                label,
                style: superSmallFont(Colors.black87, FontWeight.w400, context),
              ),
            ),
          Center(
            child: InkWell(
              onTap: isUploadingPhoto ? null : onPressed,
              borderRadius: BorderRadius.circular(100),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: selectedImageFile != null
                    ? FileImage(selectedImageFile)
                    : (profilePicturePath != null &&
                          profilePicturePath.isNotEmpty)
                    ? NetworkImage(profilePicturePath)
                    : null,
                child:
                    (selectedImageFile == null &&
                        (profilePicturePath == null ||
                            profilePicturePath.isEmpty))
                    ? Icon(
                        icon ?? Icons.person,
                        color: iconColor ?? Colors.grey,
                        size: 60,
                      )
                    : null,
              ),
            ),
          ),
          if (isUploadingPhoto)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      ),
    );
  }

  Widget customActionButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    bool isLoading = false,
    required BuildContext context,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? green,
                  ),
                ),
              )
            : Icon(icon, size: 22),
        label: Text(
          isLoading ? "Processing..." : text,
          style: CustomTheme().mediumFont(
            foregroundColor ?? green,
            FontWeight.w700,
            context,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          foregroundColor: foregroundColor ?? green,
          shape: RoundedRectangleBorder(borderRadius: CustomTheme.borderRadius),
          elevation: 6,
          shadowColor: green.withOpacity(0.3),
        ),
      ),
    );
  }

  void customScaffoldMessage({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: smallFont(Colors.black, FontWeight.w600, context),
        ),
        backgroundColor: backgroundColor ?? CustomTheme.whiteKindaGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
