import 'package:flutter/material.dart';
import 'package:ekray/views/eCommerce/order_details/layouts/order_details_layout.dart';

class OrderDetailsView extends StatelessWidget {
  final int orderId;
  const OrderDetailsView({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return OrderDetailsLayout(
      orderId: orderId,
    );
  }
}
