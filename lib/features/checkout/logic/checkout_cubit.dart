import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cart/logic/cart_cubit.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CartCubit cartCubit;

  CheckoutCubit({required this.cartCubit}) : super(const CheckoutInitial());

  Future<void> submitOrder({
    required String name,
    required String mobile,
    required String address,
    required String city,
    required String pincode,
  }) async {
    final cartState = cartCubit.state;
    if (cartState.items.isEmpty) {
      emit(const CheckoutFailure('Cannot process order with an empty cart.'));
      return;
    }

    emit(const CheckoutSubmitting());

    try {
      // Simulate network request to process order
      await Future.delayed(const Duration(milliseconds: 1400));

      final randomNum = 10000 + Random().nextInt(90000);
      final orderId = 'ORD-$randomNum';

      final details = OrderDetails(
        orderId: orderId,
        customerName: name.trim(),
        mobileNumber: mobile.trim(),
        shippingAddress: address.trim(),
        city: city.trim(),
        pincode: pincode.trim(),
        totalAmount: cartState.totalAmount,
        totalItems: cartState.totalQuantity,
        orderDate: DateTime.now(),
      );

      // Crucial requirement: After successful checkout, clear user's cart in memory and storage!
      await cartCubit.clearCart();

      emit(CheckoutSuccess(details));
    } catch (e) {
      emit(CheckoutFailure('Failed to place order: ${e.toString()}'));
    }
  }

  void reset() {
    emit(const CheckoutInitial());
  }
}
