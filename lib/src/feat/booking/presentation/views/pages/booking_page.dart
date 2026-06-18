import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/core/formatters.dart';
import 'package:mabar_slurd/src/core/notification_service.dart';
import 'package:mabar_slurd/src/res/assets.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/buttons/mabar_button.dart';
import 'package:mabar_slurd/src/feat/booking/presentation/views/components/calendar_pop.dart';
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

  /// id komputer yang sudah dibooking di rentang waktu yang sedang dipilih.
  Set<String> _bookedComputers = {};
  bool _loadingAvail = false;

  /// Daftar perangkat venue (dari Firestore; fallback ke daftar standar).
  List<Map<String, dynamic>> _computers = [];
  bool _loadingComputers = true;

  String _paymentMethod = 'Bayar di Tempat';
  static const List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Bayar di Tempat', 'icon': Icons.payments_outlined},
    {'name': 'GoPay', 'icon': Icons.account_balance_wallet},
    {'name': 'OVO', 'icon': Icons.account_balance_wallet_outlined},
    {'name': 'QRIS', 'icon': Icons.qr_code},
    {'name': 'Kartu', 'icon': Icons.credit_card},
  ];

  @override
  void initState() {
    super.initState();
    _loadComputers();
  }

  Future<void> _loadComputers() async {
    final venueId = widget.venue['id'] as String?;
    List<Map<String, dynamic>> list = [];
    if (venueId != null) {
      list = await FirestoreService.getVenueComputersOnce(venueId);
    }
    if (!mounted) return;
    setState(() {
      _computers = list;
      _loadingComputers = false;
    });
  }

  bool _isConsole(Map<String, dynamic> c) =>
      c['type'] == 'Console' || c['tier'] == 'Console';

  String _iconFor(Map<String, dynamic> c) =>
      _isConsole(c) ? AssetIcons.gamepad : AssetIcons.pc;

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

  /// Muat ulang daftar komputer yang sudah dibooking untuk rentang waktu aktif.
  /// Dipanggil setiap kali tanggal / jam / durasi berubah.
  Future<void> _refreshAvailability() async {
    final start = _startTime;
    final end = _endTime;
    final venueId = widget.venue['id'] as String?;
    if (start == null || end == null || venueId == null) {
      setState(() => _bookedComputers = {});
      return;
    }

    setState(() => _loadingAvail = true);
    final booked =
        await FirestoreService.getBookedComputers(venueId, start, end);
    if (!mounted) return;
    setState(() {
      _bookedComputers = booked;
      _loadingAvail = false;
      // Jika komputer yang sedang dipilih ternyata sudah dibooking, batalkan.
      if (selectedKomputer != null &&
          selectedKomputer! < _computers.length &&
          booked.contains(_computers[selectedKomputer!]['id'])) {
        selectedKomputer = null;
      }
    });
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

    final komputer = _computers[selectedKomputer!];
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
        paymentMethod: _paymentMethod,
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

    final komputer = _computers[selectedKomputer!];

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
        actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: const BorderSide(
                          color: CustomColors.mabarBorderSubtle),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: CustomColors.mabarTextSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: CustomColors.mabarBorderFocus,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _handleBookingConfirmed();
                    },
                    child: const Text(
                      'Pesan',
                      style: TextStyle(
                        color: CustomColors.mabarTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                          ? _computers[selectedKomputer!]['name']
                          : null),
                  const SizedBox(height: 12),
                  _buildKomputerSection(),
                  const SizedBox(height: 28),

                  _buildSectionLabel('Metode Pembayaran',
                      icon: Icons.account_balance_wallet_outlined,
                      chip: _paymentMethod),
                  const SizedBox(height: 10),
                  _buildPaymentPicker(),
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
                _refreshAvailability();
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

  // ── Pilih Jam: grid sederhana 4 kolom ─────────────────────────────────────

  Widget _buildJamGrid() {
    return Wrap(
      children: List.generate(
        pilihJam.length,
        (index) {
          final isSelected = selectedJam == index;
          return FractionallySizedBox(
            widthFactor: 1 / 4,
            child: GestureDetector(
              onTap: () {
                setState(() => selectedJam = index);
                _refreshAvailability();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
                child: Text(
                  pilihJam[index]['jam'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Durasi: slider 1–12 jam ───────────────────────────────────────────────

  Widget _buildDurasiPicker() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: CustomColors.mabarBorderFocus,
            inactiveTrackColor: CustomColors.mabarSurfaceCard,
            thumbColor: CustomColors.mabarBorderFocus,
            overlayColor:
                CustomColors.mabarBorderFocus.withValues(alpha: 0.18),
            trackHeight: 5,
          ),
          child: Slider(
            min: 1,
            max: 12,
            divisions: 11,
            value: _durasiJam.toDouble(),
            label: '$_durasiJam Jam',
            onChanged: (value) =>
                setState(() => _durasiJam = value.round()),
            onChangeEnd: (_) => _refreshAvailability(),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 Jam',
                  style: TextStyle(
                      color: CustomColors.mabarTextSecondary, fontSize: 12)),
              Text('12 Jam',
                  style: TextStyle(
                      color: CustomColors.mabarTextSecondary, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Metode Pembayaran ─────────────────────────────────────────────────────

  Widget _buildPaymentPicker() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _paymentMethods.length,
        itemBuilder: (context, i) {
          final m = _paymentMethods[i];
          final name = m['name'] as String;
          final isSelected = _paymentMethod == name;
          return GestureDetector(
            onTap: () => setState(() => _paymentMethod = name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? CustomColors.mabarBorderFocus
                    : CustomColors.mabarSurfaceCard,
                border: Border.all(
                  color: isSelected
                      ? CustomColors.mabarBorderFocus
                      : CustomColors.mabarBorderSubtle,
                ),
              ),
              child: Row(
                children: [
                  Icon(m['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : CustomColors.mabarTextSecondary),
                  const SizedBox(width: 7),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
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
    if (_loadingComputers) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(
              color: CustomColors.mabarBorderFocus),
        ),
      );
    }

    if (_computers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: CustomColors.mabarSurfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CustomColors.mabarBorderSubtle),
        ),
        child: const Column(
          children: [
            Icon(Icons.devices_other_outlined,
                size: 36, color: CustomColors.mabarTextTertiary),
            SizedBox(height: 10),
            Text(
              'Warnet ini belum menambahkan perangkat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CustomColors.mabarTextSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final pcIndices = _computers
        .asMap()
        .entries
        .where((e) => !_isConsole(e.value))
        .map((e) => e.key)
        .toList();

    final consoleIndices = _computers
        .asMap()
        .entries
        .where((e) => _isConsole(e.value))
        .map((e) => e.key)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _availabilityHint(),
        if (pcIndices.isNotEmpty) ...[
          _deviceSectionHeader(Icons.computer_outlined, 'PC', pcIndices.length),
          const SizedBox(height: 8),
          _buildKomputerGrid(pcIndices),
        ],
        if (consoleIndices.isNotEmpty) ...[
          if (pcIndices.isNotEmpty) const SizedBox(height: 20),
          _deviceSectionHeader(
              Icons.gamepad_outlined, 'Console', consoleIndices.length),
          const SizedBox(height: 8),
          _buildKomputerGrid(consoleIndices),
        ],
      ],
    );
  }

  /// Banner status ketersediaan di atas grid perangkat.
  Widget _availabilityHint() {
    late final IconData icon;
    late final String text;
    late final Color color;

    if (_startTime == null) {
      icon = Icons.info_outline;
      text = 'Pilih tanggal & jam dulu untuk lihat unit yang tersedia.';
      color = CustomColors.mabarTextSecondary;
    } else if (_loadingAvail) {
      icon = Icons.sync;
      text = 'Mengecek ketersediaan…';
      color = CustomColors.mabarTextSecondary;
    } else if (_bookedComputers.isEmpty) {
      icon = Icons.check_circle_outline;
      text = 'Semua unit tersedia di jam ini.';
      color = CustomColors.mabarGreen;
    } else {
      icon = Icons.event_busy_outlined;
      text = '${_bookedComputers.length} unit sudah dibooking di jam ini.';
      color = CustomColors.mabarYellow;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
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
        final komputer = _computers[index];
        final isSelected = selectedKomputer == index;
        final isBooked = _bookedComputers.contains(komputer['id']);
        final tierColor = _tierColor(komputer['tier'] as String);

        final Color nameColor = isBooked
            ? CustomColors.mabarTextTertiary
            : isSelected
                ? CustomColors.mabarBorderFocus
                : CustomColors.mabarTextPrimary;

        return GestureDetector(
          onTap: isBooked
              ? () => _showError(
                  '${komputer['name']} sudah dibooking di jam itu. Pilih jam lain atau unit lain.')
              : () => setState(() => selectedKomputer = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isBooked
                  ? CustomColors.mabarBgDark
                  : isSelected
                      ? CustomColors.mabarBorderFocus.withValues(alpha: 0.12)
                      : CustomColors.mabarSurfaceCard,
              border: Border.all(
                color: isSelected && !isBooked
                    ? CustomColors.mabarBorderFocus
                    : CustomColors.mabarBorderSubtle,
                width: isSelected && !isBooked ? 1.5 : 1,
              ),
            ),
            child: Stack(
              children: [
                Opacity(
                  opacity: isBooked ? 0.45 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            _iconFor(komputer),
                            width: 22,
                            color: nameColor,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              komputer['name'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: nameColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tierBadge(komputer['tier'] as String, tierColor),
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
                ),
                if (isBooked)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Dibooking',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else if (isSelected)
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
                ? '${_computers[selectedKomputer!]['name']} · ${_computers[selectedKomputer!]['spec']}'
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
          _summaryDivider(),
          _summaryRow(
            Icons.account_balance_wallet_outlined,
            'Pembayaran',
            _paymentMethod,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 15, color: CustomColors.mabarTextSecondary),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 13, color: CustomColors.mabarTextSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: CustomColors.mabarTextPrimary,
              height: 1.3,
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
