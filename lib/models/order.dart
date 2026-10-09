class Order {
  final String orderNumber;
  final String productName;
  final int quantity;
  final int totalPrice;
  final String paymentMethod;
  final String pickupMethod;
  final DateTime orderDate;
  String status;

  Order({
    required this.orderNumber,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.paymentMethod,
    required this.pickupMethod,
    required this.orderDate,
    this.status = 'Menunggu Pembayaran',
  });

  // Convert ke JSON
  Map<String, dynamic> toJson() => {
        'orderNumber': orderNumber,
        'productName': productName,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'paymentMethod': paymentMethod,
        'pickupMethod': pickupMethod,
        'orderDate': orderDate.toIso8601String(),
        'status': status,
      };

  // Buat dari JSON
  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderNumber: json['orderNumber'],
        productName: json['productName'],
        quantity: json['quantity'],
        totalPrice: json['totalPrice'],
        paymentMethod: json['paymentMethod'],
        pickupMethod: json['pickupMethod'],
        orderDate: DateTime.parse(json['orderDate']),
        status: json['status'] ?? 'Menunggu Pembayaran',
      );
}