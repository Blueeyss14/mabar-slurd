import 'package:flutter/material.dart';
import 'package:mabar_slurd/res/custom_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordVisible = false;
  bool _isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark, // or mabarSurfaceCard
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "DAFTAR AKUN",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Bergabung dengan komunitas gamers!",
              style: TextStyle(
                color: CustomColors.mabarTextSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),

            // USERNAME
            Text(
              "USERNAME",
              style: TextStyle(
                color: CustomColors.mabarTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              hintText: "pro_gamer_99",
              iconData: Icons.person_outline_rounded,
            ),
            
            const SizedBox(height: 20),

            // EMAIL
            Text(
              "EMAIL",
              style: TextStyle(
                color: CustomColors.mabarTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              hintText: "name@email.com",
              iconData: Icons.mail_outline_rounded,
            ),

            const SizedBox(height: 20),

            // PASSWORD
            Text(
              "PASSWORD",
              style: TextStyle(
                color: CustomColors.mabarTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              hintText: "••••••••",
              iconData: Icons.lock_outline_rounded,
              isPassword: true,
            ),

            const SizedBox(height: 24),

            // CHECKBOX T&C
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _isAgreed,
                    onChanged: (value) {
                      setState(() {
                        _isAgreed = value ?? false;
                      });
                    },
                    activeColor: CustomColors.mabarPurple,
                    side: BorderSide(
                      color: CustomColors.mabarBorderSubtle,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: "Saya setuju dengan ",
                      style: TextStyle(
                        color: CustomColors.mabarTextSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: "Syarat & Ketentuan ",
                          style: TextStyle(
                            color: CustomColors.mabarPurpleLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: "serta "),
                        TextSpan(
                          text: "Kebijakan Privasi ",
                          style: TextStyle(
                            color: CustomColors.mabarPurpleLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: "MabarKeun."),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // REGISTER BUTTON
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: CustomColors.mabarPurpleLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: CustomColors.mabarPurple.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  // Back to Login or Auto Login
                  Navigator.pop(context);
                },
                child: const Text(
                  "BUAT AKUN SEKARANG",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // LOGIN TEXT
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sudah punya akun? ",
                  style: TextStyle(
                    color: CustomColors.mabarTextSecondary,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "LOGIN KEMBALI",
                    style: TextStyle(
                      color: CustomColors.mabarPurpleLight,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData iconData,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.mabarSurfaceInput,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CustomColors.mabarBorderSubtle,
          width: 1,
        ),
      ),
      child: TextField(
        obscureText: isPassword && !_isPasswordVisible,
        style: const TextStyle(
          color: CustomColors.mabarTextPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: CustomColors.mabarTextTertiary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            iconData,
            color: CustomColors.mabarPurple,
            size: 20,
          ),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  child: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
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
