import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';

class MabarTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final IconData iconData;
  final bool isPassword;
  final TextInputType keyboardType;

  const MabarTextField({
    super.key,
    this.controller,
    this.hintText,
    required this.iconData,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<MabarTextField> createState() => _MabarTextFieldState();
}

class _MabarTextFieldState extends State<MabarTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceInput,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomColors.mabarBorderSubtle, width: 1),
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword && _isObscured,
        style: const TextStyle(
          color: CustomColors.mabarTextPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: CustomColors.mabarTextTertiary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            widget.iconData,
            color: CustomColors.mabarPurple,
            size: 20,
          ),
          suffixIcon: widget.isPassword
              ? GestureDetector(
                  onTap: () => setState(() => _isObscured = !_isObscured),
                  child: Icon(
                    _isObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: CustomColors.mabarTextTertiary,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
