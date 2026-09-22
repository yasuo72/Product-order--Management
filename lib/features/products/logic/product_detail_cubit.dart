import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/network_exceptions.dart';
import '../data/product_repository.dart';
import 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final ProductRepository _productRepository;

  ProductDetailCubit(this._productRepository) : super(const ProductDetailInitial());

  Future<void> fetchDetail(int id) async {
    emit(const ProductDetailLoading());
    try {
      final product = await _productRepository.getProductDetail(id);
      emit(ProductDetailSuccess(product));
    } on AppException catch (e) {
      emit(ProductDetailFailure(e.message));
    } catch (e) {
      emit(ProductDetailFailure('Failed to load product details: ${e.toString()}'));
    }
  }
}
