import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand;
  final List<String> images;
  final String thumbnail;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    this.brand,
    required this.images,
    required this.thumbnail,
  });

  double get discountedPrice {
    if (discountPercentage <= 0) return price;
    final discounted = price - (price * (discountPercentage / 100));
    return double.parse(discounted.toStringAsFixed(2));
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle brand (some products might not have brand or have it null)
    final brandVal = json['brand'];
    String? brand;
    if (brandVal is String) {
      brand = brandVal;
    }

    // Handle images list safely
    final rawImages = json['images'];
    List<String> imagesList = [];
    if (rawImages is List) {
      imagesList = rawImages.map((e) => e.toString()).toList();
    }

    // Fallback thumbnail if empty
    String thumbnail = json['thumbnail'] as String? ?? '';
    if (thumbnail.isEmpty && imagesList.isNotEmpty) {
      thumbnail = imagesList.first;
    }

    return ProductModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: brand,
      images: imagesList,
      thumbnail: thumbnail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'images': images,
      'thumbnail': thumbnail,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        price,
        discountPercentage,
        rating,
        stock,
        brand,
        images,
        thumbnail,
      ];
}
