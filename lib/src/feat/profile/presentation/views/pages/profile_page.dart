import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/feat/auth/presentation/views/login_screen.dart';
import 'package:mabar_slurd/src/feat/profile/presentation/views/pages/edit_profile_page.dart';
import 'package:mabar_slurd/src/feat/profile/presentation/views/pages/notification_page.dart';
import 'package:mabar_slurd/src/feat/profile/presentation/views/pages/payment_method_page.dart';
import 'package:mabar_slurd/src/feat/profile/presentation/views/pages/help_page.dart';
import 'package:mabar_slurd/src/feat/profile/presentation/views/pages/about_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Profil",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: CustomColors.mabarTextPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 25),
              _buildMenuSection(context),
              const SizedBox(height: 25),
              _buildLogoutButton(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: CustomColors.mabarSurfaceCard,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: CustomColors.mabarBorderFocus,
            ),
            child: const Icon(
              Icons.person,
              size: 48,
              color: CustomColors.mabarTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "pro_gamer_99",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: CustomColors.mabarTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "gaming@example.com",
            style: TextStyle(
              fontSize: 14,
              color: CustomColors.mabarTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: CustomColors.mabarSurfaceCard,
      ),
      child: Column(
        children: [
          _ProfileMenuItem(
            icon: Icons.person_outline,
            title: "Edit Profil",
            onTap: () => _goTo(context, const EditProfilePage()),
          ),
          _ProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: "Notifikasi",
            onTap: () => _goTo(context, const NotificationPage()),
          ),
          _ProfileMenuItem(
            icon: Icons.payment_outlined,
            title: "Metode Pembayaran",
            onTap: () => _goTo(context, const PaymentMethodPage()),
          ),
          _ProfileMenuItem(
            icon: Icons.help_outline,
            title: "Bantuan",
            onTap: () => _goTo(context, const HelpPage()),
          ),
          _ProfileMenuItem(
            icon: Icons.info_outline,
            title: "Tentang Aplikasi",
            showDivider: false,
            onTap: () => _goTo(context, const AboutPage()),
          ),
        ],
      ),
    );
  }

  void _goTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmLogout(context),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CustomColors.mabarBorderSubtle),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 10),
            Text(
              "Keluar",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: CustomColors.mabarSurfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Keluar Akun",
            style: TextStyle(
              color: CustomColors.mabarTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Yakin mau keluar dari akun kamu?",
            style: TextStyle(color: CustomColors.mabarTextSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "Batal",
                style: TextStyle(color: CustomColors.mabarTextSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                "Keluar",
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
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool showDivider;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.showDivider = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(icon, color: CustomColors.mabarBorderFocus),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: CustomColors.mabarTextPrimary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: CustomColors.mabarTextTertiary,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          const Divider(
            height: 1,
            color: CustomColors.mabarBorderSubtle,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
