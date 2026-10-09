import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'my_orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: auth.isLoggedIn ? _buildLoggedIn(context, auth) : _buildNotLoggedIn(context),
      ),
    );
  }

  // ============ JIKA BELUM LOGIN ============
  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppTheme.lightGreen, shape: BoxShape.circle),
              child: const Icon(Icons.person_outline, size: 60, color: AppTheme.darkGreen),
            ),
            const SizedBox(height: 20),
            const Text('Belum Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              'Silakan login terlebih dahulu untuk mengakses profil dan fitur lainnya.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textGrey),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Masuk Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ JIKA SUDAH LOGIN ============
  Widget _buildLoggedIn(BuildContext context, AuthProvider auth) {
    final orderCount = Provider.of<OrderProvider>(context).orders.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Akun Saya', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Kartu Profil
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              children: [
                // Avatar Dinamis
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightGreen,
                    image: auth.userPhotoBase64.isNotEmpty
                        ? DecorationImage(
                            image: MemoryImage(base64Decode(auth.userPhotoBase64)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: auth.userPhotoBase64.isEmpty
                      ? const Icon(Icons.person, size: 55, color: AppTheme.darkGreen)
                      : null,
                ),
                const SizedBox(height: 15),
                Text(auth.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(
                  auth.userEmail.isNotEmpty ? auth.userEmail : auth.userPhone,
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Profil'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.darkGreen,
                    side: const BorderSide(color: AppTheme.darkGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Menu Items
          _buildMenuItem(
            context,
            icon: Icons.receipt_long,
            title: 'Pesanan Saya',
            subtitle: orderCount > 0 ? '$orderCount pesanan' : 'Lihat riwayat dan status pesanan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
              );
            },
          ),
          _buildMenuItem(context, icon: Icons.location_on, title: 'Alamat', subtitle: 'Kelola alamat pengiriman'),
          _buildMenuItem(context, icon: Icons.favorite, title: 'Favorit', subtitle: 'Produk yang kamu simpan'),
          _buildMenuItem(context, icon: Icons.help_outline, title: 'Bantuan', subtitle: 'Pusat bantuan EcoTahu'),
          _buildMenuItem(context, icon: Icons.info_outline, title: 'Tentang EcoTahu', subtitle: 'Informasi aplikasi'),
          const SizedBox(height: 20),

          // Tombol Keluar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Konfirmasi'),
                    content: const Text('Yakin mau keluar dari akun bro?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Keluar', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await auth.logout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil keluar')));
                  }
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required String subtitle, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap ?? () {},
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.lightGreen, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.darkGreen, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
      ),
    );
  }
}