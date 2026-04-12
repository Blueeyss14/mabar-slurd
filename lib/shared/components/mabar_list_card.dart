import 'package:flutter/material.dart';
import 'package:mabar_slurd/res/custom_colors.dart';

class MabarListCard extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? date;
  final String? time;
  final int? total;

  const MabarListCard({
    super.key,
    this.title,
    this.subTitle,
    this.date,
    this.time,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: CustomColors.mabarSurfaceCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title ?? 'Title',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.mabarTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: CustomColors.mabarBorderSubtle,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check, color: Colors.cyan, size: 18),
                    SizedBox(width: 5),
                    Text(
                      'Selesai',
                      style: TextStyle(
                        fontSize: 16,
                        color: CustomColors.mabarCyan,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            subTitle ?? 'Sub Title',
            style: const TextStyle(
              fontSize: 20,
              color: CustomColors.mabarTextSecondary,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: CustomColors.mabarTextSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                date ?? 'Date',
                style: const TextStyle(
                  fontSize: 20,
                  color: CustomColors.mabarTextSecondary,
                ),
              ),
              const SizedBox(width: 15),
              const Icon(
                Icons.lock_clock,
                color: CustomColors.mabarTextSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                time ?? 'Time',
                style: const TextStyle(
                  fontSize: 20,
                  color: CustomColors.mabarTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color.fromARGB(113, 94, 93, 112)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.mabarTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${total ?? 'Total'}K IDR',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.mabarCyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
