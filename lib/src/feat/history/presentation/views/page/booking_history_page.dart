import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/mabar_list_card.dart';
import 'package:mabar_slurd/src/feat/history/presentation/views/widgets/history_data.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 30),

                if (historyData.isEmpty)
                  _buildEmptyState()
                else
                  ...List.generate(
                    historyData.length,
                    (index) => MabarListCard(
                      title: historyData[index]['title'],
                      subTitle: historyData[index]['subTitle'],
                      date: historyData[index]['date'],
                      time: historyData[index]['time'],
                      total: historyData[index]['total'],
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

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: CustomColors.mabarTextTertiary,
            ),
            SizedBox(height: 16),
            Text(
              "Belum ada riwayat",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CustomColors.mabarTextPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Booking kamu akan muncul di sini",
              style: TextStyle(
                fontSize: 14,
                color: CustomColors.mabarTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
