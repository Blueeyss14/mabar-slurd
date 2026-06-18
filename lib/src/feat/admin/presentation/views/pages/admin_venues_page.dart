import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/core/formatters.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/mabar_empty_state.dart';
import 'package:mabar_slurd/src/feat/admin/presentation/views/pages/admin_venue_form_page.dart';
import 'package:mabar_slurd/src/feat/admin/presentation/views/pages/admin_computers_page.dart';

/// Daftar venue milik admin. Bisa tambah venue baru & edit info venue.
class AdminVenuesPage extends StatelessWidget {
  const AdminVenuesPage({super.key});

  void _openForm(BuildContext context, {Map<String, dynamic>? venue}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminVenueFormPage(venue: venue)),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, Map<String, dynamic> v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Venue?',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Warnet "${v['name'] ?? '-'}" akan dihapus permanen. Lanjutkan?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: CustomColors.mabarTextSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus',
                style: TextStyle(
                    color: Colors.red.shade400, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final success = await FirestoreService.deleteVenue(v['id'] as String);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Venue dihapus.' : 'Gagal menghapus venue.',
          style: const TextStyle(
              color: CustomColors.mabarTextPrimary,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            success ? CustomColors.mabarPurpleBg : Colors.red.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.mabarBorderFocus,
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Venue',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        const MabarEmptyState(
                          icon: Icons.storefront_outlined,
                          title: "Belum ada venue",
                          subtitle:
                              "Buat warnet pertamamu agar bisa menerima booking.",
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => _openForm(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: CustomColors.mabarBorderFocus),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add,
                              color: CustomColors.mabarBorderFocus),
                          label: const Text(
                            'Buat Venue',
                            style: TextStyle(
                              color: CustomColors.mabarBorderFocus,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...venues.map((v) => _venueCard(context, v)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _venueCard(BuildContext context, Map<String, dynamic> v) {
    final price = (v['price_per_hour'] as num?)?.toInt() ?? 0;
    final rating = (v['rating'] as num?)?.toDouble() ?? 0;
    final badge = v['badge'] as String?;

    return GestureDetector(
      onTap: () => _openForm(context, venue: v),
      child: Container(
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
                GestureDetector(
                  onTap: () => _confirmDelete(context, v),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.delete_outline,
                        size: 20, color: Colors.red.shade400),
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
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openForm(context, venue: v),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: CustomColors.mabarBorderSubtle),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.edit_outlined,
                        size: 16, color: CustomColors.mabarTextSecondary),
                    label: const Text('Edit Info',
                        style: TextStyle(
                            color: CustomColors.mabarTextSecondary,
                            fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminComputersPage(
                          venueId: v['id'] as String,
                          venueName: v['name'] as String? ?? '-',
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          CustomColors.mabarBorderFocus.withValues(alpha: 0.15),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.devices_other_outlined,
                        size: 16, color: CustomColors.mabarBorderFocus),
                    label: const Text('Perangkat',
                        style: TextStyle(
                            color: CustomColors.mabarBorderFocus,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
