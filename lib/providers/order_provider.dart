import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  OrderProvider() {
    _loadFromLocal();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = SupabaseService.currentUser;
      dynamic response;
      if (user != null) {
        response = await SupabaseService.client
            .from('orders')
            .select('*, order_items(*)')
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
      } else {
        response = await SupabaseService.client
            .from('orders')
            .select('*, order_items(*)')
            .order('created_at', ascending: false);
      }

      if (response != null && response is List && response.isNotEmpty) {
        final List<dynamic> data = response;
        _orders = data.map((json) {
          final itemsJson = (json['order_items'] as List<dynamic>? ?? [])
              .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
              .toList();
          return Order.fromJson(json as Map<String, dynamic>, itemsJson);
        }).toList();
        _saveToLocal();
      } else if (_orders.isEmpty) {
        _loadFromLocal();
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      _errorMessage = e.toString();
      _loadFromLocal();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder({
    required List<OrderItem> items,
    required double totalAmount,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = SupabaseService.currentUser;
      String orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      try {
        final orderData = <String, dynamic>{
          'total_amount': totalAmount,
          'status': 'Processing',
          'shipping_address': shippingAddress,
          'payment_method': paymentMethod,
        };

        if (user != null) {
          orderData['user_id'] = user.id;
        }

        final response = await SupabaseService.client
            .from('orders')
            .insert(orderData)
            .select('id')
            .single();

        if (response != null && response['id'] != null) {
          orderId = response['id'].toString();
        }

        final itemsData = items.map((item) {
          final map = <String, dynamic>{
            'order_id': orderId,
            'book_title': item.bookTitle,
            'book_cover': item.bookCover,
            'price': item.price,
            'quantity': item.quantity,
          };
          if (item.bookId.length > 20) {
            map['book_id'] = item.bookId;
          }
          return map;
        }).toList();

        await SupabaseService.client.from('order_items').insert(itemsData);
      } catch (e) {
        debugPrint('Supabase insert order warning: $e');
      }

      final newOrder = Order(
        id: orderId,
        userId: user?.id ?? 'guest-user',
        items: items,
        totalAmount: totalAmount,
        status: 'Processing',
        createdAt: DateTime.now(),
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      );

      _orders.insert(0, newOrder);
      _saveToLocal();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _saveToLocal() {
    try {
      final jsonList = _orders.map((o) => {
        'id': o.id,
        'user_id': o.userId,
        'total_amount': o.totalAmount,
        'status': o.status,
        'created_at': o.createdAt.toIso8601String(),
        'shipping_address': o.shippingAddress,
        'payment_method': o.paymentMethod,
        'order_items': o.items.map((item) => {
          'book_id': item.bookId,
          'book_title': item.bookTitle,
          'book_cover': item.bookCover,
          'price': item.price,
          'quantity': item.quantity,
        }).toList(),
      }).toList();
      LocalStorageService.saveOrdersJson(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving orders locally: $e');
    }
  }

  void _loadFromLocal() {
    try {
      final jsonString = LocalStorageService.getOrdersJson();
      if (jsonString != null && jsonString.isNotEmpty) {
        final List dynamicList = jsonDecode(jsonString);
        _orders = dynamicList.map((json) {
          final itemsJson = (json['order_items'] as List<dynamic>? ?? [])
              .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
              .toList();
          return Order.fromJson(json as Map<String, dynamic>, itemsJson);
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading orders locally: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final updated = Order(
        id: _orders[index].id,
        userId: _orders[index].userId,
        items: _orders[index].items,
        totalAmount: _orders[index].totalAmount,
        status: 'Cancelled',
        createdAt: _orders[index].createdAt,
        shippingAddress: _orders[index].shippingAddress,
        paymentMethod: _orders[index].paymentMethod,
      );
      _orders[index] = updated;
      _saveToLocal();
      notifyListeners();
    }
  }
}