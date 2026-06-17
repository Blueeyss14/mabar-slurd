import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/core/formatters.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/mabar_empty_state.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String? _selectedVenueId;

  String _resolveStatus(String raw, DateTime endTime) {
    if (raw == 'cancelled') return 'Dibatalkan';
    if (raw == 'done') return 'Selesai';
    if (DateTime.now().isAfter(endTime)) return 'Selesai';
    return 'Berlangsung';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Dibatalkan':
        return Colors.red.shade400;
      case 'Selesai':
        return CustomColors.mabarTextSecondary;
      default:
        return CustomColors.mabarGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirestoreService.getMyVenues(),
          builder: (context, venueSnap) {
            if (venueSnap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: CustomColors.mabarBorderFocus,
                ),
              );
            }

            final venues = venueSnap.data ?? [];

            if (venues.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: MabarEmptyState(
                    icon: Icons.storefront_outlined,
                    title: "Belum ada venue",
                    subtitle:
                        "Belum ada warnet yang terdaftar atas akun admin ini.\nTambahkan venue lewat menu Venue Saya.",
                  ),
                ),
              );
            }

            // Default pilih venue pertama.
            final selectedId = _selectedVenueId ??
                (venues.first['id'] as String);
            final selectedVenue = venues.firstWhere(
              (v) => v['id'] == selectedId,
              orElse: () => venues.first,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Booking Masuk",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: CustomColors.mabarTextPrimary,
                        ),
                      ),
                      const Text(
                        "Kelola pesanan yang masuk ke warnetmu",
                        style: TextStyle(
                          fontSize: 13,
                          color: CustomColors.mabarTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (venues.length > 1)
                        _venueSelector(venues, selectedId),
                      if (venues.length <= 1)
                        _venueChip(selectedVenue['name'] as String? ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _bookingList(selectedId),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _venueChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CustomColors.mabarBorderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storefront,
              size: 15, color: CustomColors.mabarBorderFocus),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              color: CustomColors.mabarTextPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _venueSelector(List<Map<String, dynamic>> venues, String selectedId) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: venues.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final v = venues[i];
          final id = v['id'] as String;
          final isActive = id == selectedId;
          return GestureDetector(
            onTap: () => setState(() => _selectedVenueId = id),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isActive
                    ? CustomColors.mabarBorderFocus
                    : CustomColors.mabarSurfaceCard,
                border: Border.all(
                  color: isActive
                      ? CustomColors.mabarBorderFocus
                      : CustomColors.mabarBorderSubtle,
                ),
              ),
              child: Text(
                v['name'] as String? ?? '-',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? CustomColors.mabarTextPrimary
                      : CustomColors.mabarTextSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bookingList(String venueId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.getVenueBookings(venueId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: CustomColors.mabarBorderFocus,
            ),
          );
        }

        final all = (snap.data ?? [])
            .where((b) =>
                b['start_time'] is Timestamp && b['end_time'] is Timestamp)
            .toList();

        if (all.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: MabarEmptyState(
                icon: Icons.inbox_outlined,
                title: "Belum ada booking",
                subtitle: "Pesanan yang masuk akan muncul di sini.",
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          itemCount: all.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _bookingCard(all[i]),
        );
      },
    );
  }

  Widget _bookingCard(Map<String, dynamic> b) {
    final startTime = (b['start_time'] as Timestamp).toDate();
    final endTime = (b['end_time'] as Timestamp).toDate();
    final statusRaw = b['status'] as String? ?? 'active';
    final status = _resolveStatus(statusRaw, endTime);
    final color = _statusColor(status);

    final computerId = b['computer_id'] as String?;
    final deviceType = b['device_type'] as String?;
    final perangkat = (computerId != null && deviceType != null)
        ? '$computerId · $deviceType'
        : computerId ?? deviceType ?? '-';

    final canMarkDone = statusRaw == 'active' && DateTime.now().isBefore(endTime);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CustomColors.mabarBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  perangkat,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.calendar_today_outlined,
              Formatters.tanggal(startTime)),
          const SizedBox(height: 4),
          _infoRow(Icons.access_time_outlined,
              '${Formatters.jam(startTime)} – ${Formatters.jam(endTime)}'),
          const SizedBox(height: 4),
          _infoRow(Icons.payments_outlined,
              'Rp ${Formatters.rupiah(((b['total_price'] as num?)?.toInt() ?? 0) * 1000)}'),
          if (canMarkDone) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.mabarBorderFocus,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _confirmDone(b['id'] as String),
                icon: const Icon(Icons.check_circle_outline,
                    size: 18, color: Colors.white),
                label: const Text(
                  'Tandai Selesai',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: CustomColors.mabarTextSecondary),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: CustomColors.mabarTextSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDone(String bookingId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tandai Selesai?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Booking ini akan ditandai sebagai selesai.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: CustomColors.mabarTextSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Selesai',
                style: TextStyle(
                    color: CustomColors.mabarBorderFocus,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (ok != true) return;
    final success = await FirestoreService.markBookingDone(bookingId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Booking ditandai selesai.' : 'Gagal memperbarui status.',
          style: const TextStyle(color: CustomColors.mabarTextPrimary),
        ),
        backgroundColor:
            success ? CustomColors.mabarPurpleBg : Colors.red.shade800,
      ),
    );
  }
}
