import 'package:flutter/material.dart';
import 'package:mabar_slurd/res/assets.dart';
import 'package:mabar_slurd/res/custom_colors.dart';

class MapGaming extends StatelessWidget {
  const MapGaming({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: CustomColors.mabarCyanMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Image.asset(AssetImages.map, fit: BoxFit.cover),
    );
  }
}

//  Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   AssetIcons.location,
//                   width: 40,
//                   color: CustomColors.mabarTextPrimary,
//                 ),
//                 const SizedBox(height: 5),
//                 const Text(
//                   "Peta Lokasi Terdekat",
//                   style: TextStyle(color: CustomColors.mabarTextPrimary),
//                 ),
//               ],
//             ),
//           ),
