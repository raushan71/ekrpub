// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:ekray/views/eCommerce/checkout/layouts/checkout_layout.dart';

class EcommerceCheckoutView extends StatelessWidget {
  final bool isBuyNow;
  final double payableAmount;
  final String? couponCode;

  const EcommerceCheckoutView({
    super.key,
    required this.payableAmount,
    required this.couponCode,
    this.isBuyNow = false,
  });

  @override
  Widget build(BuildContext context) {
    return EcommerceCheckoutLayout(
      payableAmount: payableAmount,
      couponCode: couponCode,
      isBuyNow: isBuyNow,
    );
  }
}
