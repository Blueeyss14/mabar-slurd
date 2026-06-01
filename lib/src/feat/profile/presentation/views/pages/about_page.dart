import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Tentang Aplikasi",
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: CustomColors.mabarPurpleLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.sports_esports,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "MabarKeun",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: CustomColors.mabarTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Versi 1.0.0",
              style: TextStyle(
                fontSize: 14,
                color: CustomColors.mabarTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "MabarKeun adalah aplikasi untuk mencari dan booking tempat gaming terdekat. Temukan warnet dan gaming spot favorit, lihat fasilitasnya, lalu pesan slot dengan mudah.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: CustomColors.mabarTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoTile(Icons.business_outlined, "Pengembang", "Tim MabarKeun"),
            _buildInfoTile(Icons.description_outlined, "Syarat & Ketentuan", ""),
            _buildInfoTile(Icons.privacy_tip_outlined, "Kebijakan Privasi", ""),
            _buildInfoTile(Icons.star_outline, "Beri Rating", ""),
            const SizedBox(height: 24),
            const Text(
              "© 2026 MabarKeun. Hak cipta dilindungi.",
              style: TextStyle(
                fontSize: 12,
                color: CustomColors.mabarTextTertiary,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: CustomColors.mabarPurpleLight),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: CustomColors.mabarTextPrimary,
          ),
        ),
        trailing: value.isNotEmpty
            ? Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: CustomColors.mabarTextSecondary,
                ),
              )
            : const Icon(
                Icons.chevron_right,
                color: CustomColors.mabarTextTertiary,
              ),
      ),
    );
  }
}
