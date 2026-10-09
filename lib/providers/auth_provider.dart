import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userUsername = '';
  String _userGender = '';
  String _userBirthDate = '';
  String _userAddress = '';
  String _userPhotoBase64 = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userUsername => _userUsername;
  String get userGender => _userGender;
  String get userBirthDate => _userBirthDate;
  String get userAddress => _userAddress;
  String get userPhotoBase64 => _userPhotoBase64;

  // ==================== HELPER: SAVE PROFIL PER-EMAIL ====================
  Future<void> _saveProfileData() async {
    if (_userEmail.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final profileData = {
      'name': _userName,
      'email': _userEmail,
      'phone': _userPhone,
      'username': _userUsername,
      'gender': _userGender,
      'birthDate': _userBirthDate,
      'address': _userAddress,
      'photoBase64': _userPhotoBase64,
    };
    await prefs.setString('profile_$_userEmail', jsonEncode(profileData));
  }

  // ==================== HELPER: LOAD PROFIL ====================
  Future<void> _loadProfileData(String email) async {
    if (email.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('profile_$email');
    if (profileJson != null) {
      final data = jsonDecode(profileJson) as Map<String, dynamic>;
      _userName = data['name'] ?? '';
      _userEmail = data['email'] ?? email;
      _userPhone = data['phone'] ?? '';
      _userUsername = data['username'] ?? '';
      _userGender = data['gender'] ?? '';
      _userBirthDate = data['birthDate'] ?? '';
      _userAddress = data['address'] ?? '';
      _userPhotoBase64 = data['photoBase64'] ?? '';
    }
  }

  // ==================== CEK STATUS LOGIN ====================
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      final currentEmail = prefs.getString('currentEmail') ?? '';
      if (currentEmail.isNotEmpty) {
        await _loadProfileData(currentEmail);
        _userEmail = currentEmail;
      }
    }

    notifyListeners();
  }

  // ==================== REGISTER ====================
  Future<Map<String, dynamic>> registerWithEmail({
    required String name,
    required String email,
    required String password,
    String? username,
    String? phone,
    String? gender,
    String? birthDate,
    String? address,
  }) async {
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'Semua kolom wajib diisi!'};
      }
      if (password.length < 6) {
        return {'success': false, 'message': 'Password minimal 6 karakter!'};
      }
      if (!email.contains('@')) {
        return {'success': false, 'message': 'Format email tidak valid!'};
      }

      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await userCredential.user?.updateDisplayName(name);

      // Set state
      _isLoggedIn = true;
      _userName = name;
      _userEmail = email.trim();
      _userUsername = username ?? '';
      _userPhone = phone ?? '';
      _userGender = gender ?? '';
      _userBirthDate = birthDate ?? '';
      _userAddress = address ?? '';

      // Simpan profil (per-email) + session
      await _saveProfileData();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('currentEmail', _userEmail);

      notifyListeners();
      return {'success': true, 'message': 'Pendaftaran berhasil! 🎉'};
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email sudah terdaftar. Silakan login.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        case 'weak-password':
          message = 'Password terlalu lemah (min. 6 karakter).';
          break;
        default:
          message = 'Pendaftaran gagal: ${e.message}';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ==================== LOGIN ====================
  Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'Email dan password wajib diisi!'};
      }

      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _isLoggedIn = true;
      _userEmail = userCredential.user?.email ?? email.trim();

      // Load profil per-email
      await _loadProfileData(_userEmail);

      // Fallback nama dari Firebase kalau kosong
      if (_userName.isEmpty) {
        _userName = userCredential.user?.displayName ?? _userEmail.split('@')[0];
      }

      // Save session flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('currentEmail', _userEmail);

      // Simpan ulang profil (fallback kalau baru ada)
      await _saveProfileData();

      notifyListeners();
      return {'success': true, 'message': 'Berhasil masuk! 🎉'};
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Akun tidak ditemukan. Silakan daftar dulu.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Email atau password salah.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        case 'user-disabled':
          message = 'Akun ini telah dinonaktifkan.';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak percobaan. Coba lagi nanti.';
          break;
        default:
          message = 'Login gagal: ${e.message}';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ==================== LOGIN GOOGLE ====================
  Future<bool> loginWithGoogle() async {
    try {
      UserCredential? userCredential;

      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return false;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      _isLoggedIn = true;
      _userEmail = userCredential.user?.email ?? '';

      // Coba load profil yang sudah ada
      await _loadProfileData(_userEmail);

      // Fallback nama Google kalau kosong
      if (_userName.isEmpty) {
        _userName = userCredential.user?.displayName ?? 'Pengguna Google';
      }

      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('currentEmail', _userEmail);

      // Simpan profil (kalau baru, akan dibuat; kalau ada, akan tetap sama)
      await _saveProfileData();

      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error Google Sign-In: $e');
      return false;
    }
  }

  // ==================== UPDATE PROFIL ====================
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? username,
    String? gender,
    String? birthDate,
    String? address,
    String? photoBase64,
  }) async {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (phone != null) _userPhone = phone;
    if (username != null) _userUsername = username;
    if (gender != null) _userGender = gender;
    if (birthDate != null) _userBirthDate = birthDate;
    if (address != null) _userAddress = address;
    if (photoBase64 != null) _userPhotoBase64 = photoBase64;

    // Simpan sebagai JSON per-email
    await _saveProfileData();

    notifyListeners();
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Logout error: $e');
    }

    // Reset state di memory
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _userPhone = '';
    _userUsername = '';
    _userGender = '';
    _userBirthDate = '';
    _userAddress = '';
    _userPhotoBase64 = '';

    // ⚠️ HANYA hapus session flag, BUKAN data profil!
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('currentEmail');
    // Data 'profile_<email>' TETAP tersimpan
    // Data 'orders' TETAP tersimpan

    notifyListeners();
  }
}