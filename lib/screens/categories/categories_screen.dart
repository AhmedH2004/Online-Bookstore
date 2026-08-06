import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/book_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/book_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categoryMetadata = [
    {'name': 'All', 'icon': Icons.grid_view, 'color': Color(0xFF4F46E5)},
    {'name': 'Fiction', 'icon': Icons.menu_book, 'color': Color(0xFF4F46E5)},
    {'name': 'Psychology', 'icon': Icons.psychology, 'color': Color(0xFF0EA5E9)},
    {'name': 'Technology', 'icon': Icons.computer, 'color': Color(0xFF10B981)},
    {'name': 'History', 'icon': Icons.history_edu, 'color': Color(0xFFF59E0B)},
    {'name': 'Science Fiction', 'icon': Icons.rocket_launch, 'color': Color(0xFF8B5CF6)},
    {'name': 'Art & Design', 'icon': Icons.palette, 'color': Color(0xFFEC4899)},
  ];

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    // Filter books by search and selected category
    final categoryBooks = bookProvider.books.where((book) {
      final matchesCat = _selectedCategory == 'All' ||
          book.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/account'),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Selector Cards Bar
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _categoryMetadata.length,
                itemBuilder: (context, index) {
                  final cat = _categoryMetadata[index];
                  final catName = cat['name'] as String;
                  final isSelected = _selectedCategory == catName;

                  // Compute real book count for each category
                  final count = catName == 'All'
                      ? bookProvider.books.length
                      : bookProvider.books.where((b) => b.category.toLowerCase() == catName.toLowerCase()).length;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = catName),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            color: isSelected ? Colors.white : (cat['color'] as Color),
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            catName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '$count Books',
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Search in Category Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search within $_selectedCategory...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Category Books Grid Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedCategory Books',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  Chip(
                    label: Text('${categoryBooks.length} Found', style: const TextStyle(fontSize: 11, color: Color(0xFF4F46E5))),
                    backgroundColor: const Color(0xFFEEF2FF),
                  ),
                ],
              ),
            ),

            // Book Grid
            bookProvider.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : categoryBooks.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No books found in this category.')),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: categoryBooks.length,
                        itemBuilder: (context, index) {
                          final book = categoryBooks[index];
                          return BookCard(book: book);
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
