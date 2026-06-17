import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/core/formatters.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/mabar_empty_state.dart';

/// Daftar venue milik admin. Untuk sementara read-only;
/// pengeditan info & komputer akan ditambahkan pada fase berikutnya.
class AdminVenuesPage extends StatelessWidget {
  const AdminVenuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirestoreService.getMyVenues(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: CustomColors.mabarBorderFocus,
                ),
              );
            }

            final venues = snap.data ?? [];

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              children: [
                const Text(
                  "Venue Saya",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const Text(
                  "Warnet yang terdaftar atas akunmu",
                  style: TextStyle(
                    fontSize: 13,
                    color: CustomColors.mabarTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                if (venues.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: MabarEmptyState(
                      icon: Icons.storefront_outlined,
                      title: "Belum ada venue",
                      subtitle:
                          "Belum ada warnet terdaftar atas akun ini.",
                    ),
                  )
                else
                  ...venues.map(_venueCard),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _venueCard(Map<String, dynamic> v) {
    final price = (v['price_per_hour'] as num?)?.toInt() ?? 0;
    final rating = (v['rating'] as num?)?.toDouble() ?? 0;
    final badge = v['badge'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomColors.mabarBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  v['name'] as String? ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: CustomColors.mabarBorderFocus.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: CustomColors.mabarBorderFocus,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  size: 16, color: CustomColors.mabarStar),
              const SizedBox(width: 4),
              Text(
                rating.toString(),
                style: const TextStyle(
                  fontSize: 13,
                  color: CustomColors.mabarTextSecondary,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.payments_outlined,
                  size: 15, color: CustomColors.mabarTextSecondary),
              const SizedBox(width: 4),
              Text(
                'Rp ${Formatters.rupiah(price * 1000)}/jam',
                style: const TextStyle(
                  fontSize: 13,
                  color: CustomColors.mabarTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
