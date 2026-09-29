import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final bool isHealth;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.isHealth = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? AppConstants.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: effectiveColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (isHealth) ...[
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    Flexible(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
