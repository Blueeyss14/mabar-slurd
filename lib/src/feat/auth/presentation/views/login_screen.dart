import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mabar_slurd/src/feat/auth/presentation/controllers/auth_controller.dart';
import 'package:mabar_slurd/src/res/assets.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/feat/auth/presentation/views/register_screen.dart';
import 'package:mabar_slurd/src/feat/auth/presentation/views/forgot_password_screen.dart';
import 'package:mabar_slurd/src/shared/components/mabar_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Image & Title Area
            Stack(
              alignment: Alignment.center,
              children: [
                // Top Banner Image with Gradient Overlay
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage(AssetImages.gaming),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient Overlay to blend with background
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        CustomColors.mabarBgDark.withValues(alpha: 0.1),
                        CustomColors.mabarBgDark,
                      ],
                    ),
                  ),
                ),
                // Titles
                Positioned(
                  bottom: 10,
                  child: Column(
                    children: [
                      const Text(
                        "MABARKEUN",
                        style: TextStyle(
                          color: CustomColors.mabarPurple,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Selamat datang kembali, Gamers!",
                        style: TextStyle(
                          color: CustomColors.mabarTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // EMAIL
                  Text(
                    "ALAMAT EMAIL",
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
                    hintText: "gaming@example.com",
                    iconData: Icons.mail_outline_rounded,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // PASSWORD
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "KATA SANDI",
                        style: TextStyle(
                          color: CustomColors.mabarTextSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "LUPA?",
                          style: TextStyle(
                            color: CustomColors.mabarPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MabarTextField(
                    controller: passwordController,
                    hintText: "••••••••",
                    iconData: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),

                  const SizedBox(height: 40),

                  // LOGIN BUTTON
                  Obx(() => authController.isLoading.value
                      ? const Center(child: CircularProgressIndicator(color: CustomColors.mabarPurpleLight))
                      : Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: CustomColors.mabarPurpleLight,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: CustomColors.mabarPurple.withValues(alpha: 0.4),
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
                              authController.loginUser(
                                emailController.text,
                                passwordController.text,
                              );
                            },
                            child: const Text(
                              "MASUK SEKARANG",
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
                  
                  // DIVIDER "ATAU LOGIN DENGAN"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: CustomColors.mabarBorderSubtle,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "ATAU MASUK DENGAN",
                          style: TextStyle(
                            color: CustomColors.mabarTextTertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: CustomColors.mabarBorderSubtle,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // SOCIAL LOGIN BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          icon: Icons.g_mobiledata_rounded, // or google image if available
                          title: "Google",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSocialButton(
                          icon: Icons.facebook_rounded,
                          title: "Facebook",
                          iconColor: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // REGISTER TEXT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Belum punya akun? ",
                        style: TextStyle(
                          color: CustomColors.mabarTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "DAFTAR DISINI",
                          style: TextStyle(
                            color: CustomColors.mabarPurpleLight,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String title,
    Color? iconColor,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomColors.mabarBorderSubtle,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor ?? Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
