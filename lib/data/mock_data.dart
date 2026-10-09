import '../models/product.dart';
import '../models/article.dart'; // Tambahkan ini

// ... (kode mockProducts tetap ada di sini) ...

// Tambahkan data artikel di bawahnya
final List<Article> mockArticles = [
  Article(
    id: '1',
    title: 'Kenapa Memilih Tahu Lokal?',
    category: 'LINGKUNGAN',
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=500',
    readTime: '5 Menit Baca',
    date: '15 September 2026',
    author: 'Tim EcoTahu',
    content: 'Tahu bukan sekadar makanan, melainkan bagian dari budaya dan ekonomi lokal. Dengan memilih tahu yang diproduksi secara lokal, kita tidak hanya mendapatkan nutrisi terbaik yang segar, tetapi juga membantu mengurangi jejak karbon dari transportasi jarak jauh.\n\nSelain itu, produsen tahu lokal di bawah naungan EcoTahu berkomitmen pada proses produksi yang ramah lingkungan, memastikan limbah dibuang dengan baik untuk menjaga kelestarian alam sekitar kita.\n\nDukungan Anda terhadap produsen lokal juga berarti memberdayakan komunitas petani kedelai lokal dan pengrajin tahu tradisional yang telah menjaga warisan kuliner ini selama turun-temurun. Setiap potong tahu yang Anda nikmati adalah bentuk investasi bagi bumi yang lebih hijau.',
  ),
  Article(
    id: '2',
    title: 'Manfaat Tahu untuk Kesehatan Jantung',
    category: 'KESEHATAN',
    imageUrl: 'https://images.unsplash.com/photo-1596797038530-2c107229654b?auto=format&fit=crop&q=80&w=500',
    readTime: '5 Menit Baca',
    date: '10 September 2026',
    author: 'Dr. Ahmad',
    content: 'Tahu adalah sumber protein nabati yang sangat baik dan rendah lemak jenuh. Kandungan isoflavon dalam tahu telah terbukti secara ilmiah dapat membantu menurunkan kadar kolesterol jahat (LDL) dalam darah.\n\nDengan mengonsumsi tahu secara teratur sebagai pengganti daging merah, Anda dapat mengurangi risiko penyakit jantung koroner. Tahu juga kaya akan kalsium dan magnesium yang berperan penting dalam menjaga tekanan darah tetap stabil.',
  ),
  Article(
    id: '3',
    title: 'Cara Mengurangi Limbah Produksi Tahu',
    category: 'LINGKUNGAN',
    imageUrl: 'https://images.unsplash.com/photo-1584473457409-ae5c91d7d8b1?auto=format&fit=crop&q=80&w=500',
    readTime: '4 Menit Baca',
    date: '5 September 2026',
    author: 'Tim EcoTahu',
    content: 'Industri tahu tradisional sering kali menghasilkan limbah cair dan padat yang jika tidak diolah dengan baik dapat mencemari lingkungan. Di EcoTahu, kami menerapkan sistem pengolahan limbah yang berkelanjutan.\n\nAmpas tahu, yang merupakan limbah padat utama, kami olah kembali menjadi pakan ternak berkualitas tinggi dan bahan baku tempe gembus. Sedangkan limbah cairnya melalui proses filtrasi sebelum dibuang, dan sebagian digunakan untuk pupuk organik tanaman.',
  ),
];

final List<Product> mockProducts = [
  Product(
    id: '1',
    name: 'Tahu Putih',
    price: 'Rp 12.000/kg',
    priceValue: 12000,
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=500',
    description: 'Tahu putih segar dan berkualitas, dibuat secara tradisional dengan kedelai pilihan non-GMO. Memiliki tekstur yang lembut namun padat, cocok untuk berbagai olahan makanan mulai dari sup hingga tumisan.',
    rating: 4.8,
  ),
  Product(
    id: '2',
    name: 'Ampas Tahu',
    price: 'Rp 5.000/kg',
    priceValue: 5000,
    imageUrl: 'https://images.unsplash.com/photo-1596797038530-2c107229654b?auto=format&fit=crop&q=80&w=500',
    description: 'Ampas tahu segar hasil sisa pembuatan tahu. Sangat cocok untuk pakan ternak berkualitas atau diolah menjadi tempe gembus dan kerupuk. Kaya akan serat dan protein.',
    rating: 4.5,
  ),
];