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
  final String warrantyInformation;
  final String shippingInformation;
  final String returnPolicy;

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
    this.warrantyInformation = '1 year standard warranty',
    this.shippingInformation = 'Ships in 1-2 business days',
    this.returnPolicy = '30 days return policy',
  });

  double get discountedPrice {
    if (discountPercentage <= 0) return price;
    final discounted = price - (price * (discountPercentage / 100));
    return double.parse(discounted.toStringAsFixed(2));
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final brandVal = json['brand'];
    String? brand;
    if (brandVal is String) {
      brand = brandVal;
    }

    final rawImages = json['images'];
    List<String> imagesList = [];
    if (rawImages is List) {
      imagesList = rawImages.map((e) => e.toString()).toList();
    }

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
      warrantyInformation: json['warrantyInformation'] as String? ?? '1 year standard warranty',
      shippingInformation: json['shippingInformation'] as String? ?? 'Ships in 1-2 business days',
      returnPolicy: json['returnPolicy'] as String? ?? '30 days return policy',
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
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'returnPolicy': returnPolicy,
    };
  }

  Map<String, dynamic> toSqliteMap() {
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
      'images': images.join(','),
      'thumbnail': thumbnail,
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'returnPolicy': returnPolicy,
    };
  }

  factory ProductModel.fromSqliteMap(Map<String, dynamic> map) {
    final imagesStr = map['images'] as String? ?? '';
    final imagesList = imagesStr.isEmpty ? <String>[] : imagesStr.split(',');

    return ProductModel(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (map['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      brand: map['brand'] as String?,
      images: imagesList,
      thumbnail: map['thumbnail'] as String? ?? '',
      warrantyInformation: map['warrantyInformation'] as String? ?? '1 year standard warranty',
      shippingInformation: map['shippingInformation'] as String? ?? 'Ships in 1-2 business days',
      returnPolicy: map['returnPolicy'] as String? ?? '30 days return policy',
    );
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
        warrantyInformation,
        shippingInformation,
        returnPolicy,
      ];
}
