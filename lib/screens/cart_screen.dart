import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isDelivery = false;
  int shippingCost = 0;

  // Fungsi bantuan untuk format Rupiah (Rp 17.000)
  String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Keranjang'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              // Panggil fungsi clearCart dari Provider
              Provider.of<CartProvider>(context, listen: false).clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Keranjang berhasil dikosongkan!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('Keranjang kamu masih kosong bro!'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // List Item Keranjang
                      ...cart.items.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              // Gambar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item.product.imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 15),
                              // Info Produk
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        // Tombol Hapus per item (Ikon Silang)
                                        InkWell(
                                          onTap: () {
                                            cart.removeFromCart(item);
                                          },
                                          child: const Icon(Icons.close, size: 18, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    Text(item.product.price, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                                    const SizedBox(height: 10),
                                    // Quantity Control
                                    Row(
                                      children: [
                                        _buildQtyButton(Icons.remove, () => cart.decreaseQuantity(item)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 15),
                                          child: Text('${item.quantity} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        _buildQtyButton(Icons.add, () => cart.increaseQuantity(item)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Total Harga per Item
                              Text(
                                formatCurrency(item.product.priceValue * item.quantity),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkGreen),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 20),
                      const Text('Metode Pengambilan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),

                      // Opsi Ambil di Tempat
                      _buildShippingOption(
                        title: 'Ambil di Tempat',
                        subtitle: 'GRATIS ONGKIR',
                        isSelected: !isDelivery,
                        onTap: () {
                          setState(() {
                            isDelivery = false;
                            shippingCost = 0;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      // Opsi Diantar
                      _buildShippingOption(
                        title: 'Diantar ke Lokasi',
                        subtitle: '+ Rp 5.000',
                        isSelected: isDelivery,
                        onTap: () {
                          setState(() {
                            isDelivery = true;
                            shippingCost = 5000;
                          });
                        },
                      ),

                      const SizedBox(height: 20),
                      const Text('Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow('Subtotal', formatCurrency(cart.subtotal)),
                            const SizedBox(height: 10),
                            _buildSummaryRow('Ongkos Kirim', isDelivery ? formatCurrency(shippingCost) : 'Rp 0'),
                            const Divider(height: 30),
                            _buildSummaryRow('Total', formatCurrency(cart.subtotal + shippingCost), isTotal: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Tombol Checkout
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.creamBg,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Pindah ke Halaman Checkout
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Lanjut ke Checkout →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget Helper untuk Tombol +/-
  Widget _buildQtyButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppTheme.lightGreen,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 16, color: AppTheme.darkGreen),
      ),
    );
  }

  // Widget Helper untuk Opsi Pengiriman
  Widget _buildShippingOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightGreen : Colors.white,
          border: Border.all(color: isSelected ? AppTheme.darkGreen : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              title == 'Ambil di Tempat' ? Icons.store : Icons.local_shipping,
              color: isSelected ? AppTheme.darkGreen : AppTheme.textGrey,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: isSelected ? AppTheme.darkGreen : AppTheme.textGrey, fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.darkGreen : AppTheme.textGrey,
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Ringkasan
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: isTotal ? AppTheme.darkGreen : AppTheme.textDark, fontSize: isTotal ? 18 : 14)),
      ],
    );
  }
}