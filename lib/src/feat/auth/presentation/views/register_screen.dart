import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mabar_slurd/src/feat/auth/presentation/controllers/auth_controller.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/mabar_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isAgreed = false;
  late final AuthController authController;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController());
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
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
            const Text(
              "Bergabung dengan komunitas gamers!",
              style: TextStyle(
                color: CustomColors.mabarTextSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),

            // USERNAME
            const Text(
              "NAMA PENGGUNA",
              style: TextStyle(
                color: CustomColors.mabarTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            MabarTextField(
              controller: usernameController,
              hintText: "pro_gamer_99",
              iconData: Icons.person_outline_rounded,
            ),

            const SizedBox(height: 20),

            // EMAIL
            const Text(
              "EMAIL",
              style: TextStyle(
                color: CustomColors.mabarTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            MabarTextField(
              controller: emailController,
              hintText: "name@email.com",
              iconData: Icons.mail_outline_rounded,
            ),

            const SizedBox(height: 20),

            // PASSWORD
            const Text(
              "KATA SANDI",
              style: TextStyle(
                color: CustomColors.mabarTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            MabarTextField(
              controller: passwordController,
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
                    side: const BorderSide(
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
                    text: const TextSpan(
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
                        TextSpan(text: "serta "),
                        TextSpan(
                          text: "Kebijakan Privasi ",
                          style: TextStyle(
                            color: CustomColors.mabarPurpleLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: "MabarKeun."),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // REGISTER BUTTON
            Obx(
              () => authController.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: CustomColors.mabarPurpleLight,
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: CustomColors.mabarPurpleLight,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: CustomColors.mabarPurple.withValues(
                              alpha: 0.4,
                            ),
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
                          authController.registerUser(
                            emailController.text,
                            passwordController.text,
                            username: usernameController.text,
                          );
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
            ),

            const SizedBox(height: 40),

            // LOGIN TEXT
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Sudah punya akun? ",
                  style: TextStyle(
                    color: CustomColors.mabarTextSecondary,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "MASUK KEMBALI",
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
}
