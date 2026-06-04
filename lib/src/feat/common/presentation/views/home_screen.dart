import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/image_card.dart';
import 'package:mabar_slurd/src/feat/detail/presentation/views/pages/detail_screen.dart';
import 'package:mabar_slurd/src/feat/common/presentation/components/map_gaming.dart';
import 'package:mabar_slurd/src/feat/common/presentation/components/search_gaming.dart';
import 'package:mabar_slurd/src/feat/common/presentation/controllers/location_controller.dart';
import 'package:mabar_slurd/src/feat/common/presentation/widgets/gaming_place_data.dart';
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

  List<Map<String, dynamic>> get _sortedPlaces {
    final list = [...gamingPlaceData];
    switch (_selectedSort) {
      case 'Terdekat':
        list.sort((a, b) =>
            (a['distance'] as double).compareTo(b['distance'] as double));
        break;
      case 'Populer':
        list.sort((a, b) {
          final aPop = a['badge'] == 'Populer' ? 0 : 1;
          final bPop = b['badge'] == 'Populer' ? 0 : 1;
          return aPop.compareTo(bPop);
        });
        break;
      case 'Rating':
        list.sort((a, b) =>
            (b['rating'] as double).compareTo(a['rating'] as double));
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
                ...List.generate(
                  _sortedPlaces.length,
                  (index) {
                    final place = _sortedPlaces[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: MabarImageCard(
                        name: place['name'],
                        rating: place['rating'],
                        distance: place['distance'],
                        price: place['price'],
                        badge: place['badge'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DetailScreen(),
                            ),
                          );
                        },
                      ),
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
