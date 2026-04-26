import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mabar_slurd/res/assets.dart';
import 'package:mabar_slurd/res/custom_colors.dart';
import 'package:mabar_slurd/shared/components/image_card.dart';
import 'package:mabar_slurd/src/feat/Detail/presentation/views/pages/detail_screen.dart';
import 'package:mabar_slurd/src/feat/common/presentation/components/map_gaming.dart';
import 'package:mabar_slurd/src/feat/common/presentation/components/search_gaming.dart';
import 'package:mabar_slurd/src/feat/common/presentation/controllers/location_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.put(LocationController());

    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Row(
                  children: [
                    Image.asset(
                      AssetIcons.location,
                      width: 30,
                      color: CustomColors.mabarTextPrimary,
                    ),
                    Text(
                      locationController.locationName.value,
                      style: const TextStyle(color: CustomColors.mabarTextPrimary),
                    ),
                  ],
                )),
                const SizedBox(height: 15),
                const SearchGaming(),
                const SizedBox(height: 20),
                const Text(
                  "Cari Wilayah",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const MapGaming(),
                const SizedBox(height: 15),
                ...List.generate(
                  10,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DetailScreen(),
                          ),
                        );
                      },
                      child: const ImageCard(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
