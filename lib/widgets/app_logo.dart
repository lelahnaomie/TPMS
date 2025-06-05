import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppLogo({
    super.key,
    this.size = 80,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? const Color(0xFF0078D4);
    final Color icColor = iconColor ?? Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: icColor,
              width: 3,
            ),
          ),
          child: Icon(
            Icons.tire_repair,
            color: icColor,
            size: size * 0.25,
          ),
        ),
      ),
    );
  }
}
