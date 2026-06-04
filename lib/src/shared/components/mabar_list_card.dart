import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';

class MabarListCard extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? date;
  final String? time;
  final int? total;
  final String? status;
  final VoidCallback? onTap;

  const MabarListCard({
    super.key,
    this.title,
    this.subTitle,
    this.date,
    this.time,
    this.total,
    this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: CustomColors.mabarSurfaceCard,
          border: Border.all(color: CustomColors.mabarBorderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: CustomColors.mabarPurpleBg,
                  ),
                  child: const Icon(
                    Icons.sports_esports,
                    color: CustomColors.mabarPurpleLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? 'Title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CustomColors.mabarTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subTitle ?? 'Sub Title',
                        style: const TextStyle(
                          fontSize: 13,
                          color: CustomColors.mabarTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(Icons.calendar_month_outlined, date ?? 'Date'),
                const SizedBox(width: 10),
                _buildInfoChip(Icons.access_time_rounded, time ?? 'Time'),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(
              height: 1,
              color: CustomColors.mabarBorderSubtle,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Total Bayar',
                  style: TextStyle(
                    fontSize: 15,
                    color: CustomColors.mabarTextSecondary,
                  ),
                ),
                Text(
                  'Rp ${_formatRupiah((total ?? 0) * 1000)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.mabarCyan,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: CustomColors.mabarSurfaceInput,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: CustomColors.mabarTextSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: CustomColors.mabarTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  Widget _buildStatusBadge() {
    final String label = status ?? 'Selesai';
    Color color;
    IconData icon;
    switch (label) {
      case 'Berlangsung':
        color = CustomColors.mabarYellow;
        icon = Icons.bolt;
        break;
      case 'Dibatalkan':
        color = Colors.redAccent;
        icon = Icons.close;
        break;
      default:
        color = CustomColors.mabarGreen;
        icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color.withValues(alpha: 0.15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
