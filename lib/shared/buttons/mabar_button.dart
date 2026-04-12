import 'package:flutter/material.dart';
import 'package:mabar_slurd/res/custom_colors.dart';

class MabarButton extends StatelessWidget {
  final double? fontSize;
  final String? text;
  final void Function()? onTap;
  const MabarButton({super.key, this.fontSize, this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: CustomColors.mabarBorderFocus,
        ),
        child: Text(
          text ?? "Mabar",
          style: TextStyle(
            fontSize: fontSize ?? 20,
            color: CustomColors.mabarTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
