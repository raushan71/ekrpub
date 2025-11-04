import 'dart:convert';

import 'package:ekray/models/eCommerce/shop_message_model/product.dart';

import 'shop.dart';
import 'user.dart';

class Messages {
  int? id;
  Shop? shop;
  UserMessage? user;
  ProductMessage? product;
  String? type;
  dynamic message;
  int? isSeen;
  DateTime? createdAt;
  bool? shopActiveStatus;
  bool? userActiveStatus;

  Messages({
    this.id,
    this.shop,
    this.user,
    this.product,
    this.type,
    this.message,
    this.isSeen,
    this.createdAt,
    this.shopActiveStatus,
    this.userActiveStatus,
  });

  factory Messages.fromMap(Map<String, dynamic> data) => Messages(
        id: data['id'] as int?,
        shop: data['shop'] == null
            ? null
            : Shop.fromMap(data['shop'] as Map<String, dynamic>),
        user: data['user'] == null
            ? null
            : UserMessage.fromMap(data['user'] as Map<String, dynamic>),
        product: data['product'] == null
            ? null
            : ProductMessage.fromMap(data['product'] as Map<String, dynamic>),
        type: data['type'] as String?,
        message: data['message'] as dynamic,
        isSeen: data['is_seen'] as int?,
        createdAt: data['created_at'] == null
            ? null
            : DateTime.parse(data['created_at'] as String),
        shopActiveStatus: data['shop_active_status'] as bool?,
        userActiveStatus: data['user_active_status'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'shop': shop?.toMap(),
        'user': user?.toMap(),
        'product': product,
        'type': type,
        'message': message,
        'is_seen': isSeen,
        'created_at': createdAt?.toIso8601String(),
        'shop_active_status': shopActiveStatus,
        'user_active_status': userActiveStatus,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Message].
  factory Messages.fromJson(String data) {
    return Messages.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Message] to a JSON string.
  String toJson() => json.encode(toMap());
}
