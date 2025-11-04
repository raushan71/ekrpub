import 'dart:convert';

class AddToCartModel {
  final int productId;
  final int quantity;
  final int? size;
  final int? color;
  final String? unit;
  final int? isBuyNow;
  AddToCartModel({
    required this.productId,
    required this.quantity,
    this.size,
    this.color,
    this.unit,
    this.isBuyNow,
  });

  AddToCartModel copyWith({
    int? productId,
    int? quantity,
    int? size,
    int? color,
    String? unit,
  }) {
    return AddToCartModel(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      color: color ?? this.color,
      unit: unit ?? this.unit,
      isBuyNow: isBuyNow ?? isBuyNow,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'product_id': productId,
      'quantity': quantity,
      'size': size,
      'color': color,
      'unit': unit,
      'is_buy_now': isBuyNow,
    };
  }

  factory AddToCartModel.fromMap(Map<String, dynamic> map) {
    return AddToCartModel(
      productId: map['productId'] as int,
      quantity: map['quantity'] as int,
      size: map['size'] != null ? map['size'] as int : null,
      color: map['color'] != null ? map['color'] as int : null,
      unit: map['unit'] != null ? map['unit'] as String : null,
      isBuyNow: map['is_buy_now'] != null ? map['is_buy_now'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AddToCartModel.fromJson(String source) =>
      AddToCartModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
