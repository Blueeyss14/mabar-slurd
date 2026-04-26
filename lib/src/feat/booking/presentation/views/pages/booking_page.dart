import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mabar_slurd/core/notification_service.dart';
import 'package:mabar_slurd/res/custom_colors.dart';
import 'package:mabar_slurd/shared/buttons/mabar_button.dart';
import 'package:mabar_slurd/src/feat/booking/presentation/widgets/durasi.dart';
import 'package:mabar_slurd/src/feat/booking/presentation/widgets/perangkat.dart';
import 'package:mabar_slurd/src/feat/booking/presentation/widgets/pilih_jam.dart';
import 'package:mabar_slurd/src/feat/history/presentation/views/page/booking_history_page.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int? selectedJam;

  void selectJamFunc(int index) {
    setState(() {
      selectedJam = index;
    });
  }

  int? selectedDuration;

  void selectDurFunc(int index) {
    setState(() {
      selectedDuration = index;
    });
  }

  int? selectedDevice;

  void selectDeviceFunc(int index) {
    setState(() {
      selectedDevice = index;
    });
  }

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
                  "Booking",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Pilih Tanggal",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: CustomColors.mabarSurfaceCard,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: CustomColors.mabarBorderFocus,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Calendar',
                        style: TextStyle(
                          fontSize: 20,
                          color: CustomColors.mabarTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Pilih Jam",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 15),

                Wrap(
                  alignment: WrapAlignment.start,
                  children: List.generate(
                    pilihJam.length,
                    (index) => FractionallySizedBox(
                      widthFactor: 1 / 3,
                      child: GestureDetector(
                        onTap: () => selectJamFunc(index),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: selectedJam == index
                                ? CustomColors.mabarBorderFocus
                                : CustomColors.mabarSurfaceCard,
                          ),
                          child: Text(
                            pilihJam[index]['jam'],
                            style: const TextStyle(
                              fontSize: 18,
                              color: CustomColors.mabarTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Durasi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 15),

                Wrap(
                  alignment: WrapAlignment.start,
                  children: List.generate(
                    durasi.length,
                    (index) => FractionallySizedBox(
                      widthFactor: 1 / 4,
                      child: GestureDetector(
                        onTap: () => selectDurFunc(index),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: selectedDuration == index
                                ? CustomColors.mabarBorderFocus
                                : CustomColors.mabarSurfaceCard,
                          ),
                          child: AutoSizeText(
                            durasi[index]['durasi'],
                            maxLines: 1,
                            minFontSize: 6,
                            style: const TextStyle(
                              // fontSize: 18,
                              color: CustomColors.mabarTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Pilih Perangkat",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 15),

                Wrap(
                  alignment: WrapAlignment.start,
                  children: List.generate(
                    perangkat.length,
                    (index) => FractionallySizedBox(
                      widthFactor: 1 / 2,
                      child: GestureDetector(
                        onTap: () => selectDeviceFunc(index),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: selectedDevice == index
                                ? CustomColors.mabarBorderFocus
                                : CustomColors.mabarSurfaceCard,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                perangkat[index]['icon'],
                                width: 40,
                                color: CustomColors.mabarTextPrimary,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                perangkat[index]['label'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: CustomColors.mabarTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Ringkasan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: CustomColors.mabarSurfaceCard,
                  ),
                  child: const Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Tempat',
                              style: TextStyle(
                                fontSize: 18,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'GG Arena',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Tanggal',
                              style: TextStyle(
                                fontSize: 18,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '15 Apr 2026',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Waktu',
                              style: TextStyle(
                                fontSize: 18,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '14:00 - 16:00',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Perangkat',
                              style: TextStyle(
                                fontSize: 18,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'PC Gaming',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Color.fromARGB(113, 94, 93, 112)),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '30K IDR',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.mabarCyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                MabarButton(
                  onTap: () => _popUpDialogConfirm(context),
                  text: 'Konfirmasi Booking',
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _popUpDialogConfirm(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(
          0xFF1E1E1E,
        ), // Sesuaikan dengan tema gelap MabarKeun
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Konfirmasi Booking 🎮',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Pastikan jadwal dan perangkat yang kamu pilih sudah sesuai ya!',
          style: TextStyle(color: Colors.white70),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        actions: [
          // Tombol Batal (bisa pakai TextButton biasa agar tidak terlalu dominan)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali', style: TextStyle(color: Colors.grey)),
          ),

          // Tombol Konfirmasi pakai MabarButton
          // Sesuaikan parameter 'text' atau 'onPressed' dengan property di class MabarButton-mu
          SizedBox(
            width: 120, // Atur lebar agar pas di dalam dialog
            child: MabarButton(
              text: 'Gas Poll!',
              onTap: () {
                Navigator.pop(context);
                _prosesBookingBerhasil(context);
              },
            ),
          ),
        ],
      );
    },
  );
}

void _prosesBookingBerhasil(BuildContext context) async {
  // 1. Trigger Notifikasi Lokal
  await NotificationService.showNotification(
    title: "Booking Berhasil! 🎉",
    body: "Tempat kamu sudah aman. Cek detailnya di menu Riwayat.",
  );

  // 2. Feedback visual cepat
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Pesanan berhasil dibuat!',
        style: TextStyle(
          color: CustomColors.mabarTextPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: CustomColors.mabarPurpleBg,
    ),
  );

  // 3. Pindah ke Booking History Page
  // Pastikan route '/booking_history' sudah terdaftar di routes.dart kamu
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const BookingHistoryPage()),
  );
}
