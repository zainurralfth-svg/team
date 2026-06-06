import 'package:flutter/material.dart';
import '../Core/Colour.dart';
import 'custom_text.dart';

enum NotificationType { success, error, warning, info }

class NotificationHelper {
  static void show(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;

    // Bersihkan SnackBar yang sedang tampil agar tidak menumpuk
    ScaffoldMessenger.of(context).clearSnackBars();

    Color bgColor;
    IconData icon;

    switch (type) {
      case NotificationType.success:
        bgColor = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case NotificationType.error:
        bgColor = AppColors.error;
        icon = Icons.error_outline;
        break;
      case NotificationType.warning:
        bgColor = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case NotificationType.info:
        bgColor = AppColors.info;
        icon = Icons.info_outline;
        break;
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    // Ambil padding top (notch / status bar) agar tidak terpotong
    final double topPadding = MediaQuery.of(context).padding.top;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.up,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.only(
          bottom: screenHeight - topPadding - 160, // Posisikan di bagian atas layar
          left: 20,
          right: 20,
        ),
        duration: duration,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: CustomText(
                  message,
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
