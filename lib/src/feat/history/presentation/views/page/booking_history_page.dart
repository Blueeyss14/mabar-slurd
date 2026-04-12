import 'package:flutter/material.dart';
import 'package:mabar_slurd/res/custom_colors.dart';
import 'package:mabar_slurd/shared/components/mabar_list_card.dart';
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
                  'Lihat Aktivitasi Booking Kamu',
                  style: TextStyle(
                    fontSize: 14,
                    color: CustomColors.mabarTextSecondary,
                  ),
                ),
                const SizedBox(height: 30),

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
