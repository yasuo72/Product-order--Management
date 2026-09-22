import 'package:equatable/equatable.dart';
import '../data/models/product_model.dart';

enum ProductListStatus { initial, loading, success, failure, loadingMore }

class ProductListState extends Equatable {
  final ProductListStatus status;
  final List<ProductModel> products;
  final bool hasReachedMax;
  final String selectedCategory;
  final String searchQuery;
  final List<String> categories;
  final String? errorMessage;
  final int total;

  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const [],
    this.hasReachedMax = false,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.categories = const ['All'],
    this.errorMessage,
    this.total = 0,
  });

  ProductListState copyWith({
    ProductListStatus? status,
    List<ProductModel>? products,
    bool? hasReachedMax,
    String? selectedCategory,
    String? searchQuery,
    List<String>? categories,
    String? errorMessage,
    int? total,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        hasReachedMax,
        selectedCategory,
        searchQuery,
        categories,
        errorMessage,
        total,
      ];
}
