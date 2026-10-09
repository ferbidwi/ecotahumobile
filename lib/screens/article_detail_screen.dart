import 'package:flutter/material.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Artikel'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Utama
            Image.network(
              article.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      article.category,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.darkGreen),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Judul
                  Text(article.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3)),
                  const SizedBox(height: 15),

                  // Penulis & Tanggal
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 15,
                        backgroundColor: AppTheme.lightGreen,
                        child: Icon(Icons.person, size: 18, color: AppTheme.darkGreen),
                      ),
                      const SizedBox(width: 10),
                      Text('Oleh ${article.author} • ${article.date}', style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Isi Konten
                  Text(
                    article.content,
                    style: const TextStyle(fontSize: 15, height: 1.8, color: AppTheme.textDark),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 25),

                  // Kotak Kutipan (Quote Box)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: AppTheme.darkGreen, width: 4)),
                      color: AppTheme.lightGreen,
                    ),
                    child: const Text(
                      '"Pilihan makanan kita hari ini menentukan kualitas lingkungan kita di masa depan."',
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Interaksi (Like, Comment, Save)
                  Row(
                    children: [
                      _buildInteraction(Icons.favorite_border, '1.2k'),
                      const SizedBox(width: 20),
                      _buildInteraction(Icons.chat_bubble_outline, '48'),
                      const SizedBox(width: 20),
                      _buildInteraction(Icons.bookmark_border, ''),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Tombol Beli Tahu Lokal
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Arahkan kembali ke Home/Produk
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Beli Tahu Lokal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteraction(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textGrey, size: 22),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 5),
          Text(count, style: const TextStyle(color: AppTheme.textGrey)),
        ],
      ],
    );
  }
}