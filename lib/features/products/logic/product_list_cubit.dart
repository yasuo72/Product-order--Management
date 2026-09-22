import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/network_exceptions.dart';
import '../data/product_repository.dart';
import 'product_list_state.dart';

class ProductListCubit extends Cubit<ProductListState> {
  final ProductRepository _productRepository;
  static const int _pageSize = 10;
  Timer? _debounceTimer;

  ProductListCubit(this._productRepository) : super(const ProductListState());

  Future<void> fetchInitial() async {
    emit(state.copyWith(status: ProductListStatus.loading));
    try {
      final categoriesFuture = _productRepository.getCategories();
      final productsFuture = _productRepository.getProducts(
        limit: _pageSize,
        skip: 0,
        category: state.selectedCategory,
        searchQuery: state.searchQuery,
      );

      final categories = await categoriesFuture;
      final productsResult = await productsFuture;

      final products = productsResult.products;
      final total = productsResult.total;

      emit(state.copyWith(
        status: ProductListStatus.success,
        products: products,
        categories: categories,
        total: total,
        hasReachedMax: products.length >= total,
        errorMessage: null,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: ProductListStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductListStatus.failure,
        errorMessage: 'Failed to load products: ${e.toString()}',
      ));
    }
  }

  Future<void> loadMore() async {
    if (state.hasReachedMax ||
        state.status == ProductListStatus.loadingMore ||
        state.status == ProductListStatus.loading) {
      return;
    }

    emit(state.copyWith(status: ProductListStatus.loadingMore));

    try {
      final result = await _productRepository.getProducts(
        limit: _pageSize,
        skip: state.products.length,
        category: state.selectedCategory,
        searchQuery: state.searchQuery,
      );

      final newProducts = result.products;
      final updatedList = [...state.products, ...newProducts];

      emit(state.copyWith(
        status: ProductListStatus.success,
        products: updatedList,
        total: result.total,
        hasReachedMax: updatedList.length >= result.total || newProducts.isEmpty,
      ));
    } catch (_) {
      emit(state.copyWith(status: ProductListStatus.success));
    }
  }

  void searchWithDebounce(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      search(query);
    });
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    emit(state.copyWith(
      status: ProductListStatus.loading,
      searchQuery: trimmed,
      selectedCategory: 'All',
    ));

    try {
      final result = await _productRepository.getProducts(
        limit: _pageSize,
        skip: 0,
        searchQuery: trimmed,
      );

      emit(state.copyWith(
        status: ProductListStatus.success,
        products: result.products,
        total: result.total,
        hasReachedMax: result.products.length >= result.total,
        errorMessage: null,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: ProductListStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductListStatus.failure,
        errorMessage: 'Search failed: ${e.toString()}',
      ));
    }
  }

  Future<void> selectCategory(String category) async {
    if (state.selectedCategory == category && state.searchQuery.isEmpty) return;

    emit(state.copyWith(
      status: ProductListStatus.loading,
      selectedCategory: category,
      searchQuery: '',
    ));

    try {
      final result = await _productRepository.getProducts(
        limit: _pageSize,
        skip: 0,
        category: category,
      );

      emit(state.copyWith(
        status: ProductListStatus.success,
        products: result.products,
        total: result.total,
        hasReachedMax: result.products.length >= result.total,
        errorMessage: null,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: ProductListStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductListStatus.failure,
        errorMessage: 'Filter failed: ${e.toString()}',
      ));
    }
  }

  Future<void> refresh() async {
    try {
      final result = await _productRepository.getProducts(
        limit: _pageSize,
        skip: 0,
        category: state.selectedCategory,
        searchQuery: state.searchQuery,
      );

      emit(state.copyWith(
        status: ProductListStatus.success,
        products: result.products,
        total: result.total,
        hasReachedMax: result.products.length >= result.total,
        errorMessage: null,
      ));
    } catch (_) {
      // Keep existing products if refresh fails
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
