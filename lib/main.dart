import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/supabase_service.dart';
import 'services/local_storage_service.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/book_provider.dart';
import 'providers/order_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/bestsellers_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/account/account_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase Backend
  await SupabaseService.initialize();
  
  // Initialize Local Storage
  await LocalStorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()..fetchBooks()),
        ChangeNotifierProvider(create: (_) => CartProvider()..loadCartFromLocal()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const PageTurnBookstoreApp(),
    ),
  );
}

class PageTurnBookstoreApp extends StatelessWidget {
  const PageTurnBookstoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PageTurn Bookstore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // Indigo primary
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF0EA5E9),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/bestsellers': (context) => const BestsellersScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/cart': (context) => const CartScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/account': (context) => const AccountScreen(),
      },
    );
  }
}
