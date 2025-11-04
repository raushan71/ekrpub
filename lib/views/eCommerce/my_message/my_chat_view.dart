import 'package:flutter/material.dart';
import 'package:ekray/models/eCommerce/product/product_details.dart';
import 'package:ekray/views/eCommerce/my_message/layouts/my_chat_layout.dart';
import 'package:ekray/models/eCommerce/shop_message_model/shop.dart';

class MyChatView extends StatelessWidget {
  final Shop shop;
  const MyChatView({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return MyChatLayout(
      shop: shop,
    );
  }
}
