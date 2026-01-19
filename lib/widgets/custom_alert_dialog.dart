import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAlertDialog {
  /// Show a confirmation dialog that adapts to light/dark theme
  static Future<bool> showConfirmation({
    required String title,
    required String message,
    String confirmText = "Yes",
    String cancelText = "No",
    Color? confirmColor,
    Color? cancelColor,
  }) async {
    // Determine theme-aware colors
    final bool isDark = Get.isDarkMode;
    final Color backgroundColor = isDark ? Colors.grey[900]! : Colors.white;
    final Color titleColor = isDark ? Colors.white : Colors.black87;
    final Color messageColor = isDark ? Colors.grey[300]! : Colors.black54;
    final Color iconColor =
        confirmColor ?? (isDark ? Colors.tealAccent : Colors.redAccent);
    final Color cancelBtnColor =
        cancelColor ?? (isDark ? Colors.grey[700]! : Colors.grey);
    final Color confirmBtnColor =
        confirmColor ?? (isDark ? Colors.tealAccent : Colors.redAccent);

    return await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        backgroundColor: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 48, color: iconColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(fontSize: 16, color: messageColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cancelBtnColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Get.back(result: false);
                      },
                      child: Text(
                        cancelText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmBtnColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Get.back(result: true);
                      },
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    ).then((value) => value ?? false);
  }
}
