import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/mabar_text_field.dart';

/// Form buat / edit venue. Bila [venue] null = mode buat baru,
/// selain itu mode edit.
class AdminVenueFormPage extends StatefulWidget {
  final Map<String, dynamic>? venue;

  const AdminVenueFormPage({super.key, this.venue});

  @override
  State<AdminVenueFormPage> createState() => _AdminVenueFormPageState();
}

class _AdminVenueFormPageState extends State<AdminVenueFormPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _badgeController = TextEditingController();
  bool _isLoading = false;

  bool get _isEdit => widget.venue != null;

  @override
  void initState() {
    super.initState();
    final v = widget.venue;
    if (v != null) {
      _nameController.text = v['name'] as String? ?? '';
      _priceController.text =
          ((v['price_per_hour'] as num?)?.toInt() ?? 0).toString();
      _badgeController.text = v['badge'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? -1;

    if (name.isEmpty) {
      _snack('Nama warnet tidak boleh kosong.', isError: true);
      return;
    }
    if (price < 0) {
      _snack('Harga per jam harus angka yang valid.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    bool ok;
    if (_isEdit) {
      ok = await FirestoreService.updateVenue(
        venueId: widget.venue!['id'] as String,
        name: name,
        pricePerHour: price,
        badge: _badgeController.text,
      );
    } else {
      final id = await FirestoreService.createVenue(
        name: name,
        pricePerHour: price,
        badge: _badgeController.text,
      );
      ok = id != null;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    _snack(
      ok
          ? (_isEdit ? 'Venue diperbarui.' : 'Venue berhasil dibuat.')
          : 'Gagal menyimpan venue.',
      isError: !ok,
    );
    if (ok) Navigator.pop(context);
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: CustomColors.mabarTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            isError ? Colors.red.shade800 : CustomColors.mabarPurpleBg,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEdit ? 'Edit Venue' : 'Tambah Venue',
          style: const TextStyle(
            color: CustomColors.mabarTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _label('NAMA WARNET'),
            MabarTextField(
              controller: _nameController,
              hintText: 'GG Arena',
              iconData: Icons.storefront_outlined,
            ),
            const SizedBox(height: 20),
            _label('HARGA PER JAM (RIBUAN)'),
            MabarTextField(
              controller: _priceController,
              hintText: '15  (= Rp 15.000)',
              iconData: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 6),
            const Text(
              'Contoh: ketik 15 untuk Rp 15.000 per jam.',
              style: TextStyle(
                fontSize: 11,
                color: CustomColors.mabarTextTertiary,
              ),
            ),
            const SizedBox(height: 20),
            _label('LABEL (OPSIONAL)'),
            MabarTextField(
              controller: _badgeController,
              hintText: 'Populer / Baru / 24 Jam',
              iconData: Icons.local_offer_outlined,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.mabarPurpleLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isLoading ? null : _simpan,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _isEdit ? 'SIMPAN PERUBAHAN' : 'BUAT VENUE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: CustomColors.mabarTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
