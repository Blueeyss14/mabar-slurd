import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/feat/common/presentation/components/filter_sheet.dart';

class SearchGaming extends StatelessWidget {
  const SearchGaming({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: CustomColors.mabarSurfaceInput,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CustomColors.mabarBorderSubtle),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: CustomColors.mabarTextSecondary,
                  size: 22,
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                      hintStyle: TextStyle(
                        color: CustomColors.mabarTextTertiary,
                        fontSize: 14,
                      ),
                      hintText: "Cari tempat gaming",
                    ),
                    style: TextStyle(
                      color: CustomColors.mabarTextPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const FilterSheet(),
            );
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: CustomColors.mabarBorderFocus,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: CustomColors.mabarTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
