import 'dart:convert';

class GiftAddModel {
  final int productId;
  final int giftId;
  final String? receiverName;
  final String? senderName;
  final String? note;
  final int? addressId;
  GiftAddModel({
    required this.productId,
    required this.giftId,
    this.receiverName,
    this.senderName,
    this.note,
    this.addressId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'product_id': productId,
      'gift_id': giftId,
      'receiver_name': receiverName,
      'sender_name': senderName,
      'note': note,
      'address_id': addressId,
    };
  }

  factory GiftAddModel.fromMap(Map<String, dynamic> map) {
    return GiftAddModel(
      productId: map['product_id'] as int,
      giftId: map['gift_id'] as int,
      receiverName:
          map['receiver_name'] != null ? map['receiver_name'] as String : null,
      senderName:
          map['sender_name'] != null ? map['sender_name'] as String : null,
      note: map['note'] != null ? map['note'] as String : null,
      addressId: map['address_id'] != null ? map['address_id'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GiftAddModel.fromJson(String source) =>
      GiftAddModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
