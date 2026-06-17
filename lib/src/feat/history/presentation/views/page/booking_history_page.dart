import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/mabar_list_card.dart';
import 'package:mabar_slurd/src/shared/components/mabar_empty_state.dart';
import 'package:mabar_slurd/src/feat/history/presentation/views/page/booking_history_detail_page.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  String _selectedFilter = 'Semua';

  static const List<String> _filters = [
    'Semua',
    'Berlangsung',
    'Selesai',
    'Dibatalkan',
  ];

  /// Tentukan status tampilan berdasarkan end_time dan status Firestore.
  /// Jika status Firestore 'active' tapi end_time sudah lewat → otomatis 'Selesai'.
  String _resolveStatus(String raw, DateTime endTime) {
    if (raw == 'cancelled') return 'Dibatalkan';
    if (raw == 'done') return 'Selesai';
    if (DateTime.now().isAfter(endTime)) return 'Selesai';
    return 'Berlangsung';
  }

  String _formatTanggal(DateTime date) {
    const namaBulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${namaBulan[date.month - 1]} ${date.year}';
  }

  String _formatJam(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.getBookingHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: CustomColors.mabarBorderFocus,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: const TextStyle(color: CustomColors.mabarTextSecondary),
              ),
            );
          }

          final rawData = snapshot.data ?? [];

          // Abaikan dokumen yang tidak punya waktu valid agar tidak crash.
          final allData = rawData
              .where((item) =>
                  item['start_time'] is Timestamp &&
                  item['end_time'] is Timestamp)
              .toList();

          // Terapkan filter
          final filtered = _selectedFilter == 'Semua'
              ? allData
              : allData.where((item) {
                  final statusRaw = item['status'] as String? ?? 'active';
                  final endTime = (item['end_time'] as Timestamp).toDate();
                  return _resolveStatus(statusRaw, endTime) == _selectedFilter;
                }).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Riwayat Booking",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: CustomColors.mabarTextPrimary,
                      ),
                    ),
                    const Text(
                      'Lihat aktivitas booking kamu',
                      style: TextStyle(
                        fontSize: 14,
                        color: CustomColors.mabarTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFilterChips(),
                    const SizedBox(height: 20),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: MabarEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: "Belum ada riwayat",
                          subtitle: "Booking kamu akan muncul di sini",
                        ),
                      )
                    else
                      ...filtered.map((item) {
                        final startTime = (item['start_time'] as Timestamp)
                            .toDate();
                        final endTime = (item['end_time'] as Timestamp)
                            .toDate();
                        final statusLabel = _resolveStatus(
                          item['status'] as String? ?? 'active',
                          endTime,
                        );

                        return MabarListCard(
                          title: item['venue_name'] as String? ?? '-',
                          subTitle: item['device_type'] as String? ?? '-',
                          date: _formatTanggal(startTime),
                          time:
                              '${_formatJam(startTime)} - ${_formatJam(endTime)}',
                          total: (item['total_price'] as num).toInt(),
                          status: statusLabel,
                          onTap: () => _goToDetail(
                            item,
                            statusLabel,
                            startTime,
                            endTime,
                          ),
                        );
                      }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _goToDetail(
    Map<String, dynamic> item,
    String statusLabel,
    DateTime startTime,
    DateTime endTime,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingHistoryDetailPage(
          bookingId: item['id'] as String,
          title: item['venue_name'] as String? ?? '-',
          subTitle: item['device_type'] as String? ?? '-',
          date: _formatTanggal(startTime),
          time: '${_formatJam(startTime)} - ${_formatJam(endTime)}',
          total: (item['total_price'] as num).toInt(),
          status: statusLabel,
          durationHours: (item['duration_hours'] as num?)?.toInt() ?? 1,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final bool isActive = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
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
                filter,
                style: TextStyle(
                  fontSize: 14,
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
}
