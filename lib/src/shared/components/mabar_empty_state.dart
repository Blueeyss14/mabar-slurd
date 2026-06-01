import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';

class MabarEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const MabarEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: CustomColors.mabarTextTertiary),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CustomColors.mabarTextPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: CustomColors.mabarTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
