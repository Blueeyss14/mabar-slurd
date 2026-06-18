import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/image_card.dart';
import 'package:mabar_slurd/src/feat/detail/presentation/views/pages/detail_screen.dart';
import 'package:mabar_slurd/src/feat/common/presentation/components/map_gaming.dart';
import 'package:mabar_slurd/src/feat/common/presentation/components/search_gaming.dart';
import 'package:mabar_slurd/src/feat/common/presentation/controllers/location_controller.dart';
import 'package:mabar_slurd/src/feat/profile/presentation/views/pages/notification_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationController locationController = Get.put(LocationController());
  String _selectedSort = 'Semua';

  static const List<String> _sorts = ['Semua', 'Terdekat', 'Populer', 'Rating'];

  List<Map<String, dynamic>> _applySorting(List<Map<String, dynamic>> venues) {
    final list = [...venues];
    switch (_selectedSort) {
      case 'Terdekat':
        list.sort((a, b) => ((a['distance'] as num?) ?? 0)
            .compareTo((b['distance'] as num?) ?? 0));
        break;
      case 'Populer':
        list.sort((a, b) {
          final aPop = a['badge'] == 'Populer' ? 0 : 1;
          final bPop = b['badge'] == 'Populer' ? 0 : 1;
          return aPop.compareTo(bPop);
        });
        break;
      case 'Rating':
        list.sort((a, b) => ((b['rating'] as num?) ?? 0)
            .compareTo((a['rating'] as num?) ?? 0));
        break;
      default:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Lokasi kamu",
                          style: TextStyle(
                            fontSize: 12,
                            color: CustomColors.mabarTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(
                          () => Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: CustomColors.mabarPurpleLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                locationController.locationName.value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CustomColors.mabarTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CustomColors.mabarSurfaceCard,
                          border: Border.all(color: CustomColors.mabarBorderSubtle),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: CustomColors.mabarTextPrimary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SearchGaming(),
                const SizedBox(height: 24),
                const Text(
                  "Cari Wilayah",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const MapGaming(),
                const SizedBox(height: 24),
                const Text(
                  "Rekomendasi untuk kamu",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSortChips(),
                const SizedBox(height: 8),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirestoreService.getVenues(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Belum ada venue tersedia.',
                          style: TextStyle(color: CustomColors.mabarTextSecondary),
                        ),
                      );
                    }
                    final places = _applySorting(snapshot.data!);
                    return Column(
                      children: places.map((place) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: MabarImageCard(
                            name: place['name'] as String? ?? '-',
                            rating: (place['rating'] as num?)?.toDouble() ?? 0,
                            distance: (place['distance'] as num?)?.toDouble() ?? 0,
                            price: (place['price_per_hour'] as num?)?.toInt() ?? 0,
                            badge: place['badge'] as String?,
                            imageUrl: place['image_url'] as String?,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailScreen(venue: place),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _sorts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = _sorts[index];
          final bool isActive = _selectedSort == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedSort = cat),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: isActive
                    ? CustomColors.mabarBorderFocus
                    : CustomColors.mabarSurfaceCard,
                border: Border.all(
                  color: isActive
                      ? CustomColors.mabarBorderFocus
                      : CustomColors.mabarBorderSubtle,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? CustomColors.mabarTextPrimary
                      : CustomColors.mabarTextSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
