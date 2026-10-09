import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // Tambah ke keranjang
  void addToCart(Product product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  // Hapus dari keranjang
  void removeFromCart(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

   void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Tambah kuantitas
  void increaseQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  // Kurangi kuantitas
  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      notifyListeners();
    }
  }

  // Hitung Subtotal
  int get subtotal {
    int total = 0;
    for (var item in _items) {
      total += item.product.priceValue * item.quantity;
    }
    return total;
  }
}