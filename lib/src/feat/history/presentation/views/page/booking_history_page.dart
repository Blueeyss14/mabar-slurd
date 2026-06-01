import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/mabar_list_card.dart';
import 'package:mabar_slurd/src/shared/components/mabar_empty_state.dart';
import 'package:mabar_slurd/src/feat/history/presentation/views/page/booking_history_detail_page.dart';
import 'package:mabar_slurd/src/feat/history/presentation/views/widgets/history_data.dart';

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

  List<Map<String, dynamic>> get _filteredData {
    if (_selectedFilter == 'Semua') return historyData;
    return historyData
        .where((item) => item['status'] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredData;
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: SingleChildScrollView(
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
                  ...List.generate(
                    filtered.length,
                    (index) => MabarListCard(
                      title: filtered[index]['title'],
                      subTitle: filtered[index]['subTitle'],
                      date: filtered[index]['date'],
                      time: filtered[index]['time'],
                      total: filtered[index]['total'],
                      status: filtered[index]['status'],
                      onTap: () => _goToDetail(filtered[index]),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingHistoryDetailPage(
          title: item['title'],
          subTitle: item['subTitle'],
          date: item['date'],
          time: item['time'],
          total: item['total'],
          status: item['status'],
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
