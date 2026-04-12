import 'package:flutter/material.dart';
import 'package:mabar_slurd/res/assets.dart';
import 'package:mabar_slurd/res/custom_colors.dart';

class ImageCard extends StatelessWidget {
  final double? size;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final void Function()? onTap;
  final BoxBorder? border;
  const ImageCard({
    super.key,
    this.size,
    this.margin,
    this.color,
    this.padding,
    this.child,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: MediaQuery.of(context).size.width,
      height: 250,
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Flexible(
                child: SizedBox(
                  width: double.infinity,
                  child: Image.asset(AssetImages.gaming, fit: BoxFit.cover),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                width: double.infinity,
                child: Column(
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
                    const SizedBox(height: 5),

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
                    const SizedBox(height: 5),

                    const Text(
                      "15k/jam",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: CustomColors.mabarPurpleDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.all(5),
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
    );
  }
}
