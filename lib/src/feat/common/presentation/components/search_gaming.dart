import 'package:flutter/material.dart';
import 'package:mabar_slurd/res/assets.dart';
import 'package:mabar_slurd/res/custom_colors.dart';

class SearchGaming extends StatelessWidget {
  const SearchGaming({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: CustomColors.mabarTextSecondary.withAlpha(30),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Image.asset(
            AssetIcons.search,
            width: 25,
            color: CustomColors.mabarTextSecondary,
          ),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
                hintStyle: TextStyle(color: CustomColors.mabarTextPrimary),
                hintText: "Cari Temen Mabar",
              ),
              style: TextStyle(
                color: CustomColors.mabarTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
