import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_palette.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.palette.mutedText),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: context.palette.secondaryText,
          ),
        ),
      ],
    );
  }
}
