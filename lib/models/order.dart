class OrderItem {
  final String bookId;
  final String bookTitle;
  final String bookCover;
  final double price;
  final int quantity;

  OrderItem({
    required this.bookId,
    required this.bookTitle,
    required this.bookCover,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      bookId: json['book_id']?.toString() ?? '',
      bookTitle: json['book_title'] as String? ?? 'Book',
      bookCover: json['book_cover'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as int?) ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'book_title': bookTitle,
      'book_cover': bookCover,
      'price': price,
      'quantity': quantity,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final String shippingAddress;
  final String paymentMethod;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.shippingAddress,
    required this.paymentMethod,
  });

  factory Order.fromJson(Map<String, dynamic> json, List<OrderItem> orderItems) {
    return Order(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? 'guest-user',
      items: orderItems,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Processing',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      shippingAddress: json['shipping_address'] as String? ?? 'N/A',
      paymentMethod: json['payment_method'] as String? ?? 'Credit Card',
    );
  }
}
