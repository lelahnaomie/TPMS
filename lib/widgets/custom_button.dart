import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFullWidth;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? fontSize;
  final IconData? icon;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFullWidth = false,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.fontSize,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? const Color(0xFF0078D4);
    final Color txtColor = textColor ?? Colors.white;
    final double btnHeight = height ?? 56;
    final double txtSize = fontSize ?? 16;

    Widget buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(txtColor),
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (icon != null && !isLoading) ...[
          Icon(icon, size: txtSize + 2, color: txtColor),
          const SizedBox(width: 8),
        ],
        Text(
          isLoading ? 'Loading...' : text,
          style: TextStyle(
            fontSize: txtSize,
            fontWeight: FontWeight.bold,
            color: txtColor,
          ),
        ),
      ],
    );

    if (isOutlined) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: btnHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: bgColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: btnHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
          shadowColor: bgColor.withOpacity(0.3),
        ),
        child: buttonChild,
      ),
    );
  }
}
