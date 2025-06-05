import 'package:flutter/material.dart';

class AuthRedirect extends StatelessWidget {
  final String question;
  final String actionText;
  final VoidCallback onPressed;
  final Color? actionTextColor;
  final double fontSize;

  const AuthRedirect({
    super.key,
    required this.question,
    required this.actionText,
    required this.onPressed,
    this.actionTextColor,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final Color actionColor = actionTextColor ?? const Color(0xFF0078D4);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionText,
            style: TextStyle(
              fontSize: fontSize,
              color: actionColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
