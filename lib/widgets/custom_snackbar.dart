import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarType { success, error, info, warning }

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Get.isDarkMode;
    late Color backgroundColor;
    late Color textColor;
    late Icon icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = isDark ? Colors.green[700]! : Colors.green[600]!;
        textColor = Colors.white;
        icon = Icon(Icons.check_circle, color: textColor);
        break;

      case SnackbarType.error:
        backgroundColor = isDark ? Colors.red[700]! : Colors.red[600]!;
        textColor = Colors.white;
        icon = Icon(Icons.error, color: textColor);
        break;

      case SnackbarType.warning:
        backgroundColor = isDark ? Colors.orange[700]! : Colors.orange[400]!;
        textColor = Colors.white;
        icon = Icon(Icons.warning_amber_rounded, color: textColor);
        break;

      case SnackbarType.info:
        backgroundColor = isDark ? Colors.blueGrey[800]! : Colors.blue[400]!;
        textColor = Colors.white;
        icon = Icon(Icons.info_outline, color: textColor);
        break;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: icon,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: duration,
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
      forwardAnimationCurve: Curves.easeOutBack,
      animationDuration: const Duration(milliseconds: 450),
    );
  }
}
