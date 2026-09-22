import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_order_app/core/constants/app_colors.dart';
import 'package:product_order_app/core/widgets/custom_button.dart';
import 'package:product_order_app/core/widgets/custom_text_field.dart';
import 'package:product_order_app/features/auth/logic/auth_cubit.dart';
import 'package:product_order_app/features/cart/logic/cart_cubit.dart';
import 'package:product_order_app/features/cart/logic/cart_state.dart';
import '../logic/checkout_cubit.dart';
import '../logic/checkout_state.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _paymentMethod = 'Cash on Delivery';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      _nameController.text = user.fullName.isNotEmpty ? user.fullName : user.username;
      _mobileController.text = '9876543210';
      _addressController.text = 'Flat 402, Skyline Residency, MG Road';
      _cityController.text = 'Mumbai';
      _pincodeController.text = '400001';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _onPlaceOrder() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<CheckoutCubit>().submitOrder(
            name: _nameController.text,
            mobile: _mobileController.text,
            address: _addressController.text,
            city: _cityController.text,
            pincode: _pincodeController.text,
          );
    }
  }

  Widget _buildStepItem(String label, IconData icon, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isActive ? AppColors.primary : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(orderDetails: state.orderDetails),
            ),
          );
        } else if (state is CheckoutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Checkout & Review',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Progress Indicator (Key Polish)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStepItem('Delivery', Icons.location_on_rounded, true),
                      Container(width: 20, height: 1.5, color: AppColors.primary),
                      _buildStepItem('Payment', Icons.payment_rounded, true),
                      Container(width: 20, height: 1.5, color: Colors.grey.withAlpha(100)),
                      _buildStepItem('Confirm', Icons.check_circle_rounded, false),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Shipping Address
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '1. Shipping Address',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Full name is required';
                    if (v.trim().length < 3) return 'Name must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mobile Number
                CustomTextField(
                  controller: _mobileController,
                  label: 'Mobile Number',
                  hint: '10-digit mobile number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Mobile number is required';
                    final cleaned = v.trim().replaceAll(RegExp(r'\D'), '');
                    if (cleaned.length != 10) return 'Please enter a valid 10-digit mobile number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Street Address
                CustomTextField(
                  controller: _addressController,
                  label: 'Street Address',
                  hint: 'House/Flat No., Building, Street',
                  prefixIcon: Icons.home_outlined,
                  maxLines: 2,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Address is required';
                    if (v.trim().length < 8) return 'Address must be at least 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // City & Pincode in Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: _cityController,
                        label: 'City',
                        hint: 'City name',
                        prefixIcon: Icons.location_city_outlined,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'City is required';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _pincodeController,
                        label: 'Pincode',
                        hint: '6 digits',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final cleaned = v.trim().replaceAll(RegExp(r'\D'), '');
                          if (cleaned.length != 6) return '6 digits';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Section: Payment Method
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.payment_outlined, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '2. Payment Method',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildPaymentOption(
                        title: 'Cash on Delivery (COD)',
                        subtitle: 'Pay with cash upon arrival',
                        icon: Icons.money_rounded,
                        value: 'Cash on Delivery',
                        isDark: isDark,
                      ),
                      Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      _buildPaymentOption(
                        title: 'Instant UPI / QR Code',
                        subtitle: 'Google Pay, PhonePe, Paytm, BHIM',
                        icon: Icons.qr_code_rounded,
                        value: 'UPI / QR',
                        isDark: isDark,
                      ),
                      Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      _buildPaymentOption(
                        title: 'Credit / Debit Card',
                        subtitle: 'Visa, Mastercard, RuPay cards accepted',
                        icon: Icons.credit_card_rounded,
                        value: 'Credit / Debit Card',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Order Summary Card
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, cartState) {
                    final freeShipping = cartState.subtotal >= 50.0;
                    final shippingCost = freeShipping ? 0.0 : cartState.shippingFee;
                    final finalPayable = cartState.subtotal + shippingCost;

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '3. Order Review',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${cartState.totalQuantity} items',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Items Subtotal'),
                              Text('\$${cartState.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Delivery Shipping'),
                              Text(
                                freeShipping ? 'FREE' : '\$${shippingCost.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: freeShipping ? AppColors.success : null,
                                ),
                              ),
                            ],
                          ),
                          if (cartState.totalSavings > 0) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Discounts', style: TextStyle(color: AppColors.success)),
                                Text('-\$${cartState.totalSavings.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total to Pay', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                              Text(
                                '\$${finalPayable.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 256-bit Security Banner
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '256-bit SSL Encrypted & Secure Checkout',
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Submit Button
                BlocBuilder<CheckoutCubit, CheckoutState>(
                  builder: (context, checkoutState) {
                    final isSubmitting = checkoutState is CheckoutSubmitting;

                    return CustomButton(
                      text: 'Place Order Now',
                      isLoading: isSubmitting,
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: _onPlaceOrder,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required bool isDark,
  }) {
    final isSelected = _paymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(isDark ? 35 : 12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(30)
                    : (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
