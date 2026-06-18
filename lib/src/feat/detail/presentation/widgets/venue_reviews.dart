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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await FirestoreService.getVenueReviews(widget.venueId);
    if (!mounted) return;
    setState(() {
      _reviews = list;
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
                    i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
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

    int rating = 5;
    final commentC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) => Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
                        onPressed: () => setSheet(() => rating = i + 1),
                        icon: Icon(
                          i < rating
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
                    controller: commentC,
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
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await FirestoreService.addReview(
                          widget.venueId,
                          rating: rating,
                          comment: commentC.text,
                        );
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              ok ? 'Ulasan terkirim. Terima kasih!' : 'Gagal mengirim ulasan.',
                              style: const TextStyle(
                                  color: CustomColors.mabarTextPrimary,
                                  fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: ok
                                ? CustomColors.mabarPurpleBg
                                : Colors.red.shade800,
                          ),
                        );
                        if (ok) _load();
                      },
                      child: const Text('Kirim Ulasan',
                          style: TextStyle(
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
}
