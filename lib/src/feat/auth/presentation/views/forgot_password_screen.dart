import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mabar_slurd/src/feat/auth/presentation/controllers/auth_controller.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/mabar_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _kirimTautan() async {
    FocusScope.of(context).unfocus();
    final sukses = await authController.resetPassword(_emailController.text);
    if (sukses && mounted) Navigator.pop(context);
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
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: CustomColors.mabarPurpleBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: CustomColors.mabarPurpleLight,
                size: 38,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "LUPA KATA SANDI",
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
              "Masukkan email kamu, nanti kami kirimkan tautan untuk atur ulang kata sandi.",
              style: TextStyle(
                color: CustomColors.mabarTextSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
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
              controller: _emailController,
              hintText: "gaming@example.com",
              iconData: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 40),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.mabarPurpleLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: authController.isLoading.value ? null : _kirimTautan,
                  child: authController.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "KIRIM TAUTAN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "Kembali ke Masuk",
                  style: TextStyle(
                    color: CustomColors.mabarPurpleLight,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
