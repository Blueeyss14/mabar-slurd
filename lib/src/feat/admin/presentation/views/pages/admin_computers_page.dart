import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/res/assets.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/mabar_empty_state.dart';

/// Kelola unit perangkat (PC/Console) milik satu venue.
class AdminComputersPage extends StatelessWidget {
  final String venueId;
  final String venueName;

  const AdminComputersPage({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  static const _tiers = ['Reguler', 'Gaming', 'VIP', 'Console'];
  static const _types = ['PC', 'Console'];

  Color _tierColor(String tier) {
    switch (tier) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kelola Perangkat',
                style: TextStyle(
                    color: CustomColors.mabarTextPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text(venueName,
                style: const TextStyle(
                    color: CustomColors.mabarTextSecondary, fontSize: 12)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.mabarBorderFocus,
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Unit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.getVenueComputers(venueId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: CustomColors.mabarBorderFocus),
            );
          }

          final units = snap.data ?? [];

          if (units.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MabarEmptyState(
                    icon: Icons.devices_other_outlined,
                    title: "Belum ada perangkat",
                    subtitle:
                        "Tambah unit satu per satu, atau isi cepat 15 unit standar.",
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.mabarBorderFocus,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _seedDefaults(context),
                    icon: const Icon(Icons.bolt, color: Colors.white, size: 18),
                    label: const Text('Isi 15 Unit Standar',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            itemCount: units.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _unitCard(context, units[i]),
          );
        },
      ),
    );
  }

  Widget _unitCard(BuildContext context, Map<String, dynamic> u) {
    final tier = u['tier'] as String? ?? 'Reguler';
    final type = u['type'] as String? ?? 'PC';
    final color = _tierColor(tier);
    final icon = type == 'Console' ? AssetIcons.gamepad : AssetIcons.pc;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CustomColors.mabarBorderSubtle),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 26, color: CustomColors.mabarTextPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      u['name'] as String? ?? u['code'] as String? ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: CustomColors.mabarTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: color.withValues(alpha: 0.5), width: 0.8),
                      ),
                      child: Text(tier,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: color)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(u['spec'] as String? ?? '-',
                    style: const TextStyle(
                        fontSize: 12,
                        color: CustomColors.mabarTextSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                size: 19, color: CustomColors.mabarTextSecondary),
            onPressed: () => _openForm(context, unit: u),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 19, color: Colors.red.shade400),
            onPressed: () => _confirmDelete(context, u),
          ),
        ],
      ),
    );
  }

  Future<void> _seedDefaults(BuildContext context) async {
    final ok = await FirestoreService.seedDefaultComputers(venueId);
    if (!context.mounted) return;
    _snack(context, ok ? '15 unit standar ditambahkan.' : 'Gagal mengisi unit.',
        isError: !ok);
  }

  Future<void> _confirmDelete(
      BuildContext context, Map<String, dynamic> u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Unit?',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Hapus ${u['name'] ?? u['code']} dari daftar?',
            style: const TextStyle(color: Colors.white70)),
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
    final success =
        await FirestoreService.deleteComputer(venueId, u['docId'] as String);
    if (!context.mounted) return;
    _snack(context, success ? 'Unit dihapus.' : 'Gagal menghapus unit.',
        isError: !success);
  }

  void _openForm(BuildContext context, {Map<String, dynamic>? unit}) {
    final isEdit = unit != null;
    final codeC = TextEditingController(text: unit?['code'] as String? ?? '');
    final nameC = TextEditingController(
        text: unit?['name'] as String? ?? unit?['code'] as String? ?? '');
    final specC = TextEditingController(text: unit?['spec'] as String? ?? '');
    String tier = (unit?['tier'] as String?) ?? 'Reguler';
    String type = (unit?['type'] as String?) ?? 'PC';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
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
                  Text(isEdit ? 'Edit Unit' : 'Tambah Unit',
                      style: const TextStyle(
                          color: CustomColors.mabarTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const SizedBox(height: 16),
                  _field(codeC, 'Kode (mis. PC-13 / PS5-04)'),
                  const SizedBox(height: 10),
                  _field(nameC, 'Nama tampilan'),
                  const SizedBox(height: 10),
                  _field(specC, 'Spesifikasi (mis. i7 / RTX 4070)'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _dropdown('Tier', tier, _tiers,
                            (v) => setSheet(() => tier = v!)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dropdown('Tipe', type, _types,
                            (v) => setSheet(() => type = v!)),
                      ),
                    ],
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
                      onPressed: () async {
                        final code = codeC.text.trim();
                        if (code.isEmpty) {
                          _snack(ctx, 'Kode tidak boleh kosong.',
                              isError: true);
                          return;
                        }
                        final name =
                            nameC.text.trim().isEmpty ? code : nameC.text.trim();
                        bool ok;
                        if (isEdit) {
                          ok = await FirestoreService.updateComputer(
                            venueId,
                            unit['docId'] as String,
                            code: code,
                            name: name,
                            spec: specC.text,
                            tier: tier,
                            type: type,
                          );
                        } else {
                          ok = await FirestoreService.addComputer(
                            venueId,
                            code: code,
                            name: name,
                            spec: specC.text,
                            tier: tier,
                            type: type,
                          );
                        }
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        _snack(context,
                            ok ? 'Unit disimpan.' : 'Gagal menyimpan unit.',
                            isError: !ok);
                      },
                      child: Text(isEdit ? 'Simpan' : 'Tambah',
                          style: const TextStyle(
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

  Widget _field(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      style: const TextStyle(color: CustomColors.mabarTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: CustomColors.mabarTextTertiary),
        filled: true,
        fillColor: CustomColors.mabarSurfaceInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: CustomColors.mabarSurfaceCard,
          style: const TextStyle(color: CustomColors.mabarTextPrimary),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _snack(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: CustomColors.mabarTextPrimary,
                fontWeight: FontWeight.bold)),
        backgroundColor:
            isError ? Colors.red.shade800 : CustomColors.mabarPurpleBg,
      ),
    );
  }
}
