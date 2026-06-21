import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/core/formatters.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';

/// Bagian ulasan di halaman detail venue: rata-rata rating, daftar ulasan,
/// dan tombol tulis ulasan untuk user yang login.
class VenueReviews extends StatefulWidget {
  final String venueId;

  const VenueReviews({super.key, required this.venueId});

  @override
  State<VenueReviews> createState() => _VenueReviewsState();
}

class _VenueReviewsState extends State<VenueReviews> {
  List<Map<String, dynamic>> _reviews = [];
  bool _loading = true;
  bool _hasBooked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      FirestoreService.getVenueReviews(widget.venueId),
      FirestoreService.hasUserBooked(widget.venueId),
    ]);
    if (!mounted) return;
    setState(() {
      _reviews = results[0] as List<Map<String, dynamic>>;
      _hasBooked = results[1] as bool;
      _loading = false;
    });
  }

  double get _avg {
    if (_reviews.isEmpty) return 0;
    final sum = _reviews.fold<int>(
        0, (acc, r) => acc + ((r['rating'] as num?)?.toInt() ?? 0));
    return sum / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Ulasan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: CustomColors.mabarTextPrimary,
              ),
            ),
            const Spacer(),
            if (_reviews.isNotEmpty) ...[
              const Icon(Icons.star_rounded,
                  color: CustomColors.mabarStar, size: 20),
              const SizedBox(width: 4),
              Text(
                '${_avg.toStringAsFixed(1)} (${_reviews.length})',
                style: const TextStyle(
                  color: CustomColors.mabarTextSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                  color: CustomColors.mabarBorderFocus),
            ),
          )
        else if (_reviews.isEmpty)
          const Text(
            'Belum ada ulasan. Jadilah yang pertama!',
            style: TextStyle(color: CustomColors.mabarTextSecondary),
          )
        else
          ..._reviews.take(5).map(_reviewTile),
        const SizedBox(height: 12),
        if (_hasBooked)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: CustomColors.mabarBorderFocus),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _openWriteSheet,
              icon: const Icon(Icons.rate_review_outlined,
                  color: CustomColors.mabarBorderFocus, size: 18),
              label: const Text(
                'Tulis Ulasan',
                style: TextStyle(
                  color: CustomColors.mabarBorderFocus,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else if (!_loading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: CustomColors.mabarSurfaceCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline,
                    size: 15, color: CustomColors.mabarTextTertiary),
                SizedBox(width: 8),
                Text(
                  'Booking dulu untuk bisa memberi ulasan',
                  style: TextStyle(
                      color: CustomColors.mabarTextTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _reviewTile(Map<String, dynamic> r) {
    final rating = (r['rating'] as num?)?.toInt() ?? 0;
    final created = (r['created_at'] as Timestamp?)?.toDate();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r['user_name'] as String? ?? 'Pengguna',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 15,
                    color: CustomColors.mabarStar,
                  ),
                ),
              ),
            ],
          ),
          if ((r['comment'] as String?)?.isNotEmpty ?? false) ...[
            const SizedBox(height: 6),
            Text(
              r['comment'] as String,
              style: const TextStyle(
                color: CustomColors.mabarTextSecondary,
                fontSize: 13,
              ),
            ),
          ],
          if (created != null) ...[
            const SizedBox(height: 6),
            Text(
              Formatters.tanggal(created),
              style: const TextStyle(
                color: CustomColors.mabarTextTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openWriteSheet() {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login dulu untuk menulis ulasan.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewSheet(
        venueId: widget.venueId,
        onSubmitted: _load,
      ),
    );
  }
}

/// Isi bottom sheet "Tulis Ulasan", dipisah jadi StatefulWidget sendiri.
///
/// KENAPA DIPISAH (fix bug "TextEditingController was used after disposed"):
/// Future yang dikembalikan showModalBottomSheet() selesai begitu route
/// di-pop SECARA LOGIS (sinkron), BUKAN setelah animasi penutupan sheet
/// benar-benar kelar (animasinya masih jalan ~200-300ms). Kalau controller
/// di-dispose lewat `.whenComplete()` pada Future itu (cara lama), ada
/// jendela waktu di mana TextField masih tampil & menerima event
/// fokus/keyboard-hide, padahal controller-nya sudah dibuang -> exception,
/// lalu nge-cascade jadi RenderFlex overflow & assertion lain (layar merah).
///
/// Dengan controller dikelola lewat State.dispose() di sini, Flutter
/// dijamin baru manggil dispose() setelah widget ini benar-benar lepas
/// dari tree (yaitu setelah animasi penutupan selesai), jadi gak akan
/// kepakai-setelah-dibuang lagi.
class _ReviewSheet extends StatefulWidget {
  final String venueId;
  final VoidCallback onSubmitted;

  const _ReviewSheet({required this.venueId, required this.onSubmitted});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _rating = 5;
  final _commentC = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _commentC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _sending = true);

    final err = await FirestoreService.addReview(
      widget.venueId,
      rating: _rating,
      comment: _commentC.text,
    );

    if (!mounted) return;

    Navigator.of(context).pop();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          err ?? 'Ulasan terkirim. Terima kasih!',
          style: const TextStyle(
              color: CustomColors.mabarTextPrimary,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            err == null ? CustomColors.mabarPurpleBg : Colors.red.shade800,
      ),
    );

    if (err == null) widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
            const Text('Beri Ulasan',
                style: TextStyle(
                    color: CustomColors.mabarTextPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return IconButton(
                  onPressed:
                      _sending ? null : () => setState(() => _rating = i + 1),
                  icon: Icon(
                    i < _rating
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
              controller: _commentC,
              enabled: !_sending,
              maxLines: 3,
              style: const TextStyle(color: CustomColors.mabarTextPrimary),
              decoration: InputDecoration(
                hintText: 'Tulis pengalamanmu (opsional)...',
                hintStyle:
                    const TextStyle(color: CustomColors.mabarTextTertiary),
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
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kirim Ulasan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}