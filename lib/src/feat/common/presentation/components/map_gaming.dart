import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/feat/common/presentation/controllers/location_controller.dart';
import 'package:mabar_slurd/src/feat/detail/presentation/views/pages/detail_screen.dart';

class MapGaming extends StatelessWidget {
  const MapGaming({super.key});

  @override
  Widget build(BuildContext context) {
    final LocationController locationController =
        Get.find<LocationController>();

    return Container(
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: CustomColors.mabarBorderSubtle),
      ),
      child: Obx(() {
        if (locationController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: CustomColors.mabarPurpleLight,
            ),
          );
        }

        if (locationController.currentLocation.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_outlined,
                  color: CustomColors.mabarTextTertiary,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  "Lokasi tidak ditemukan.\nAktifkan GPS kamu.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CustomColors.mabarTextSecondary),
                ),
              ],
            ),
          );
        }

        final initialCenter = locationController.currentLocation.value!;

        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 13.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom |
                      InteractiveFlag.flingAnimation,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.mabar_slurd',
                ),
                Obx(
                  () => MarkerLayer(
                    markers: [
                      for (final place in locationController.nearbyPlaces)
                        Marker(
                          point: place['location'],
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showPlaceDetail(context, place),
                            child: _buildPlaceMarker(),
                          ),
                        ),
                      if (locationController.selectedLocation.value != null)
                        Marker(
                          point: locationController.selectedLocation.value!,
                          width: 44,
                          height: 44,
                          child: _buildMarker(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 12,
              top: 12,
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColors.mabarBgDark.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: CustomColors.mabarPurpleLight,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        locationController.locationName.value,
                        style: const TextStyle(
                          color: CustomColors.mabarTextPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showPlaceDetail(BuildContext context, Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: CustomColors.mabarPurpleBg,
                    ),
                    child: const Icon(
                      Icons.sports_esports,
                      color: CustomColors.mabarPurpleLight,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place['name'] ?? 'Warnet',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.mabarTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: CustomColors.mabarStar,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "4.7 · Buka sekarang",
                              style: TextStyle(
                                fontSize: 13,
                                color: CustomColors.mabarTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(venue: place),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: CustomColors.mabarBorderFocus,
                        ),
                        child: const Text(
                          "Lihat Detail",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.mabarTextPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarker() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CustomColors.mabarBorderFocus,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: CustomColors.mabarPurple.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.sports_esports,
        color: Colors.white,
        size: 22,
      ),
    );
  }

  Widget _buildPlaceMarker() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CustomColors.mabarCyan,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: CustomColors.mabarCyan.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(
        Icons.store_mall_directory,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
