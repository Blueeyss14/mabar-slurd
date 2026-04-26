import 'package:flutter/material.dart';
import 'package:mabar_slurd/res/assets.dart';
import 'package:mabar_slurd/res/custom_colors.dart';
import 'package:mabar_slurd/shared/buttons/mabar_button.dart';
import 'package:mabar_slurd/src/feat/booking/presentation/widgets/durasi.dart';
import 'package:mabar_slurd/src/feat/booking/presentation/widgets/perangkat.dart';
import 'package:mabar_slurd/src/feat/booking/presentation/widgets/pilih_jam.dart';

class BookingScreen extends StatefulWidget {
  final String placeName;
  final double pricePerHour;

  const BookingScreen({
    super.key,
    this.placeName = 'GG Arena',
    this.pricePerHour = 15000,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  int? _selectedJamIndex;
  int? _selectedDurIndex;
  int? _selectedDeviceIndex;

  String get _formattedDate {
    if (_selectedDate == null) return '';
    final months = [
      '',
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
    return '${_selectedDate!.day} ${months[_selectedDate!.month]} ${_selectedDate!.year}';
  }

  String get _selectedJamStr =>
      _selectedJamIndex != null ? pilihJam[_selectedJamIndex!]['jam'] : '-';

  String get _selectedDurStr =>
      _selectedDurIndex != null ? durasi[_selectedDurIndex!]['durasi'] : '-';

  String get _selectedDeviceStr => _selectedDeviceIndex != null
      ? perangkat[_selectedDeviceIndex!]['label']
      : '-';

  // Hitung jam selesai dari jam mulai + durasi
  String get _endTimeStr {
    if (_selectedJamIndex == null || _selectedDurIndex == null) return '';
    final jamStr = pilihJam[_selectedJamIndex!]['jam'] as String;
    final durStr = durasi[_selectedDurIndex!]['durasi'] as String;
    final startHour = int.parse(jamStr.split(':')[0]);
    final durationHours = int.parse(durStr.split(' ')[0]);
    final endHour = (startHour + durationHours) % 24;
    return '${endHour.toString().padLeft(2, '0')}:00';
  }

  String get _waktuStr {
    if (_selectedJamIndex == null) return '-';
    if (_selectedDurIndex == null) return _selectedJamStr;
    return '$_selectedJamStr - $_endTimeStr';
  }

  // Format total: 30k IDR
  String get _totalStr {
    if (_selectedDurIndex == null) return '-';
    final durStr = durasi[_selectedDurIndex!]['durasi'] as String;
    final hours = int.parse(durStr.split(' ')[0]);
    final total = widget.pricePerHour * hours;
    final k = (total / 1000).toStringAsFixed(0);
    return '${k}k IDR';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: CustomColors.mabarPurple,
            onPrimary: CustomColors.mabarTextPrimary,
            surface: CustomColors.mabarSurface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _confirmBooking() {
    if (_selectedDate == null || _selectedJamIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih tanggal dan jam terlebih dahulu'),
          backgroundColor: CustomColors.mabarPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: CustomColors.mabarSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Booking Berhasil!',
          style: TextStyle(
            color: CustomColors.mabarTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tempat: ${widget.placeName}\n'
          'Tanggal: $_formattedDate\n'
          'Waktu: $_waktuStr\n'
          'Perangkat: $_selectedDeviceStr\n'
          'Total: $_totalStr',
          style: const TextStyle(
            color: CustomColors.mabarTextSecondary,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: CustomColors.mabarPurple),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      appBar: AppBar(
        backgroundColor: CustomColors.mabarBgDark,
        elevation: 0,
        title: const Text(
          'Booking Screen',
          style: TextStyle(
            color: CustomColors.mabarTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: CustomColors.mabarTextPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                const Text(
                  'Booking',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 30),

                // tanggal
                const Text(
                  'Pilih Tanggal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: CustomColors.mabarSurfaceCard,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: CustomColors.mabarBorderFocus,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _formattedDate.isEmpty
                              ? 'Pilih tanggal'
                              : _formattedDate,
                          style: TextStyle(
                            fontSize: 16,
                            color: _formattedDate.isEmpty
                                ? CustomColors.mabarTextSecondary
                                : CustomColors.mabarTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // jam
                const Text(
                  'Pilih Jam',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
                        onTap: () => setState(() => _selectedJamIndex = index),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: _selectedJamIndex == index
                                ? CustomColors.mabarBorderFocus
                                : CustomColors.mabarSurfaceCard,
                          ),
                          child: Text(
                            pilihJam[index]['jam'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: CustomColors.mabarTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // durasi
                const Text(
                  'Durasi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
                        onTap: () => setState(() => _selectedDurIndex = index),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: _selectedDurIndex == index
                                ? CustomColors.mabarBorderFocus
                                : CustomColors.mabarSurfaceCard,
                          ),
                          child: Text(
                            durasi[index]['durasi'],
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

                // pilih device
                const Text(
                  'Pilih Perangkat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
                        onTap: () =>
                            setState(() => _selectedDeviceIndex = index),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: _selectedDeviceIndex == index
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
                  'Ringkasan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: CustomColors.mabarSurfaceCard,
                  ),
                  child: Column(
                    children: [
                      _SummaryRow('Tempat', widget.placeName, bold: true),
                      _SummaryRow(
                        'Tanggal',
                        _formattedDate.isEmpty ? '-' : _formattedDate,
                      ),
                      _SummaryRow('Waktu', _waktuStr),
                      _SummaryRow('Perangkat', _selectedDeviceStr),
                      const Divider(color: Color.fromARGB(113, 94, 93, 112)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                            Text(
                              _totalStr,
                              style: const TextStyle(
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

                // button konfirmasi
                MabarButton(onTap: _confirmBooking, text: 'Konfirmasi Booking'),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
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
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: CustomColors.mabarTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
