import 'package:flutter/material.dart';

class FormHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconBackgroundColor;
  final Color? titleColor;
  final double iconSize;
  final double titleFontSize;
  final double subtitleFontSize;

  const FormHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconBackgroundColor,
    this.titleColor,
    this.iconSize = 80,
    this.titleFontSize = 28,
    this.subtitleFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconBgColor = iconBackgroundColor ?? const Color(0xFF0078D4);
    final Color txtColor = titleColor ?? const Color(0xFF0078D4);

    return Column(
      children: [
        // Icon Container
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: iconBgColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: iconSize * 0.5,
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: txtColor,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleFontSize,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
