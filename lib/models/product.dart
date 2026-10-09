class Product {
  final String id;
  final String name;
  final String price; // Untuk tampilan (String)
  final int priceValue; // Untuk perhitungan (Angka)
  final String imageUrl;
  final String description;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.priceValue,
    required this.imageUrl,
    required this.description,
    required this.rating,
  });
}