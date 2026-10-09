import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import 'order_success_screen.dart';

class TransferPaymentScreen extends StatefulWidget {
  final Order order;

  const TransferPaymentScreen({super.key, required this.order});

  @override
  State<TransferPaymentScreen> createState() => _TransferPaymentScreenState();
}

class _TransferPaymentScreenState extends State<TransferPaymentScreen> {
  final List<Map<String, String>> _banks = [
    {'name': 'BCA', 'va': '8808123456789', 'icon': 'B'},
    {'name': 'BRI', 'va': '8808987654321', 'icon': 'B'},
    {'name': 'Mandiri', 'va': '8808555544444', 'icon': 'M'},
  ];

  int _selectedBank = 0;
  bool _isVerifying = false;

  String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil dicopy!'),
        backgroundColor: AppTheme.darkGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Simulasi webhook verification
  Future<void> _handleKonfirmasiTransfer() async {
    setState(() => _isVerifying = true);

    // Simulasi loading verifikasi (seperti webhook dari Midtrans)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Update status pesanan
    widget.order.status = 'Pembayaran Berhasil';

    // Auto-redirect ke Order Success
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OrderSuccessScreen(order: widget.order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bank = _banks[_selectedBank];

    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isVerifying ? null : () => Navigator.pop(context),
        ),
        title: const Text('Transfer Bank'),
      ),
      body: _isVerifying
          ? _buildVerifyingState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Bank Tujuan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // Pilihan Bank
                  ...List.generate(_banks.length, (index) {
                    final b = _banks[index];
                    final isSelected = _selectedBank == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedBank = index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.lightGreen : Colors.white,
                          border: Border.all(color: isSelected ? AppTheme.darkGreen : Colors.transparent, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.darkGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  b['icon']!,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(b['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isSelected ? AppTheme.darkGreen : AppTheme.textGrey,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 25),

                  // Detail Transfer
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Detail Transfer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 15),

                        // Nomor VA
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppTheme.creamBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.darkGreen.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nomor Virtual Account (${bank['name']})',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                                  const SizedBox(height: 5),
                                  Text(bank['va']!,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                ],
                              ),
                              IconButton(
                                onPressed: () => _copyToClipboard(bank['va']!, 'Nomor VA'),
                                icon: const Icon(Icons.copy, color: AppTheme.darkGreen, size: 20),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Nominal
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppTheme.creamBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.darkGreen.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Pembayaran',
                                      style: TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                                  const SizedBox(height: 5),
                                  Text(formatCurrency(widget.order.totalPrice),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkGreen)),
                                ],
                              ),
                              IconButton(
                                onPressed: () => _copyToClipboard(widget.order.totalPrice.toString(), 'Nominal'),
                                icon: const Icon(Icons.copy, color: AppTheme.darkGreen, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Transfer sesuai nominal tepat. Setelah transfer, klik tombol di bawah.',
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Tombol Konfirmasi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleKonfirmasiTransfer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Saya Sudah Transfer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ============ UI SAAT VERIFIKASI (SIMULASI WEBHOOK) ============
  Widget _buildVerifyingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: AppTheme.darkGreen,
                  strokeWidth: 5,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Memverifikasi Transfer...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Mohon tunggu sebentar, kami sedang mengecek transfer kamu',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Text(
              'Jangan tutup halaman ini',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}