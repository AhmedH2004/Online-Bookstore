import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveCartJson(String cartJson) async {
    await _prefs.setString('user_cart_data', cartJson);
  }

  static String? getCartJson() {
    return _prefs.getString('user_cart_data');
  }
  
  static Future<void> saveOrdersJson(String ordersJson) async {
    await _prefs.setString('user_orders_data', ordersJson);
  }

  static String? getOrdersJson() {
    return _prefs.getString('user_orders_data');
  }

  static Future<void> clearCartData() async {
    await _prefs.remove('user_cart_data');
  }

  static Future<void> saveUserEmail(String email) async {
    await _prefs.setString('remember_email', email);
  }

  static String? getUserEmail() {
    return _prefs.getString('remember_email');
  }
}
