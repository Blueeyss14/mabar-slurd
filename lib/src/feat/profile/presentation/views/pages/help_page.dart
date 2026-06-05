import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const List<Map<String, String>> _faq = [
    {
      'q': 'Bagaimana cara booking tempat?',
      'a': 'Pilih tempat di halaman Beranda, buka detailnya, lalu tekan tombol Booking Sekarang dan atur tanggal, jam, serta perangkat.',
    },
    {
      'q': 'Bagaimana cara membatalkan booking?',
      'a': 'Buka menu Riwayat, pilih booking yang ingin dibatalkan, lalu tekan tombol Batalkan. Pembatalan bisa dilakukan maksimal 1 jam sebelum jadwal.',
    },
    {
      'q': 'Metode pembayaran apa saja yang didukung?',
      'a': 'Kami mendukung GoPay, OVO, QRIS, kartu kredit/debit, serta bayar tunai di tempat.',
    },
    {
      'q': 'Apakah bisa refund?',
      'a': 'Refund tersedia untuk pembatalan yang memenuhi syarat dan akan diproses dalam 3-5 hari kerja.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Bantuan",
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const Text(
            "Pertanyaan Umum",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CustomColors.mabarTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._faq.map(_buildFaqItem),
          const SizedBox(height: 24),
          const Text(
            "Masih butuh bantuan?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CustomColors.mabarTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildContactTile(
            icon: Icons.chat_bubble_outline,
            title: "Live Chat",
            subtitle: "Balasan dalam beberapa menit",
          ),
          const SizedBox(height: 12),
          _buildContactTile(
            icon: Icons.email_outlined,
            title: "Email",
            subtitle: "bantuan@mabarkeun.id",
          ),
          const SizedBox(height: 12),
          _buildContactTile(
            icon: Icons.phone_outlined,
            title: "Telepon",
            subtitle: "0800-1234-5678 (bebas pulsa)",
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          colorScheme: const ColorScheme.dark(
            primary: CustomColors.mabarPurpleLight,
          ),
        ),
        child: ExpansionTile(
          iconColor: CustomColors.mabarPurpleLight,
          collapsedIconColor: CustomColors.mabarTextTertiary,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            item['q']!,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: CustomColors.mabarTextPrimary,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item['a']!,
                style: const TextStyle(
                  fontSize: 14,
                  color: CustomColors.mabarTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: CustomColors.mabarPurpleBg,
            ),
            child: Icon(icon, color: CustomColors.mabarPurpleLight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CustomColors.mabarTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: CustomColors.mabarTextTertiary,
          ),
        ],
      ),
    );
  }
}
