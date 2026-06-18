import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';

class SearchGaming extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool filterActive;

  const SearchGaming({
    super.key,
    this.onChanged,
    this.onFilterTap,
    this.filterActive = false,
  });

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
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: CustomColors.mabarTextSecondary,
                  size: 22,
                ),
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                      hintStyle: TextStyle(
                        color: CustomColors.mabarTextTertiary,
                        fontSize: 14,
                      ),
                      hintText: "Cari tempat gaming",
                    ),
                    style: const TextStyle(
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
          onTap: onFilterTap,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: CustomColors.mabarBorderFocus,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.tune_rounded,
                    color: CustomColors.mabarTextPrimary,
                  ),
                ),
                if (filterActive)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: CustomColors.mabarCyan,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: CustomColors.mabarBorderFocus, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
