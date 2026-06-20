import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/core/storage_service.dart';
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
  final _imageController = TextEditingController();
  final _hoursController = TextEditingController();
  bool _isLoading = false;

  double? _lat;
  double? _lng;
  String? _address;
  bool _loadingLoc = false;
  bool _uploadingImage = false;

  final Set<String> _facilities = {};
  static const _facilityOptions = [
    'AC',
    'WiFi',
    'Toilet',
    'Kantin',
    'Parkir',
    'Mushola',
    'Smoking Area',
    'Snack',
  ];

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
      _imageController.text = v['image_url'] as String? ?? '';
      _hoursController.text = v['hours'] as String? ?? '';
      _lat = (v['lat'] as num?)?.toDouble();
      _lng = (v['lng'] as num?)?.toDouble();
      _address = v['address'] as String?;
      final fac = v['facilities'];
      if (fac is List) {
        _facilities.addAll(fac.map((e) => e.toString()));
      }
    }
  }

  Future<void> _pakaiLokasiSaya() async {
    setState(() => _loadingLoc = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _snack('GPS belum aktif. Aktifkan dulu ya.', isError: true);
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _snack('Izin lokasi ditolak.', isError: true);
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      String? addr;
      try {
        final placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          addr = [p.street, p.subLocality, p.locality, p.subAdministrativeArea]
              .where((e) => e != null && e.isNotEmpty)
              .join(', ');
        }
      } catch (_) {
        // geocoding gagal -> simpan koordinat saja
      }

      if (!mounted) return;
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _address = (addr != null && addr.isNotEmpty)
            ? addr
            : '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
      });
    } catch (e) {
      _snack('Gagal ambil lokasi: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loadingLoc = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _uploadingImage = true);
    final url = await StorageService.uploadVenueImage(picked.path);
    if (!mounted) return;
    setState(() {
      _uploadingImage = false;
      if (url != null) _imageController.text = url;
    });
    if (url == null) {
      _snack('Gagal upload foto. Pastikan Storage aktif.', isError: true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _badgeController.dispose();
    _imageController.dispose();
    _hoursController.dispose();
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
        lat: _lat,
        lng: _lng,
        address: _address,
        imageUrl: _imageController.text,
        hours: _hoursController.text,
        facilities: _facilities.toList(),
      );
    } else {
      final id = await FirestoreService.createVenue(
        name: name,
        pricePerHour: price,
        badge: _badgeController.text,
        lat: _lat,
        lng: _lng,
        address: _address,
        imageUrl: _imageController.text,
        hours: _hoursController.text,
        facilities: _facilities.toList(),
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
            const SizedBox(height: 20),
            _label('FOTO WARNET'),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: CustomColors.mabarBorderFocus),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _uploadingImage ? null : _pickAndUpload,
                icon: _uploadingImage
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: CustomColors.mabarBorderFocus,
                        ),
                      )
                    : const Icon(Icons.photo_library_outlined,
                        size: 18, color: CustomColors.mabarBorderFocus),
                label: Text(
                  _uploadingImage ? 'Mengunggah…' : 'Upload dari Galeri',
                  style: const TextStyle(
                    color: CustomColors.mabarBorderFocus,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Atau tempel URL gambar:',
              style: TextStyle(
                fontSize: 11,
                color: CustomColors.mabarTextTertiary,
              ),
            ),
            const SizedBox(height: 6),
            MabarTextField(
              controller: _imageController,
              hintText: 'https://...jpg',
              iconData: Icons.link,
            ),
            _buildImagePreview(),
            const SizedBox(height: 20),
            _label('JAM BUKA'),
            MabarTextField(
              controller: _hoursController,
              hintText: '10:00 - 24:00',
              iconData: Icons.access_time,
            ),
            const SizedBox(height: 20),
            _label('FASILITAS'),
            _buildFacilityChips(),
            const SizedBox(height: 20),
            _label('LOKASI WARNET'),
            _buildLocationBox(),
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

  Widget _buildImagePreview() {
    final url = _imageController.text.trim();
    if (url.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 120,
            alignment: Alignment.center,
            color: CustomColors.mabarSurfaceInput,
            child: const Text(
              'URL gambar tidak valid',
              style: TextStyle(color: CustomColors.mabarTextTertiary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _facilityOptions.map((f) {
        final selected = _facilities.contains(f);
        return GestureDetector(
          onTap: () => setState(() {
            if (selected) {
              _facilities.remove(f);
            } else {
              _facilities.add(f);
            }
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: selected
                  ? CustomColors.mabarBorderFocus
                  : CustomColors.mabarSurfaceInput,
              border: Border.all(
                color: selected
                    ? CustomColors.mabarBorderFocus
                    : CustomColors.mabarBorderSubtle,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? Icons.check : Icons.add,
                  size: 14,
                  color: selected
                      ? Colors.white
                      : CustomColors.mabarTextSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  f,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                    color: selected
                        ? Colors.white
                        : CustomColors.mabarTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationBox() {
    final hasLoc = _lat != null && _lng != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceInput,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CustomColors.mabarBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasLoc ? Icons.location_on : Icons.location_off_outlined,
                size: 18,
                color: hasLoc
                    ? CustomColors.mabarBorderFocus
                    : CustomColors.mabarTextTertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasLoc
                      ? (_address ?? 'Lokasi tersimpan')
                      : 'Lokasi belum diatur',
                  style: TextStyle(
                    fontSize: 13,
                    color: hasLoc
                        ? CustomColors.mabarTextPrimary
                        : CustomColors.mabarTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (hasLoc) ...[
            const SizedBox(height: 4),
            Text(
              '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
              style: const TextStyle(
                fontSize: 11,
                color: CustomColors.mabarTextTertiary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: CustomColors.mabarBorderFocus),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _loadingLoc ? null : _pakaiLokasiSaya,
              icon: _loadingLoc
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CustomColors.mabarBorderFocus,
                      ),
                    )
                  : const Icon(Icons.my_location,
                      size: 17, color: CustomColors.mabarBorderFocus),
              label: Text(
                _loadingLoc
                    ? 'Mengambil lokasi…'
                    : (hasLoc ? 'Perbarui Lokasi' : 'Pakai Lokasi Saya'),
                style: const TextStyle(
                  color: CustomColors.mabarBorderFocus,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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
