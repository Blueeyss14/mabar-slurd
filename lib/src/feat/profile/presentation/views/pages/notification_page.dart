import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/mabar_empty_state.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.check_circle_outline,
      'title': 'Booking Berhasil',
      'body': 'Tempat kamu di GG Arena sudah aman. Sampai jumpa!',
      'time': '5 menit lalu',
      'color': CustomColors.mabarGreen,
    },
    {
      'icon': Icons.local_offer_outlined,
      'title': 'Promo Spesial',
      'body': 'Diskon 20% untuk booking PC Gaming akhir pekan ini.',
      'time': '2 jam lalu',
      'color': CustomColors.mabarPurpleLight,
    },
    {
      'icon': Icons.access_time,
      'title': 'Pengingat',
      'body': 'Booking kamu dimulai 1 jam lagi di CyberZone.',
      'time': 'Kemarin',
      'color': CustomColors.mabarYellow,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: CustomColors.mabarTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _notifications.isEmpty
          ? const MabarEmptyState(
              icon: Icons.notifications_off_outlined,
              title: "Belum ada notifikasi",
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return _buildNotificationCard(item);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (item['color'] as Color).withValues(alpha: 0.15),
            ),
            child: Icon(item['icon'] as IconData, color: item['color'] as Color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['body'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CustomColors.mabarTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['time'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CustomColors.mabarTextTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
