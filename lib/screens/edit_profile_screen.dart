import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;
  late TextEditingController _addressController;

  String? _selectedGender;
  DateTime? _selectedDate;
  String? _newPhotoBase64;
  bool _isSaving = false;

  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: auth.userName);
    _emailController = TextEditingController(text: auth.userEmail);
    _phoneController = TextEditingController(text: auth.userPhone);
    _birthDateController = TextEditingController(text: auth.userBirthDate);
    _addressController = TextEditingController(text: auth.userAddress);
    _selectedGender = auth.userGender.isNotEmpty ? auth.userGender : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Pilih foto dari galeri
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 75,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _newPhotoBase64 = base64String;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih foto: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Pilih Tanggal Lahir
  Future<void> _pickBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.darkGreen,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    await auth.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _selectedGender,
      birthDate: _birthDateController.text.trim(),
      address: _addressController.text.trim(),
      photoBase64: _newPhotoBase64,
      // Email TIDAK diupdate (permanen)
    );

    setState(() => _isSaving = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui! 🎉'),
        backgroundColor: AppTheme.darkGreen,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final String currentPhoto = _newPhotoBase64 ?? auth.userPhotoBase64;

    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ============ FOTO PROFIL ============
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightGreen,
                    border: Border.all(color: AppTheme.darkGreen, width: 3),
                    image: currentPhoto.isNotEmpty
                        ? DecorationImage(
                            image: MemoryImage(base64Decode(currentPhoto)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: currentPhoto.isEmpty
                      ? const Icon(Icons.person, size: 70, color: AppTheme.darkGreen)
                      : null,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppTheme.darkGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _pickImage,
              child: const Text(
                'Ubah Foto Profil',
                style: TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // ============ NAMA LENGKAP ============
            _buildLabel('Nama Lengkap'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Masukkan nama kamu', Icons.person_outline),
            ),
            const SizedBox(height: 20),

            // ============ EMAIL (READ-ONLY) ============
            _buildLabel('Email'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              readOnly: true, // ← Kunci! Gak bisa diedit
              enabled: false,
              decoration: _inputDecoration('Email tidak bisa diubah', Icons.email_outlined).copyWith(
                fillColor: Colors.grey.shade200,
                suffixIcon: const Icon(Icons.lock, color: AppTheme.textGrey, size: 18),
                helperStyle: const TextStyle(fontSize: 11, color: AppTheme.textGrey),
              ),
            ),
            const SizedBox(height: 20),

            // ============ NOMOR TELEPON ============
            _buildLabel('Nomor Telepon'),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Contoh: 081234567890', Icons.phone_outlined),
            ),
            const SizedBox(height: 20),

            // ============ GENDER (DROPDOWN) ============
            _buildLabel('Gender'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: _inputDecoration('Pilih gender', Icons.people_outline),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textGrey),
              items: _genderOptions.map((gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 20),

            // ============ TANGGAL LAHIR ============
            _buildLabel('Tanggal Lahir'),
            const SizedBox(height: 8),
            TextField(
              controller: _birthDateController,
              readOnly: true,
              onTap: _pickBirthDate,
              decoration: _inputDecoration('Pilih tanggal lahir', Icons.cake_outlined).copyWith(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, color: AppTheme.textGrey, size: 20),
                  onPressed: _pickBirthDate,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ============ ALAMAT ============
            _buildLabel('Alamat'),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: _inputDecoration('Masukkan alamat lengkap', Icons.location_on_outlined)
                  .copyWith(alignLabelWithHint: true),
            ),
            const SizedBox(height: 40),

            // ============ TOMBOL SIMPAN ============
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Simpan Perubahan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.textGrey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppTheme.darkGreen, width: 1.5),
      ),
    );
  }
}