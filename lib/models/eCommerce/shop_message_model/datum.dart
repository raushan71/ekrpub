import 'dart:convert';

import 'product.dart';
import 'shop.dart';
import 'user.dart';

class ShopMessage {
  int? id;
  Shop? shop;
  User? user;
  ProductMessage? product;
  String? lastMessage;
  String? lastMessageTime;
  bool? isRead;
  int? unreadMessageUser;
  int? unreadMessageShop;

  ShopMessage({
    this.id,
    this.shop,
    this.user,
    this.product,
    this.lastMessage,
    this.lastMessageTime,
    this.isRead,
    this.unreadMessageUser,
    this.unreadMessageShop,
  });

  factory ShopMessage.fromMap(Map<String, dynamic> data) => ShopMessage(
        id: data['id'] as int?,
        shop: data['shop'] == null
            ? null
            : Shop.fromMap(data['shop'] as Map<String, dynamic>),
        user: data['user'] == null
            ? null
            : User.fromMap(data['user'] as Map<String, dynamic>),
        product: data['product'] == null
            ? null
            : ProductMessage.fromMap(data['product'] as Map<String, dynamic>),
        lastMessage: data['last_message'] as String?,
        lastMessageTime: data['last_message_time'] as String?,
        isRead: data['is_read'] as bool?,
        unreadMessageUser: data['unread_message_user'] as int?,
        unreadMessageShop: data['unread_message_shop'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'shop': shop?.toMap(),
        'user': user?.toMap(),
        'product': product?.toMap(),
        'last_message': lastMessage,
        'last_message_time': lastMessageTime,
        'is_read': isRead,
        'unread_message_user': unreadMessageUser,
        'unread_message_shop': unreadMessageShop,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [ShopMessage].
  factory ShopMessage.fromJson(String data) {
    return ShopMessage.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [ShopMessage] to a JSON string.
  String toJson() => json.encode(toMap());
}
