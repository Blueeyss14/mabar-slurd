import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:mabar_slurd/res/assets.dart';
import 'package:mabar_slurd/res/custom_colors.dart';
import 'package:mabar_slurd/src/feat/common/presentation/controllers/location_controller.dart';

class MapGaming extends StatelessWidget {
  const MapGaming({super.key});

  @override
  Widget build(BuildContext context) {
    final LocationController locationController =
        Get.find<LocationController>();

    return Container(
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: CustomColors.mabarCyanMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Obx(() {
        if (locationController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (locationController.selectedLocation.value == null) {
          return const Center(
            child: Text(
              "Lokasi tidak ditemukan. Aktifkan GPS Anda.",
              style: TextStyle(color: CustomColors.mabarTextPrimary),
            ),
          );
        }

        final initialCenter = locationController.selectedLocation.value!;

        return FlutterMap(
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 13.0,
            onTap: (tapPosition, point) {
              locationController.onMapTap(point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.mabar_slurd',
            ),
            if (locationController.selectedLocation.value != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: locationController.selectedLocation.value!,
                    width: 40,
                    height: 40,
                    child: Image.asset(AssetIcons.location, color: Colors.red),
                  ),
                ],
              ),
          ],
        );
      }),
    );
  }
}
