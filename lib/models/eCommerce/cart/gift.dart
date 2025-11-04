// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:ekray/models/eCommerce/order/order_model.dart';

class Gift {
  final int id;
  final int cartId;
  final String name;
  final String thumbnail;
  final double price;
  final String? receiverName;
  final String? senderName;
  final String? note;
  final Address? address;
  Gift({
    required this.id,
    required this.cartId,
    required this.name,
    required this.thumbnail,
    required this.price,
    this.receiverName,
    this.senderName,
    this.note,
    this.address,
  });

  Gift copyWith({
    int? id,
    String? name,
    int? cartId,
    String? thumbnail,
    double? price,
    String? receiverName,
    String? senderName,
    String? note,
    Address? address,
  }) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      cartId: cartId ?? this.cartId,
      thumbnail: thumbnail ?? this.thumbnail,
      price: price ?? this.price,
      receiverName: receiverName ?? this.receiverName,
      senderName: senderName ?? this.senderName,
      note: note ?? this.note,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'cart_id': cartId,
      'thumbnail': thumbnail,
      'price': price,
      'receiver_name': receiverName,
      'sender_name': senderName,
      'note': note,
      'address': address?.toJson(),
    };
  }

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'] as int,
      name: map['name'] as String,
      cartId: map['cart_id'] as int,
      thumbnail: map['thumbnail'] as String,
      price: map['price'] as double,
      receiverName:
          map['receiver_name'] != null ? map['receiver_name'] as String : null,
      senderName:
          map['sender_name'] != null ? map['sender_name'] as String : null,
      note: map['note'] != null ? map['note'] as String : null,
      address: map['address'] != null
          ? Address.fromJson(map['address'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Gift.fromJson(String source) =>
      Gift.fromMap(json.decode(source) as Map<String, dynamic>);
}
