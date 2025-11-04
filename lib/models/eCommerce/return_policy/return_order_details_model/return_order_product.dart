import 'dart:convert';

class ReturnOrderProduct {
  int? productId;
  String? productName;
  double? productPrice;
  String? thumbnail;
  int? quantity;
  String? color;
  String? size;
  String? unit;
  double? price;

  ReturnOrderProduct({
    this.productId,
    this.productName,
    this.productPrice,
    this.thumbnail,
    this.quantity,
    this.color,
    this.size,
    this.unit,
    this.price,
  });

  factory ReturnOrderProduct.fromMap(Map<String, dynamic> data) {
    return ReturnOrderProduct(
      productId: data['product_id'] as int?,
      productName: data['product_name'] as String?,
      productPrice: data['product_price'] as double?,
      thumbnail: data['thumbnail'] as String?,
      quantity: data['quantity'] as int?,
      color: data['color'] as String?,
      size: data['size'] as String?,
      unit: data['unit'] as String?,
      price: data['price'] as double?,
    );
  }

  Map<String, dynamic> toMap() => {
        'product_id': productId,
        'product_name': productName,
        'product_price': productPrice,
        'thumbnail': thumbnail,
        'quantity': quantity,
        'color': color,
        'size': size,
        'unit': unit,
        'price': price,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [ReturnOrderProduct].
  factory ReturnOrderProduct.fromJson(String data) {
    return ReturnOrderProduct.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [ReturnOrderProduct] to a JSON string.
  String toJson() => json.encode(toMap());
}
