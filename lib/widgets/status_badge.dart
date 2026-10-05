import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';

enum StatusBadgeType {
  success,
  warning,
  danger,
  primary,
  neutral,
}

class StatusBadge extends StatelessWidget {
  final String status;
  final StatusBadgeType? type;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.type,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color border;

    if (type != null) {
      switch (type!) {
        case StatusBadgeType.success:
          bg = AppTheme.success.withOpacity(0.12);
          text = AppTheme.success;
          border = AppTheme.success.withOpacity(0.3);
          break;
        case StatusBadgeType.warning:
          bg = AppTheme.warning.withOpacity(0.12);
          text = AppTheme.warning;
          border = AppTheme.warning.withOpacity(0.3);
          break;
        case StatusBadgeType.danger:
          bg = AppTheme.error.withOpacity(0.12);
          text = AppTheme.error;
          border = AppTheme.error.withOpacity(0.3);
          break;
        case StatusBadgeType.primary:
          bg = AppTheme.primary.withOpacity(0.12);
          text = AppTheme.primary;
          border = AppTheme.primary.withOpacity(0.3);
          break;
        case StatusBadgeType.neutral:
          bg = AppTheme.borderLight.withOpacity(0.4);
          text = AppTheme.textSecondary;
          border = AppTheme.border;
          break;
      }
    } else {
      final s = status.toLowerCase();
      if (s == 'confirmed' || s == 'completed' || s == 'now_showing' || s == 'active' || s == 'popular' || s == 'success' || s == 'paid') {
        bg = AppTheme.success.withOpacity(0.12);
        text = AppTheme.success;
        border = AppTheme.success.withOpacity(0.3);
      } else if (s == 'cancelled' || s == 'inactive' || s == 'ended' || s == 'failed') {
        bg = AppTheme.error.withOpacity(0.12);
        text = AppTheme.error;
        border = AppTheme.error.withOpacity(0.3);
      } else if (s == 'upcoming' || s == 'scheduled' || s == 'pending' || s == 'initiated') {
        bg = AppTheme.warning.withOpacity(0.12);
        text = AppTheme.warning;
        border = AppTheme.warning.withOpacity(0.3);
      } else if (s == 'recliner' || s == 'platinum' || s == 'premium') {
        bg = AppTheme.secondary.withOpacity(0.12);
        text = AppTheme.secondary;
        border = AppTheme.secondary.withOpacity(0.3);
      } else {
        bg = AppTheme.borderLight.withOpacity(0.4);
        text = AppTheme.textSecondary;
        border = AppTheme.border;
      }
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          color: text,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
