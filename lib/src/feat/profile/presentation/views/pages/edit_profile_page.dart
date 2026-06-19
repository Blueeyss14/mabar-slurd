import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mabar_slurd/src/core/firestore_service.dart';
import 'package:mabar_slurd/src/core/storage_service.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';
import 'package:mabar_slurd/src/shared/components/mabar_text_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _uploadingPhoto = false;
  String? _photoUrl;
  String _initialEmail = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    _usernameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
    _initialEmail = user?.email ?? '';
    _photoUrl = user?.photoURL;
    final profile = await FirestoreService.getUserProfile();
    if (mounted) {
      setState(() {
        _phoneController.text = profile['phone'] as String? ?? '';
        _photoUrl ??= profile['photo_url'] as String?;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    final url = await StorageService.uploadProfilePhoto(picked.path);
    if (!mounted) return;
    setState(() {
      _uploadingPhoto = false;
      if (url != null) _photoUrl = url;
    });
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal upload foto. Pastikan Storage aktif.')),
      );
    }
  }

  Future<void> _simpan() async {
    FocusScope.of(context).unfocus();
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama pengguna tidak boleh kosong.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);

    final ok = await FirestoreService.updateUserProfile(
      displayName: _usernameController.text,
      phone: _phoneController.text,
      photoUrl: _photoUrl,
    );

    // Email berubah? proses terpisah (kirim verifikasi).
    final newEmail = _emailController.text.trim();
    String? emailMsg;
    if (ok && newEmail.isNotEmpty && newEmail != _initialEmail) {
      final code = await FirestoreService.updateEmail(newEmail);
      switch (code) {
        case 'verify-sent':
          emailMsg = 'Cek email baru untuk verifikasi sebelum email berubah.';
          break;
        case 'requires-recent-login':
          emailMsg = 'Untuk ganti email, logout lalu login lagi dulu ya.';
          break;
        case 'email-already-in-use':
          emailMsg = 'Email itu sudah dipakai akun lain.';
          break;
        case 'invalid-email':
          emailMsg = 'Format email baru tidak valid.';
          break;
        default:
          emailMsg = 'Gagal mengubah email.';
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Profil berhasil diperbarui.${emailMsg != null ? ' $emailMsg' : ''}'
              : 'Gagal memperbarui profil',
          style: const TextStyle(
            color: CustomColors.mabarTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            ok ? CustomColors.mabarPurpleBg : Colors.red.shade800,
      ),
    );
    if (ok && emailMsg == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.mabarBgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Edit Profil",
          style: TextStyle(
            color: CustomColors.mabarTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            Center(
              child: GestureDetector(
                onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CustomColors.mabarBorderFocus,
                        image: (_photoUrl != null && _photoUrl!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(_photoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (_photoUrl != null && _photoUrl!.isNotEmpty)
                          ? null
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: CustomColors.mabarTextPrimary,
                            ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CustomColors.mabarPurpleLight,
                          border: Border.all(
                            color: CustomColors.mabarBgDark,
                            width: 2,
                          ),
                        ),
                        child: _uploadingPhoto
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildLabel("NAMA PENGGUNA"),
            MabarTextField(
              controller: _usernameController,
              iconData: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 20),
            _buildLabel("ALAMAT EMAIL"),
            MabarTextField(
              controller: _emailController,
              iconData: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _buildLabel("NOMOR TELEPON"),
            MabarTextField(
              controller: _phoneController,
              iconData: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.mabarPurpleLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isLoading ? null : _simpan,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "SIMPAN PERUBAHAN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: CustomColors.mabarTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
