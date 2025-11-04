import 'package:flutter/material.dart';
import 'package:ekray/views/eCommerce/return_order/layouts/return_policy_product_layout.dart';

class ReturnPolicyProductView extends StatelessWidget {
  int orderId;
  ReturnPolicyProductView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return ReturnPolicyProductLayout(orderId: orderId);
  }
} 
