import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';

class BookingHistoryDetailPage extends StatelessWidget {
  final String bookingId;
  final String title;
  final String subTitle;
  final String date;
  final String time;
  final int total;
  final String status;
  final int durationHours;

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
  });

  String _formatRupiah(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

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
    const biayaLayanan = 2000;
    final totalBayar = harga + biayaLayanan;

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
            _buildPaymentCard(harga, biayaLayanan, totalBayar),
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

  Widget _buildPaymentCard(int harga, int biayaLayanan, int totalBayar) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CustomColors.mabarSurfaceCard,
      ),
      child: Column(
        children: [
          _buildPaymentRow("Harga Sewa", "Rp ${_formatRupiah(harga)}"),
          const SizedBox(height: 12),
          _buildPaymentRow(
            "Biaya Layanan",
            "Rp ${_formatRupiah(biayaLayanan)}",
          ),
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
                "Rp ${_formatRupiah(totalBayar)}",
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
