import 'package:flutter/material.dart';
import 'package:ekray/views/eCommerce/my_cart/layouts/my_cart_layout.dart';

class EcommerceMyCartView extends StatelessWidget {
  final bool isRoot;
  final bool isBuyNow;
  const EcommerceMyCartView({
    super.key,
    required this.isRoot,
    required this.isBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return EcommerceMyCartLayout(
      isRoot: isRoot,
      isBuynow: isBuyNow,
    );
  }
}
