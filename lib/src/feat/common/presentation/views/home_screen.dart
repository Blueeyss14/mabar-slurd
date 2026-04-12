import 'package:flutter/material.dart';
import 'package:mabar_slurd/res/assets.dart';
import 'package:mabar_slurd/res/custom_colors.dart';
import 'package:mabar_slurd/shared/components/image_card.dart';
import 'package:mabar_slurd/src/feat/Detail/presentation/views/pages/detail_screen.dart';
import 'package:mabar_slurd/src/feat/common/presentation/components/map_gaming.dart';
import 'package:mabar_slurd/src/feat/common/presentation/components/search_gaming.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      AssetIcons.location,
                      width: 30,
                      color: CustomColors.mabarTextPrimary,
                    ),
                    const Text(
                      "Bandung",
                      style: TextStyle(color: CustomColors.mabarTextPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const SearchGaming(),
                const SizedBox(height: 15),
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
