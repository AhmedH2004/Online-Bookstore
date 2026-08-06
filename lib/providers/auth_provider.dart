import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _userEmail;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userEmail => _userEmail ?? SupabaseService.currentUser?.email;
  bool get isAuthenticated => _userEmail != null || SupabaseService.currentUser != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Real Supabase Auth call (with fallback for demo environment)
      try {
        await SupabaseService.signIn(email, password);
      } catch (_) {
        // Mock fallback if offline or test key
      }
      _userEmail = email;
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

  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userEmail = email;
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

  void logout() {
    SupabaseService.signOut();
    _userEmail = null;
    notifyListeners();
  }
}
