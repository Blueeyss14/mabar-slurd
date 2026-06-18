import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/image_card.dart';
import 'package:mabar_slurd/src/feat/detail/presentation/views/pages/detail_screen.dart';
import 'package:mabar_slurd/src/feat/common/presentation/components/map_gaming.dart';
import 'package:mabar_slurd/src/feat/common/presentation/components/search_gaming.dart';
import 'package:mabar_slurd/src/feat/common/presentation/components/filter_sheet.dart';
import 'package:mabar_slurd/src/feat/common/presentation/controllers/location_controller.dart';
import 'package:mabar_slurd/src/feat/profile/presentation/views/pages/notification_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationController locationController = Get.put(LocationController());
  String _sortBy = 'Semua';
  String _query = '';
  double _maxPrice = 100; // Rp 100.000 = praktis tanpa batas

  static const List<String> _sorts = ['Semua', 'Terdekat', 'Populer', 'Rating'];

  bool get _filterActive => _sortBy != 'Semua' || _maxPrice < 100;

  /// Sisipkan jarak (km) tiap venue dihitung dari lokasi user (bila ada GPS).
  List<Map<String, dynamic>> _withDistance(List<Map<String, dynamic>> venues) {
    final center = locationController.currentLocation.value;
    if (center == null) return venues;
    return venues.map((v) {
      final lat = (v['lat'] as num?)?.toDouble();
      final lng = (v['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return v;
      final km = Geolocator.distanceBetween(
              center.latitude, center.longitude, lat, lng) /
          1000;
      return {...v, 'distance': double.parse(km.toStringAsFixed(1))};
    }).toList();
  }

  /// Terapkan pencarian nama, batas harga, dan urutan.
  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> venues) {
    final q = _query.trim().toLowerCase();
    var list = venues.where((v) {
      final name = (v['name'] as String? ?? '').toLowerCase();
      final price = (v['price_per_hour'] as num?)?.toInt() ?? 0;
      final cocokNama = q.isEmpty || name.contains(q);
      final cocokHarga = price <= _maxPrice;
      return cocokNama && cocokHarga;
    }).toList();

    switch (_sortBy) {
      case 'Terdekat':
        list.sort((a, b) => ((a['distance'] as num?) ?? 9999)
            .compareTo((b['distance'] as num?) ?? 9999));
        break;
      case 'Termurah':
        list.sort((a, b) => ((a['price_per_hour'] as num?) ?? 0)
            .compareTo((b['price_per_hour'] as num?) ?? 0));
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

  Future<void> _openFilter() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        initialSort: _sortBy,
        initialMaxPrice: _maxPrice,
      ),
    );
    if (result != null) {
      setState(() {
        _sortBy = result['sort'] as String? ?? _sortBy;
        _maxPrice = (result['maxPrice'] as num?)?.toDouble() ?? _maxPrice;
      });
    }
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
                SearchGaming(
                  filterActive: _filterActive,
                  onChanged: (v) => setState(() => _query = v),
                  onFilterTap: _openFilter,
                ),
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
                    return Obx(() {
                      // baca lokasi user agar jarak ikut update saat GPS siap
                      locationController.currentLocation.value;
                      final places =
                          _applyFilters(_withDistance(snapshot.data!));
                      if (places.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(
                            child: Text(
                              'Tidak ada warnet yang cocok.',
                              style: TextStyle(
                                  color: CustomColors.mabarTextSecondary),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: places.map((place) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: MabarImageCard(
                              name: place['name'] as String? ?? '-',
                              rating:
                                  (place['rating'] as num?)?.toDouble() ?? 0,
                              distance:
                                  (place['distance'] as num?)?.toDouble() ?? 0,
                              price:
                                  (place['price_per_hour'] as num?)?.toInt() ??
                                      0,
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
                    });
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
          final bool isActive = _sortBy == cat;
          return GestureDetector(
            onTap: () => setState(() => _sortBy = cat),
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
