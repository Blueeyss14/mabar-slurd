import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/core/formatters.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/feat/booking/presentation/widgets/pilih_jam.dart';

class BookingHistoryDetailPage extends StatelessWidget {
  final String bookingId;
  final String title;
  final String subTitle;
  final String date;
  final String time;
  final int total;
  final String status;
  final int durationHours;
  final Map<String, dynamic> data;

  const BookingHistoryDetailPage({
    super.key,
    required this.bookingId,
    required this.title,
    required this.subTitle,
    required this.date,
    required this.time,
    required this.total,
    required this.status,
    required this.durationHours,
    this.data = const {},
  });

  ({Color color, IconData icon}) get _statusStyle {
    switch (status) {
      case 'Berlangsung':
        return (color: CustomColors.mabarYellow, icon: Icons.bolt);
      case 'Dibatalkan':
        return (color: Colors.redAccent, icon: Icons.close);
      default:
        return (color: CustomColors.mabarGreen, icon: Icons.check_circle);
    }
  }

  /// ID pendek untuk ditampilkan: 8 karakter pertama dari doc ID Firestore
  String get _shortBookingId =>
      '#${bookingId.substring(0, bookingId.length.clamp(0, 8)).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    // total_price disimpan dalam satuan ribuan (mis. 30 = Rp 30.000),
    // jadi dikali 1000 untuk mendapat rupiah penuh.
    final harga = total * 1000;

    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Detail Booking",
          style: TextStyle(
            color: CustomColors.mabarTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildStatusHeader(),
            const SizedBox(height: 20),
            _buildPlaceCard(),
            const SizedBox(height: 16),
            _buildDetailCard(),
            const SizedBox(height: 16),
            _buildPaymentCard(harga),
            if (status == 'Berlangsung') ...[
              const SizedBox(height: 16),
              _buildRescheduleButton(context),
              const SizedBox(height: 12),
              _buildCancelButton(context),
            ],
            if (status == 'Selesai') ...[
              const SizedBox(height: 16),
              _buildReviewButton(context),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    final s = _statusStyle;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: s.color.withValues(alpha: 0.12),
        border: Border.all(color: s.color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(s.icon, color: s.color, size: 48),
          const SizedBox(height: 10),
          Text(
            status,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: s.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID Booking: $_shortBookingId',
            style: const TextStyle(
              fontSize: 13,
              color: CustomColors.mabarTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CustomColors.mabarSurfaceCard,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: CustomColors.mabarPurpleBg,
            ),
            child: const Icon(
              Icons.sports_esports,
              color: CustomColors.mabarPurpleLight,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CustomColors.mabarTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CustomColors.mabarSurfaceCard,
      ),
      child: Column(
        children: [
          _buildRow(Icons.calendar_month_outlined, "Tanggal", date),
          const SizedBox(height: 16),
          _buildRow(Icons.access_time_rounded, "Waktu", time),
          const SizedBox(height: 16),
          _buildRow(Icons.devices_outlined, "Perangkat", subTitle),
          const SizedBox(height: 16),
          _buildRow(
            Icons.hourglass_bottom_rounded,
            "Durasi",
            '$durationHours Jam',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(int harga) {
    final paymentStatus = data['payment_status'] as String? ?? 'paid';
    final isPaid = paymentStatus == 'paid';
    final payBadgeColor = isPaid ? CustomColors.mabarGreen : Colors.orange;
    final payBadgeLabel = isPaid ? 'Lunas' : 'Belum Dibayar';
    final payBadgeIcon =
        isPaid ? Icons.check_circle_outline : Icons.timer_outlined;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CustomColors.mabarSurfaceCard,
      ),
      child: Column(
        children: [
          _buildPaymentRow(
              "Metode", data['payment_method'] as String? ?? 'Bayar di Tempat'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Status Bayar",
                style: TextStyle(
                    fontSize: 15, color: CustomColors.mabarTextSecondary),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: payBadgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(payBadgeIcon, size: 13, color: payBadgeColor),
                    const SizedBox(width: 5),
                    Text(
                      payBadgeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: payBadgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPaymentRow("Harga Sewa", "Rp ${Formatters.rupiah(harga)}"),
          const SizedBox(height: 14),
          const Divider(height: 1, color: CustomColors.mabarBorderSubtle),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Bayar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.mabarTextPrimary,
                ),
              ),
              Text(
                "Rp ${Formatters.rupiah(harga)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.mabarCyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRescheduleButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: CustomColors.mabarBorderFocus),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _openReschedule(context),
        icon: const Icon(Icons.edit_calendar_outlined,
            color: CustomColors.mabarBorderFocus),
        label: const Text(
          "Ubah Jadwal",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CustomColors.mabarBorderFocus,
          ),
        ),
      ),
    );
  }

  void _openReschedule(BuildContext context) {
    final venueId = data['venue_id'] as String?;
    final computerId = data['computer_id'] as String?;
    if (venueId == null || computerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data booking tidak lengkap.')),
      );
      return;
    }

    DateTime? newDate;
    int? newHour;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheet) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: CustomColors.mabarSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: CustomColors.mabarBorderSubtle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ubah Jadwal',
                      style: TextStyle(
                          color: CustomColors.mabarTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(
                    'Durasi $durationHours jam · $subTitle (tetap)',
                    style: const TextStyle(
                        color: CustomColors.mabarTextSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  // Pilih tanggal
                  GestureDetector(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: sheetCtx,
                        initialDate: now,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 30)),
                      );
                      if (picked != null) setSheet(() => newDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: CustomColors.mabarSurfaceInput,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month,
                              size: 18, color: CustomColors.mabarBorderFocus),
                          const SizedBox(width: 10),
                          Text(
                            newDate != null
                                ? Formatters.tanggal(newDate!)
                                : 'Pilih tanggal baru',
                            style: TextStyle(
                              color: newDate != null
                                  ? CustomColors.mabarTextPrimary
                                  : CustomColors.mabarTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Jam mulai baru',
                      style: TextStyle(
                          color: CustomColors.mabarTextSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(pilihJam.length, (i) {
                      final jam = pilihJam[i]['jam'] as String;
                      final hour = int.parse(jam.split(':')[0]);
                      final sel = newHour == hour;
                      return GestureDetector(
                        onTap: () => setSheet(() => newHour = hour),
                        child: Container(
                          width: 52,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: sel
                                ? CustomColors.mabarBorderFocus
                                : CustomColors.mabarSurfaceCard,
                            border: Border.all(
                              color: sel
                                  ? CustomColors.mabarBorderFocus
                                  : CustomColors.mabarBorderSubtle,
                            ),
                          ),
                          child: Text(jam,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: CustomColors.mabarTextPrimary,
                                  fontWeight: sel
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.mabarBorderFocus,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () =>
                          _submitReschedule(context, sheetCtx, venueId,
                              computerId, newDate, newHour),
                      child: const Text('Simpan Jadwal Baru',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitReschedule(
    BuildContext pageCtx,
    BuildContext sheetCtx,
    String venueId,
    String computerId,
    DateTime? newDate,
    int? newHour,
  ) async {
    final messenger = ScaffoldMessenger.of(pageCtx);
    if (newDate == null || newHour == null) {
      ScaffoldMessenger.of(sheetCtx).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal & jam dulu.')),
      );
      return;
    }
    final start =
        DateTime(newDate.year, newDate.month, newDate.day, newHour);
    if (start.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(sheetCtx).showSnackBar(
        const SnackBar(content: Text('Tidak bisa pilih waktu yang sudah lewat.')),
      );
      return;
    }
    final end = start.add(Duration(hours: durationHours));
    final navigator = Navigator.of(pageCtx);
    Navigator.pop(sheetCtx);

    final ok = await FirestoreService.rescheduleBooking(
      bookingId: bookingId,
      venueId: venueId,
      computerId: computerId,
      startTime: start,
      endTime: end,
      durationHours: durationHours,
      totalPrice: total,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Jadwal berhasil diubah.'
              : 'Gagal: perangkat sudah dibooking di waktu itu.',
          style: const TextStyle(
              color: CustomColors.mabarTextPrimary,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: ok ? CustomColors.mabarPurpleBg : Colors.red.shade800,
      ),
    );
    if (ok) navigator.pop();
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _confirmCancel(context),
        icon: const Icon(Icons.close, color: Colors.redAccent),
        label: const Text(
          "Batalkan Booking",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: CustomColors.mabarSurfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Batalkan Booking",
            style: TextStyle(
              color: CustomColors.mabarTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Yakin mau membatalkan booking ini? Tindakan ini tidak bisa diurungkan.",
            style: TextStyle(color: CustomColors.mabarTextSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "Tidak",
                style: TextStyle(color: CustomColors.mabarTextSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final ok = await FirestoreService.cancelBooking(bookingId);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Booking berhasil dibatalkan'
                          : 'Gagal membatalkan booking',
                      style: const TextStyle(
                        color: CustomColors.mabarTextPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor:
                        ok ? CustomColors.mabarPurpleBg : Colors.red.shade800,
                  ),
                );
                if (ok) navigator.pop();
              },
              child: const Text(
                "Ya, Batalkan",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReviewButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: CustomColors.mabarStar),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _openReviewSheet(context),
        icon: const Icon(Icons.star_rate_outlined, color: CustomColors.mabarStar),
        label: const Text(
          'Beri Ulasan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CustomColors.mabarStar,
          ),
        ),
      ),
    );
  }

  void _openReviewSheet(BuildContext context) {
    final venueId = data['venue_id'] as String?;
    if (venueId == null) return;

    int rating = 5;
    final commentC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) => Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: CustomColors.mabarSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: CustomColors.mabarBorderSubtle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Beri Ulasan · $title',
                    style: const TextStyle(
                      color: CustomColors.mabarTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        onPressed: () => setSheet(() => rating = i + 1),
                        icon: Icon(
                          i < rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: CustomColors.mabarStar,
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: commentC,
                    maxLines: 3,
                    style: const TextStyle(color: CustomColors.mabarTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'Tulis pengalamanmu (opsional)...',
                      hintStyle: const TextStyle(
                          color: CustomColors.mabarTextTertiary),
                      filled: true,
                      fillColor: CustomColors.mabarSurfaceInput,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.mabarBorderFocus,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await FirestoreService.addReview(
                          venueId,
                          rating: rating,
                          comment: commentC.text,
                        );
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Ulasan terkirim. Terima kasih!'
                                  : 'Gagal mengirim ulasan.',
                              style: const TextStyle(
                                color: CustomColors.mabarTextPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: ok
                                ? CustomColors.mabarPurpleBg
                                : Colors.red.shade800,
                          ),
                        );
                      },
                      child: const Text(
                        'Kirim Ulasan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(commentC.dispose);
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: CustomColors.mabarPurpleLight),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: CustomColors.mabarTextSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: CustomColors.mabarTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: CustomColors.mabarTextSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: CustomColors.mabarTextPrimary,
          ),
        ),
      ],
    );
  }
}
