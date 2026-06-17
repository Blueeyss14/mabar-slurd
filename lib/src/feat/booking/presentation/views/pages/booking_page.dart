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
  int _durasiJam = 1;
  int? selectedKomputer;
  bool _isLoading = false;

  // ─── computed ──────────────────────────────────────────────────────────────

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
    return start.add(Duration(hours: _durasiJam));
  }

  String get _timeRangeText {
    if (_startTime == null) return '–';
    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${fmt(_startTime!)} – ${fmt(_endTime!)}';
  }

  int get _pricePerHour =>
      (widget.venue['price_per_hour'] as num?)?.toInt() ?? 0;

  int get _totalPrice => _pricePerHour * _durasiJam;

  bool _isSlotPast(int hour) {
    if (selectedDate == null) return false;
    final now = DateTime.now();
    final isToday = selectedDate!.year == now.year &&
        selectedDate!.month == now.month &&
        selectedDate!.day == now.day;
    return isToday && hour <= now.hour;
  }

  // ─── helpers ───────────────────────────────────────────────────────────────

  Color _tierColor(String tier) {
    switch (tier) {
      case 'Reguler':
        return const Color(0xFF6B7280);
      case 'Gaming':
        return const Color(0xFF16A34A);
      case 'VIP':
        return const Color(0xFFD97706);
      case 'Console':
        return CustomColors.mabarCyan;
      default:
        return const Color(0xFF6B7280);
    }
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

  // ─── booking ───────────────────────────────────────────────────────────────

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
      _showError('Pilih perangkat dulu!');
      return;
    }
    if (widget.venue['id'] == null || widget.venue['price_per_hour'] == null) {
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
        durationHours: _durasiJam,
        deviceType: komputer['tier'] as String,
        computerId: komputer['id'] as String,
        totalPrice: _totalPrice,
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      if (mounted) _showError('Terjadi kesalahan: $e');
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;

    try {
      if (success) {
        NotificationService.showNotification(
          title: 'Booking Berhasil!',
          body: 'Tempat kamu sudah aman. Cek detailnya di menu Riwayat.',
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
        _showError('Maaf, perangkat sudah dibooking di waktu tersebut!');
      }
    } catch (e) {
      if (mounted) _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showConfirmDialog() {
    if (selectedDate == null || selectedJam == null || selectedKomputer == null) {
      _showError('Lengkapi semua pilihan dulu!');
      return;
    }

    final komputer = komputerList[selectedKomputer!];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Konfirmasi Booking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.venue['name'] as String? ?? '-',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${Formatters.tanggal(selectedDate!)}  ·  $_timeRangeText',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              '${komputer['name']} · ${komputer['spec']}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  'Rp ${Formatters.rupiah(_totalPrice * 1000)}',
                  style: const TextStyle(
                    color: CustomColors.mabarCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
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
                          color: CustomColors.mabarBorderSubtle),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Batalkan',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MabarButton(
                  text: 'Pesan Sekarang',
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleBookingConfirmed();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final venueName = widget.venue['name'] as String? ?? '-';

    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _buildHeader(venueName),
                  const SizedBox(height: 28),

                  _buildSectionLabel('Pilih Tanggal',
                      icon: Icons.calendar_today_outlined,
                      chip: selectedDate != null
                          ? Formatters.tanggal(selectedDate!)
                          : null),
                  const SizedBox(height: 10),
                  _buildTanggalPicker(),
                  const SizedBox(height: 28),

                  _buildSectionLabel('Jam Mulai',
                      icon: Icons.schedule_outlined,
                      chip: selectedJam != null
                          ? pilihJam[selectedJam!]['jam']
                          : null),
                  const SizedBox(height: 12),
                  _buildJamGrid(),
                  const SizedBox(height: 28),

                  _buildSectionLabel('Durasi',
                      icon: Icons.timelapse_outlined,
                      chip: '$_durasiJam Jam'),
                  const SizedBox(height: 10),
                  _buildDurasiPicker(),
                  const SizedBox(height: 28),

                  _buildSectionLabel('Pilih Perangkat',
                      icon: Icons.devices_outlined,
                      chip: selectedKomputer != null
                          ? komputerList[selectedKomputer!]['name']
                          : null),
                  const SizedBox(height: 12),
                  _buildKomputerSection(),
                  const SizedBox(height: 28),

                  _buildSectionLabel('Ringkasan',
                      icon: Icons.receipt_long_outlined),
                  const SizedBox(height: 10),
                  _buildSummaryCard(venueName),
                  const SizedBox(height: 24),

                  _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(
                                color: CustomColors.mabarBorderFocus),
                          ),
                        )
                      : MabarButton(
                          onTap: _showConfirmDialog,
                          text: 'Pesan Sekarang',
                        ),
                  const SizedBox(height: 36),
                ],
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

  // ─── section widgets ───────────────────────────────────────────────────────

  Widget _buildHeader(String venueName) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: CustomColors.mabarSurfaceCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CustomColors.mabarBorderSubtle),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: CustomColors.mabarTextPrimary, size: 17),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Booking',
                  style: TextStyle(
                      color: CustomColors.mabarTextSecondary,
                      fontSize: 11,
                      letterSpacing: 0.5)),
              Text(venueName,
                  style: const TextStyle(
                      color: CustomColors.mabarTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String title,
      {required IconData icon, String? chip}) {
    return Row(
      children: [
        Icon(icon, size: 17, color: CustomColors.mabarBorderFocus),
        const SizedBox(width: 7),
        Text(title,
            style: const TextStyle(
                color: CustomColors.mabarTextPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        if (chip != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color:
                  CustomColors.mabarBorderFocus.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(chip,
                style: const TextStyle(
                    color: CustomColors.mabarBorderFocus,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ],
      ],
    );
  }

  Widget _buildTanggalPicker() {
    return GestureDetector(
      onTap: () => setState(() => isCalendarPoping = true),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: CustomColors.mabarSurfaceCard,
          border: Border.all(
            color: selectedDate != null
                ? CustomColors.mabarBorderFocus
                : CustomColors.mabarBorderSubtle,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: CustomColors.mabarBorderFocus
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_month,
                  color: CustomColors.mabarBorderFocus, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                calendarLabel,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selectedDate != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selectedDate != null
                      ? CustomColors.mabarTextPrimary
                      : CustomColors.mabarTextSecondary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                color: CustomColors.mabarTextSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Pilih Jam: Cinema XXI style grid ──────────────────────────────────────

  Widget _buildJamGrid() {
    // Period groups: label + list of hours
    const groups = [
      _JamGroup('Dini Hari', [0, 1, 2, 3, 4]),
      _JamGroup('Pagi', [5, 6, 7, 8, 9, 10]),
      _JamGroup('Siang', [11, 12, 13, 14]),
      _JamGroup('Sore', [15, 16, 17, 18]),
      _JamGroup('Malam', [19, 20, 21, 22, 23]),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(
          children: [
            _legendDot(CustomColors.mabarBorderFocus, 'Dipilih'),
            const SizedBox(width: 16),
            _legendDot(CustomColors.mabarSurfaceCard, 'Tersedia',
                border: true),
            const SizedBox(width: 16),
            _legendDot(const Color(0xFF1A1A20), 'Sudah Lewat'),
          ],
        ),
        const SizedBox(height: 12),
        // Groups
        ...groups.map((group) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  group.label.toUpperCase(),
                  style: const TextStyle(
                    color: CustomColors.mabarTextTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: group.hours.map((hour) {
                  final index = hour; // pilihJam index == hour
                  final jamStr =
                      '${hour.toString().padLeft(2, '0')}:00';
                  final isSelected = selectedJam == index;
                  final isPast = _isSlotPast(hour);

                  return GestureDetector(
                    onTap: isPast
                        ? null
                        : () => setState(() => selectedJam = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 60,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isPast
                            ? const Color(0xFF181820)
                            : isSelected
                                ? CustomColors.mabarBorderFocus
                                : CustomColors.mabarSurfaceCard,
                        border: Border.all(
                          color: isPast
                              ? const Color(0xFF252530)
                              : isSelected
                                  ? CustomColors.mabarBorderFocus
                                  : CustomColors.mabarBorderSubtle,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            jamStr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isPast
                                  ? const Color(0xFF3A3A4A)
                                  : CustomColors.mabarTextPrimary,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 3),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],
          );
        }),
      ],
    );
  }

  Widget _legendDot(Color color, String label, {bool border = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: border
                ? Border.all(color: CustomColors.mabarBorderSubtle)
                : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: CustomColors.mabarTextSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ── Durasi: vertical cards dengan harga per pilihan ───────────────────────

  Widget _buildDurasiPicker() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        itemBuilder: (context, index) {
          final jam = index + 1;
          final isSelected = _durasiJam == jam;
          final harga = _pricePerHour * jam;

          return GestureDetector(
            onTap: () => setState(() => _durasiJam = jam),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 10),
              width: 78,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSelected
                    ? CustomColors.mabarBorderFocus
                    : CustomColors.mabarSurfaceCard,
                border: Border.all(
                  color: isSelected
                      ? CustomColors.mabarBorderFocus
                      : CustomColors.mabarBorderSubtle,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$jam Jam',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.mabarTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    harga > 0
                        ? 'Rp ${Formatters.rupiah(harga * 1000)}'
                        : '– –',
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? CustomColors.mabarTextPrimary
                              .withValues(alpha: 0.85)
                          : CustomColors.mabarTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Pilih Perangkat: dua section (PC + Console) ───────────────────────────

  Widget _buildKomputerSection() {
    final pcIndices = komputerList
        .asMap()
        .entries
        .where((e) => (e.value['tier'] as String) != 'Console')
        .map((e) => e.key)
        .toList();

    final consoleIndices = komputerList
        .asMap()
        .entries
        .where((e) => (e.value['tier'] as String) == 'Console')
        .map((e) => e.key)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _deviceSectionHeader(Icons.computer_outlined, 'PC', pcIndices.length),
        const SizedBox(height: 8),
        _buildKomputerGrid(pcIndices),
        const SizedBox(height: 20),
        _deviceSectionHeader(
            Icons.gamepad_outlined, 'Console', consoleIndices.length),
        const SizedBox(height: 8),
        _buildKomputerGrid(consoleIndices),
      ],
    );
  }

  Widget _deviceSectionHeader(
      IconData icon, String label, int count) {
    return Row(
      children: [
        Icon(icon, size: 15, color: CustomColors.mabarTextSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: CustomColors.mabarTextSecondary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$count unit',
          style: const TextStyle(
            color: CustomColors.mabarTextTertiary,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            height: 1,
            color: CustomColors.mabarBorderSubtle,
          ),
        ),
      ],
    );
  }

  Widget _buildKomputerGrid(List<int> indices) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: indices.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.75,
      ),
      itemBuilder: (context, i) {
        final index = indices[i];
        final komputer = komputerList[index];
        final isSelected = selectedKomputer == index;
        final tierColor = _tierColor(komputer['tier'] as String);

        return GestureDetector(
          onTap: () => setState(() => selectedKomputer = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isSelected
                  ? CustomColors.mabarBorderFocus
                      .withValues(alpha: 0.12)
                  : CustomColors.mabarSurfaceCard,
              border: Border.all(
                color: isSelected
                    ? CustomColors.mabarBorderFocus
                    : CustomColors.mabarBorderSubtle,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          komputer['icon'] as String,
                          width: 22,
                          color: isSelected
                              ? CustomColors.mabarBorderFocus
                              : CustomColors.mabarTextPrimary,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            komputer['name'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? CustomColors.mabarBorderFocus
                                  : CustomColors.mabarTextPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _tierBadge(
                            komputer['tier'] as String, tierColor),
                        const SizedBox(height: 3),
                        Text(
                          komputer['spec'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: CustomColors.mabarTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: CustomColors.mabarBorderFocus,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Ringkasan ──────────────────────────────────────────────────────────────

  Widget _buildSummaryCard(String venueName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: CustomColors.mabarSurfaceCard,
        border: Border.all(color: CustomColors.mabarBorderSubtle),
      ),
      child: Column(
        children: [
          _summaryRow(Icons.store_outlined, 'Tempat', venueName),
          _summaryDivider(),
          _summaryRow(
            Icons.calendar_today_outlined,
            'Tanggal',
            selectedDate != null
                ? Formatters.tanggal(selectedDate!)
                : '–',
          ),
          _summaryDivider(),
          _summaryRow(Icons.access_time_outlined, 'Waktu', _timeRangeText),
          _summaryDivider(),
          _summaryRow(
            Icons.computer_outlined,
            'Perangkat',
            selectedKomputer != null
                ? '${komputerList[selectedKomputer!]['name']} · ${komputerList[selectedKomputer!]['spec']}'
                : '–',
          ),
          _summaryDivider(),
          _summaryRow(
              Icons.timelapse_outlined, 'Durasi', '$_durasiJam Jam'),
          _summaryDivider(),
          _summaryRow(
            Icons.payments_outlined,
            'Harga / Jam',
            'Rp ${Formatters.rupiah(_pricePerHour * 1000)}',
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CustomColors.mabarBgDark,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                Text(
                  'Rp ${Formatters.rupiah(_totalPrice * 1000)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.mabarCyan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── micro widgets ─────────────────────────────────────────────────────────

  Widget _summaryDivider() =>
      const Divider(color: Color(0x1A9B9AAA), height: 14);

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: CustomColors.mabarTextSecondary),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: CustomColors.mabarTextSecondary)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: CustomColors.mabarTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tierBadge(String tier, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4),
        border:
            Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Text(
        tier,
        style: TextStyle(
            fontSize: 9, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

// ─── data class ───────────────────────────────────────────────────────────────

@immutable
class _JamGroup {
  final String label;
  final List<int> hours;
  const _JamGroup(this.label, this.hours);
}
