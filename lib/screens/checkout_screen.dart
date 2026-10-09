import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import 'qris_payment_screen.dart';
import 'transfer_payment_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'QRIS';
  bool _isProcessing = false;

  String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _handleBuatPesanan() async {
    setState(() => _isProcessing = true);

    final cart = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Ambil produk pertama (karena kita hanya jual 2 jenis, ambil yang ada di cart)
    final firstItem = cart.items.first;

    // Buat objek Order
    final newOrder = Order(
      orderNumber: orderProvider.generateOrderNumber(),
      productName: firstItem.product.name,
      quantity: firstItem.quantity,
      totalPrice: cart.subtotal,
      paymentMethod: _selectedPayment == 'QRIS'
          ? 'QRIS'
          : _selectedPayment == 'Transfer'
              ? 'Transfer Bank'
              : 'Bayar di Tempat',
      pickupMethod: 'Ambil di Tempat',
      orderDate: DateTime.now(),
    );

    // Simpan pesanan ke provider
    orderProvider.addOrder(newOrder);

    // Simulasi loading sebentar
    await Future.delayed(const Duration(milliseconds: 800));

    // Kosongkan keranjang
    cart.clearCart();

    setState(() => _isProcessing = false);

    if (!mounted) return;

    // ==================== ROUTING SESUAI METODE PEMBAYARAN ====================
    if (_selectedPayment == 'QRIS') {
      // Ke halaman QR Code
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QrisPaymentScreen(order: newOrder)),
      );
    } else if (_selectedPayment == 'Transfer') {
      // Ke halaman Transfer VA
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TransferPaymentScreen(order: newOrder)),
      );
    } else {
      // Bayar di Tempat → langsung ke Order Success
      newOrder.status = 'Menunggu Pengambilan';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrderSuccessScreen(order: newOrder)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Checkout'),
        centerTitle: false,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('Keranjang kosong.'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ALAMAT PENGAMBILAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textGrey, letterSpacing: 1)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                        child: const Row(
                          children: [
                            Icon(Icons.location_on, color: AppTheme.darkGreen),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Politeknik Negeri Jember', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Jl. Mastrip No. 164, Jember', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: AppTheme.textGrey),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('PESANAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textGrey, letterSpacing: 1)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: cart.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(item.product.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text('Kuantitas: ${item.quantity} kg', style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Text(formatCurrency(item.product.priceValue * item.quantity), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('METODE PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textGrey, letterSpacing: 1)),
                      const SizedBox(height: 10),
                      _buildPaymentOption(id: 'QRIS', title: 'QRIS', subtitle: 'Pembayaran melalui QRIS', icon: Icons.qr_code),
                      const SizedBox(height: 10),
                      _buildPaymentOption(id: 'Transfer', title: 'Transfer Bank', subtitle: 'BCA / BRI / Mandiri', icon: Icons.account_balance),
                      const SizedBox(height: 10),
                      _buildPaymentOption(id: 'Cash', title: 'Bayar di Tempat', subtitle: 'Bayar saat mengambil pesanan', icon: Icons.payments),
                      const SizedBox(height: 20),
                      const Text('RINGKASAN PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textGrey, letterSpacing: 1)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            _buildSummaryRow('Subtotal', formatCurrency(cart.subtotal)),
                            const SizedBox(height: 10),
                            _buildSummaryRow('Ongkos Pengiriman', 'Rp 0'),
                            const Divider(height: 30),
                            _buildSummaryRow('Total Pembayaran', formatCurrency(cart.subtotal), isTotal: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.creamBg,
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Harga', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                        Text(formatCurrency(cart.subtotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.textDark)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _handleBuatPesanan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Row(
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Buat Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentOption({required String id, required String title, required String subtitle, required IconData icon}) {
    bool isSelected = _selectedPayment == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = id),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightGreen : Colors.white,
          border: Border.all(color: isSelected ? AppTheme.darkGreen : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.darkGreen : AppTheme.textGrey),
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
            Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? AppTheme.darkGreen : AppTheme.textGrey),
          ],
        ),
      ),
    );
  }

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