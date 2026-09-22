import 'package:equatable/equatable.dart';

class OrderDetails extends Equatable {
  final String orderId;
  final String customerName;
  final String mobileNumber;
  final String shippingAddress;
  final String city;
  final String pincode;
  final double totalAmount;
  final int totalItems;
  final DateTime orderDate;

  const OrderDetails({
    required this.orderId,
    required this.customerName,
    required this.mobileNumber,
    required this.shippingAddress,
    required this.city,
    required this.pincode,
    required this.totalAmount,
    required this.totalItems,
    required this.orderDate,
  });

  @override
  List<Object?> get props => [orderId, customerName, totalAmount, orderDate];
}

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting();
}

class CheckoutSuccess extends CheckoutState {
  final OrderDetails orderDetails;

  const CheckoutSuccess(this.orderDetails);

  @override
  List<Object?> get props => [orderDetails];
}

class CheckoutFailure extends CheckoutState {
  final String message;

  const CheckoutFailure(this.message);

  @override
  List<Object?> get props => [message];
}
