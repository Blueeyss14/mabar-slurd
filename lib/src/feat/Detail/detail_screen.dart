import 'package:flutter/material.dart';
import 'package:mabar_slurd/res/assets.dart';
import 'package:mabar_slurd/res/custom_colors.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: Column(
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
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: CustomColors.mabarBorderFocus,
                  ),
                  child: const Text(
                    "Populer",
                    style: TextStyle(
                      color: CustomColors.mabarTextPrimary,
                      fontSize: 16,
                    ),
                  ),
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
                const Text(
                  "GG Arena",
                  style: TextStyle(
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
                    const Text(
                      "  4.8 - 0.8 km",
                      style: TextStyle(
                        fontSize: 16,
                        color: CustomColors.mabarTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "15k/jam",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: CustomColors.mabarPurpleDark,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Image.asset(
                      AssetIcons.location,
                      width: 20,
                      color: CustomColors.mabarTextSecondary,
                    ),
                    const Flexible(
                      child: Text(
                        " jl. Sigma Mewing No. 67, Bandung",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: CustomColors.mabarTextSecondary,
                        ),
                      ),
                    ),
                  ],
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
                // ...List.generate(
                //   2,
                //   (index) => Wrap(
                //     direction: Axis.horizontal,
                //     children: [
                //       Container(
                //         width: double.infinity,
                //         height: 30,
                //         color: Colors.amberAccent,
                //       ),
                //     ],
                //   ),
                // ),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: CustomColors.mabarSurfaceCard,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(AssetIcons.pc, width: 30),
                            const SizedBox(width: 10),
                            const Text(
                              "PC Gaming",
                              style: TextStyle(
                                fontSize: 20,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: CustomColors.mabarSurfaceCard,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(AssetIcons.pc, width: 30),
                            const SizedBox(width: 10),
                            const Text(
                              "PC Gaming",
                              style: TextStyle(
                                fontSize: 20,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: CustomColors.mabarSurfaceCard,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(AssetIcons.pc, width: 30),
                            const SizedBox(width: 10),
                            const Text(
                              "PC Gaming",
                              style: TextStyle(
                                fontSize: 20,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: CustomColors.mabarSurfaceCard,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(AssetIcons.ac, width: 30),
                            const SizedBox(width: 10),
                            const Text(
                              "AC",
                              style: TextStyle(
                                fontSize: 20,
                                color: CustomColors.mabarTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
