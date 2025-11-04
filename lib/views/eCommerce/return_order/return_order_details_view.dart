import 'package:flutter/material.dart';
import 'package:ekray/views/eCommerce/return_order/layouts/return_order_details_layout.dart';

class ReturnOrderDetailsView extends StatelessWidget {
  final int orderId;
  const ReturnOrderDetailsView({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return ReturnOrderDetailsLayout(
      orderId: orderId,
    );
  }
}
