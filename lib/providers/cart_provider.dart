import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/local_storage_service.dart';

class CartItem {
  final Book book;
  int quantity;

  CartItem({required this.book, this.quantity = 1});

  Map<String, dynamic> toJson() => {
    'book': book.toJson(),
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    book: Book.fromJson(json['book']),
    quantity: json['quantity'] as int,
  );
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + (item.book.price * item.quantity));

  void addToCart(Book book) {
    final index = _items.indexWhere((item) => item.book.id == book.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(book: book, quantity: 1));
    }
    _saveToLocal();
    notifyListeners();
  }

  void updateQuantity(String bookId, int quantity) {
    final index = _items.indexWhere((item) => item.book.id == bookId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      _saveToLocal();
      notifyListeners();
    }
  }

  void removeItem(String bookId) {
    _items.removeWhere((item) => item.book.id == bookId);
    _saveToLocal();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    LocalStorageService.clearCartData();
    notifyListeners();
  }

  void _saveToLocal() {
    final jsonString = jsonEncode(_items.map((i) => i.toJson()).toList());
    LocalStorageService.saveCartJson(jsonString);
  }

  void loadCartFromLocal() {
    final jsonString = LocalStorageService.getCartJson();
    if (jsonString != null) {
      try {
        final List dynamicList = jsonDecode(jsonString);
        _items.clear();
        _items.addAll(dynamicList.map((i) => CartItem.fromJson(i)));
        notifyListeners();
      } catch (e) {
        debugPrint('Cart decode error: $e');
      }
    }
  }
}
