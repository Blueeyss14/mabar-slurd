import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/assets.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';

class MabarImageCard extends StatelessWidget {
  final String name;
  final double rating;
  final double distance;
  final int price;
  final String? badge;
  final void Function()? onTap;

  const MabarImageCard({
    super.key,
    this.name = "GG Arena",
    this.rating = 4.8,
    this.distance = 0.8,
    this.price = 15,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        width: double.infinity,
        decoration: BoxDecoration(
          color: CustomColors.mabarSurfaceCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: CustomColors.mabarBorderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Image.asset(AssetImages.gaming, fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          CustomColors.mabarSurfaceCard.withValues(alpha: 0.6),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: CustomColors.mabarBgDark.withValues(alpha: 0.7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: CustomColors.mabarStar,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$rating",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.mabarTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: CustomColors.mabarBorderFocus,
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: CustomColors.mabarTextPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: CustomColors.mabarTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: CustomColors.mabarTextSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "$distance km",
                        style: const TextStyle(
                          fontSize: 14,
                          color: CustomColors.mabarTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: CustomColors.mabarGreenBg,
                        ),
                        child: const Text(
                          "Buka",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.mabarGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFacility(Icons.computer, "PC"),
                      const SizedBox(width: 8),
                      _buildFacility(Icons.ac_unit, "AC"),
                      const SizedBox(width: 8),
                      _buildFacility(Icons.wifi, "WiFi"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                    height: 1,
                    color: CustomColors.mabarBorderSubtle,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Rp $price.000",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: CustomColors.mabarPurpleLight,
                        ),
                      ),
                      const Text(
                        " /jam",
                        style: TextStyle(
                          fontSize: 13,
                          color: CustomColors.mabarTextSecondary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: CustomColors.mabarBorderFocus,
                        ),
                        child: const Text(
                          "Booking",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.mabarTextPrimary,
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
      ),
    );
  }

  Widget _buildFacility(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CustomColors.mabarSurfaceInput,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: CustomColors.mabarTextSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CustomColors.mabarTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
