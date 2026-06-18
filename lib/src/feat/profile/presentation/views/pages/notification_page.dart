import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/core/formatters.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/mabar_empty_state.dart';

/// Notifikasi diturunkan dari aktivitas booking user (data asli Firestore).
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  ({IconData icon, Color color, String title}) _styleFor(
      String statusRaw, DateTime endTime) {
    if (statusRaw == 'cancelled') {
      return (
        icon: Icons.cancel_outlined,
        color: Colors.redAccent,
        title: 'Booking Dibatalkan'
      );
    }
    if (statusRaw == 'done' || DateTime.now().isAfter(endTime)) {
      return (
        icon: Icons.check_circle_outline,
        color: CustomColors.mabarTextSecondary,
        title: 'Booking Selesai'
      );
    }
    return (
      icon: Icons.event_available_outlined,
      color: CustomColors.mabarGreen,
      title: 'Booking Aktif'
    );
  }

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
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.getBookingHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: CustomColors.mabarBorderFocus),
            );
          }

          final items = (snapshot.data ?? [])
              .where((b) =>
                  b['start_time'] is Timestamp && b['end_time'] is Timestamp)
              .toList();

          if (items.isEmpty) {
            return const MabarEmptyState(
              icon: Icons.notifications_off_outlined,
              title: "Belum ada notifikasi",
              subtitle: "Aktivitas booking kamu akan muncul di sini.",
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _card(items[index]),
          );
        },
      ),
    );
  }

  Widget _card(Map<String, dynamic> b) {
    final startTime = (b['start_time'] as Timestamp).toDate();
    final endTime = (b['end_time'] as Timestamp).toDate();
    final statusRaw = b['status'] as String? ?? 'active';
    final s = _styleFor(statusRaw, endTime);
    final venue = b['venue_name'] as String? ?? 'Warnet';

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
              color: s.color.withValues(alpha: 0.15),
            ),
            child: Icon(s.icon, color: s.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$venue · ${Formatters.tanggal(startTime)}, '
                  '${Formatters.jam(startTime)}-${Formatters.jam(endTime)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CustomColors.mabarTextSecondary,
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
