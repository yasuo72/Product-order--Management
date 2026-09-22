import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../logic/checkout_state.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderDetails orderDetails;

  const OrderSuccessScreen({
    super.key,
    required this.orderDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(orderDetails.orderDate);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Celebration Icon Circle
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 64,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Heading
                  Text(
                    'Order Placed Successfully!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thank you for your purchase. Your order has been placed and your cart is now cleared.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Order Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          'Order ID',
                          orderDetails.orderId,
                          isHighlight: true,
                        ),
                        const Divider(height: 20),
                        _buildDetailRow('Placed On', dateFormatted),
                        const SizedBox(height: 10),
                        _buildDetailRow('Recipient', orderDetails.customerName),
                        const SizedBox(height: 10),
                        _buildDetailRow('Phone', orderDetails.mobileNumber),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          'Deliver To',
                          '${orderDetails.shippingAddress}, ${orderDetails.city} - ${orderDetails.pincode}',
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow('Items', '${orderDetails.totalItems} items'),
                        const Divider(height: 20),
                        _buildDetailRow(
                          'Total Paid',
                          '\$${orderDetails.totalAmount.toStringAsFixed(2)}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Continue Shopping Action
                  CustomButton(
                    text: 'Continue Shopping',
                    icon: Icons.storefront_rounded,
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold || isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? AppColors.primary : null,
            ),
          ),
        ),
      ],
    );
  }
}
