import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/core/formatters.dart';
import 'package:mabar_slurd/src/core/notification_service.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/buttons/mabar_button.dart';
import 'package:mabar_slurd/src/feat/booking/presentation/views/components/calendar_pop.dart';
import 'package:mabar_slurd/src/feat/booking/presentation/widgets/komputer.dart';
import 'package:mabar_slurd/src/feat/booking/presentation/widgets/pilih_jam.dart';
import 'package:get/get.dart';
import 'package:mabar_slurd/src/feat/common/presentation/views/main_shell.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> venue;

  const BookingPage({super.key, required this.venue});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int? selectedJam;
  bool isCalendarPoping = false;
  DateTime? selectedDate;
  String calendarLabel = 'Pilih Tanggal';
  double _sliderDuration = 1.0;
  int? selectedKomputer;
  bool _isLoading = false;

  DateTime? get _startTime {
    if (selectedDate == null || selectedJam == null) return null;
    final parts = (pilihJam[selectedJam!]['jam'] as String).split(':');
    return DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  DateTime? get _endTime {
    final start = _startTime;
    if (start == null) return null;
    return start.add(Duration(hours: _sliderDuration.round()));
  }

  String get _timeRangeText {
    if (_startTime == null) return '-';
    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${fmt(_startTime!)} - ${fmt(_endTime!)}';
  }

  int get _totalPrice {
    final pricePerHour = (widget.venue['price_per_hour'] as num?)?.toInt() ?? 0;
    return pricePerHour * _sliderDuration.round();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(color: CustomColors.mabarTextPrimary),
        ),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }

  Future<void> _handleBookingConfirmed() async {
    if (selectedDate == null) {
      _showError('Pilih tanggal dulu ya!');
      return;
    }
    if (selectedJam == null) {
      _showError('Pilih jam mulai dulu!');
      return;
    }
    if (selectedKomputer == null) {
      _showError('Pilih komputer dulu!');
      return;
    }

    if (widget.venue['id'] == null ||
        widget.venue['price_per_hour'] == null) {
      _showError('Data tempat tidak lengkap. Pilih dari halaman Beranda ya!');
      return;
    }

    if (_startTime!.isBefore(DateTime.now())) {
      _showError('Tidak bisa booking di waktu yang sudah lewat!');
      return;
    }

    setState(() => _isLoading = true);

    final komputer = komputerList[selectedKomputer!];
    bool success = false;
    try {
      success = await FirestoreService.createBooking(
        venueId: widget.venue['id'] as String,
        venueName: widget.venue['name'] as String,
        startTime: _startTime!,
        endTime: _endTime!,
        durationHours: _sliderDuration.round(),
        deviceType: komputer['tier'] as String,
        computerId: komputer['id'] as String,
        totalPrice: _totalPrice,
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      if (mounted) _showError('Error: $e');
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;

    try {
      if (success) {
        NotificationService.showNotification(
          title: "Booking Berhasil!",
          body: "Tempat kamu sudah aman. Cek detailnya di menu Riwayat.",
        );

        if (!mounted) return;

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

        Get.offAll(() => const MainShell(initialIndex: 1));
      } else {
        _showError('Maaf, slot sudah penuh di waktu tersebut!');
      }
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showConfirmDialog() {
    if (selectedDate == null || selectedJam == null || selectedKomputer == null) {
      _showError('Lengkapi semua pilihan dulu!');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Konfirmasi Booking',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Pastikan jadwal dan perangkat yang kamu pilih sudah sesuai ya!',
            style: TextStyle(color: Colors.white70),
          ),
          actionsPadding:
              const EdgeInsets.fromLTRB(15, 0, 15, 15),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(
                          color: CustomColors.mabarBorderSubtle,
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MabarButton(
                    text: 'Gas Poll!',
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleBookingConfirmed();
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final venueName = widget.venue['name'] as String? ?? '-';

    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: CustomColors.mabarTextPrimary),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Booking - $venueName",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: CustomColors.mabarTextPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Pilih Tanggal",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: CustomColors.mabarTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => setState(() => isCalendarPoping = true),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: CustomColors.mabarSurfaceCard,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month,
                                color: CustomColors.mabarBorderFocus),
                            const SizedBox(width: 10),
                            Text(
                              calendarLabel,
                              style: TextStyle(
                                fontSize: 18,
                                color: selectedDate != null
                                    ? CustomColors.mabarTextPrimary
                                    : CustomColors.mabarTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Pilih Jam",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: CustomColors.mabarTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.start,
                      children: List.generate(
                        pilihJam.length,
                        (index) => FractionallySizedBox(
                          widthFactor: 1 / 4,
                          child: GestureDetector(
                            onTap: () => setState(() => selectedJam = index),
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: selectedJam == index
                                    ? CustomColors.mabarBorderFocus
                                    : CustomColors.mabarSurfaceCard,
                              ),
                              child: Text(
                                pilihJam[index]['jam'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: CustomColors.mabarTextPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Durasi",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: CustomColors.mabarTextPrimary,
                          ),
                        ),
                        Text(
                          "${_sliderDuration.round()} Jam",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: CustomColors.mabarBorderFocus,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      max: 12,
                      min: 1,
                      divisions: 11,
                      activeColor: CustomColors.mabarBorderFocus,
                      value: _sliderDuration,
                      label: '${_sliderDuration.round()} Jam',
                      onChanged: (value) =>
                          setState(() => _sliderDuration = value),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Pilih Komputer",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: CustomColors.mabarTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.start,
                      children: List.generate(
                        komputerList.length,
                        (index) => FractionallySizedBox(
                          widthFactor: 1 / 2,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => selectedKomputer = index),
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: selectedKomputer == index
                                    ? CustomColors.mabarBorderFocus
                                    : CustomColors.mabarSurfaceCard,
                                border: Border.all(
                                  color: selectedKomputer == index
                                      ? CustomColors.mabarBorderFocus
                                      : CustomColors.mabarBorderSubtle,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    komputerList[index]['icon'],
                                    width: 32,
                                    color: CustomColors.mabarTextPrimary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          komputerList[index]['name'],
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: CustomColors.mabarTextPrimary,
                                          ),
                                        ),
                                        Text(
                                          komputerList[index]['spec'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color:
                                                CustomColors.mabarTextSecondary,
                                          ),
                                        ),
                                      ],
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
                        fontSize: 20,
                        color: CustomColors.mabarTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: CustomColors.mabarSurfaceCard,
                      ),
                      child: Column(
                        children: [
                          _summaryRow('Tempat', venueName),
                          _summaryRow(
                            'Tanggal',
                            selectedDate != null
                                ? Formatters.tanggal(selectedDate!)
                                : '-',
                          ),
                          _summaryRow('Waktu', _timeRangeText),
                          _summaryRow(
                            'Komputer',
                            selectedKomputer != null
                                ? '${komputerList[selectedKomputer!]['name']} (${komputerList[selectedKomputer!]['spec']})'
                                : '-',
                          ),
                          _summaryRow('Durasi', '${_sliderDuration.round()} Jam'),
                          _summaryRow(
                            'Harga / jam',
                            'Rp ${Formatters.rupiah(((widget.venue['price_per_hour'] as num?)?.toInt() ?? 0) * 1000)}',
                          ),
                          const Divider(
                              color: Color.fromARGB(113, 94, 93, 112)),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: CustomColors.mabarTextPrimary,
                                  ),
                                ),
                                Text(
                                  'Rp ${Formatters.rupiah(_totalPrice * 1000)}',
                                  style: const TextStyle(
                                    fontSize: 22,
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
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : MabarButton(
                            onTap: _showConfirmDialog,
                            text: 'Konfirmasi Booking',
                          ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          if (isCalendarPoping)
            CalendarPop(
              isCalendarPoping: isCalendarPoping,
              onClose: () => setState(() => isCalendarPoping = false),
              onDateChanged: (value) {
                setState(() {
                  selectedDate = value;
                  calendarLabel = Formatters.tanggal(value);
                  isCalendarPoping = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: CustomColors.mabarTextSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CustomColors.mabarTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
