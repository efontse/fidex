import 'package:flutter/material.dart';
import '../constants/colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label = status.replaceAll('_', ' ').toUpperCase();

    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
      case 'approved':
      case 'active':
        bg = AppColors.statusSuccessBg;
        fg = AppColors.statusSuccess;
        break;
      case 'in_transit':
      case 'processing':
      case 'pending':
        bg = AppColors.statusWarningBg;
        fg = AppColors.statusWarning;
        break;
      case 'paid':
      case 'assigned':
        bg = AppColors.statusInfoBg;
        fg = AppColors.statusInfo;
        break;
      case 'cancelled':
      case 'failed':
      case 'banned':
      case 'inactive':
        bg = AppColors.statusErrorBg;
        fg = AppColors.statusError;
        break;
      default:
        bg = AppColors.limeTint;
        fg = AppColors.primaryDark;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
