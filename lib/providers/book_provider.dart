import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/supabase_service.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Book> get books => List.unmodifiable(_books);
  List<Book> get bestsellers => _books.where((b) => b.isBestseller).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BookProvider() {
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      try {
        final response = await SupabaseService.client.from('books').select();
        final List<dynamic> data = response as List<dynamic>;
        if (data.isNotEmpty) {
          _books = data.map((json) => Book.fromJson(json)).toList();
        } else {
          _loadMockBooks();
        }
      } catch (_) {
        _loadMockBooks();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _loadMockBooks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadMockBooks() {
    _books = [
      Book(
        id: '1',
        title: 'The Midnight Library',
        author: 'Matt Haig',
        category: 'Fiction',
        price: 19.99,
        rating: 4.8,
        reviewsCount: 1240,
        coverUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=400',
        description: 'Between life and death there is a library, and within that library, the shelves go on forever.',
        isBestseller: true,
        stock: 15,
        pages: 304,
        publishedYear: 2020,
        isbn: '978-0525559474',
      ),
      Book(
        id: '2',
        title: 'Atomic Habits',
        author: 'James Clear',
        category: 'Psychology',
        price: 22.00,
        rating: 4.9,
        reviewsCount: 3820,
        coverUrl: 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?auto=format&fit=crop&q=80&w=400',
        description: 'An Easy & Proven Way to Build Good Habits & Break Bad Ones.',
        isBestseller: true,
        stock: 25,
        pages: 320,
        publishedYear: 2018,
        isbn: '978-0735211292',
      ),
      Book(
        id: '3',
        title: 'Station Eleven',
        author: 'Emily St. John Mandel',
        category: 'Fiction',
        price: 14.50,
        rating: 4.6,
        reviewsCount: 890,
        coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&q=80&w=400',
        description: "A audacious novel set in the eerie days of Civilization's collapse.",
        isBestseller: true,
        stock: 8,
        pages: 336,
        publishedYear: 2014,
        isbn: '978-0804172448',
      ),
      Book(
        id: '4',
        title: 'Circe',
        author: 'Madeline Miller',
        category: 'Fiction',
        price: 12.99,
        rating: 4.7,
        reviewsCount: 1560,
        coverUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&q=80&w=400',
        description: 'In the house of Helios, god of the sun, a daughter is born.',
        isBestseller: true,
        stock: 12,
        pages: 400,
        publishedYear: 2018,
        isbn: '978-0316556347',
      ),
    ];
  }
}
