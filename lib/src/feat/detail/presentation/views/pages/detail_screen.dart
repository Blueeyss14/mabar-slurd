import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/assets.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/buttons/mabar_button.dart';
import 'package:mabar_slurd/src/feat/detail/presentation/widgets/detail_page_widgets.dart';
import 'package:mabar_slurd/src/feat/booking/presentation/views/pages/booking_page.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> venue;

  const DetailScreen({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final name = venue['name'] as String? ?? '-';
    final rating = (venue['rating'] as num?)?.toDouble() ?? 0.0;
    final distance = (venue['distance'] as num?)?.toDouble() ?? 0.0;
    final pricePerHour = (venue['price_per_hour'] as num?)?.toInt() ?? 0;
    final totalSlots = (venue['total_slots'] as num?)?.toInt() ?? 0;
    final badge = venue['badge'] as String?;

    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Image.asset(AssetImages.gaming, fit: BoxFit.cover),
                ),
                // gradient atas gelap untuk back button
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // gradient bawah supaya tidak nyatu dengan konten
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          CustomColors.mabarBgDark,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                if (badge != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        margin: const EdgeInsets.only(top: 8, right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: CustomColors.mabarBorderFocus,
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: CustomColors.mabarTextPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                SafeArea(
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: CustomColors.mabarTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Image.asset(
                        AssetIcons.rating,
                        width: 15,
                        color: CustomColors.mabarCyan,
                      ),
                      Text(
                        "  $rating - $distance km",
                        style: const TextStyle(
                          fontSize: 16,
                          color: CustomColors.mabarTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${pricePerHour}k/jam",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: CustomColors.mabarPurpleDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Fasilitas",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: CustomColors.mabarTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.start,
                    children: List.generate(
                      detailPagesWidgets.length,
                      (index) => FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: CustomColors.mabarSurfaceCard,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                detailPagesWidgets[index]['icon'],
                                width: 30,
                              ),
                              const SizedBox(width: 10),
                              AutoSizeText(
                                detailPagesWidgets[index]['label'],
                                minFontSize: 6,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: CustomColors.mabarTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Harga",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: CustomColors.mabarTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: CustomColors.mabarSurfaceCard,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "${pricePerHour}k",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: CustomColors.mabarPurpleDark,
                          ),
                        ),
                        const Text(
                          '/Jam',
                          style: TextStyle(
                            fontSize: 20,
                            color: CustomColors.mabarTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Ketersediaan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: CustomColors.mabarTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: CustomColors.mabarSurfaceCard,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Slot',
                          style: TextStyle(
                            fontSize: 20,
                            color: CustomColors.mabarTextSecondary,
                          ),
                        ),
                        Text(
                          "$totalSlots Slot",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: CustomColors.mabarCyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  MabarButton(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingPage(venue: venue),
                      ),
                    ),
                    text: "Booking Sekarang",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
