class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final double price;
  final double rating;
  final int reviewsCount;
  final String coverUrl;
  final String description;
  final bool isBestseller;
  final int stock;
  final int pages;
  final int publishedYear;
  final String isbn;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.coverUrl,
    required this.description,
    required this.isBestseller,
    required this.stock,
    required this.pages,
    required this.publishedYear,
    required this.isbn,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      category: json['category_name'] ?? json['category'] ?? 'General',
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      coverUrl: json['cover_url'] as String,
      description: json['description'] as String,
      isBestseller: json['is_bestseller'] as bool? ?? false,
      stock: json['stock'] as int? ?? 10,
      pages: json['pages'] as int? ?? 250,
      publishedYear: json['published_year'] as int? ?? 2024,
      isbn: json['isbn'] as String? ?? '978-0000000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'category_name': category,
      'price': price,
      'rating': rating,
      'reviews_count': reviewsCount,
      'cover_url': coverUrl,
      'description': description,
      'is_bestseller': isBestseller,
      'stock': stock,
      'pages': pages,
      'published_year': publishedYear,
      'isbn': isbn,
    };
  }
}
