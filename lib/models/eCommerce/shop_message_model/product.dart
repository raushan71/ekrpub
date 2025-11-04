import 'dart:convert';

class ProductMessage {
  int? id;
  String? name;
  String? thumbnail;
  double? discountPrice;
  double? rating;
  String? totalReviews;
  double? price;

  ProductMessage({
    this.id,
    this.name,
    this.thumbnail,
    this.discountPrice,
    this.rating,
    this.totalReviews,
    this.price,
  });

  factory ProductMessage.fromMap(Map<String, dynamic> data) => ProductMessage(
        id: data['id'] as int?,
        name: data['name'] as String?,
        thumbnail: data['thumbnail'] as String?,
        discountPrice: (data['discount_price'] as num).toDouble(),
        rating: data['rating'] as double?,
        totalReviews: data['total_reviews'] as String?,
        price: (data['price'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'thumbnail': thumbnail,
        'discount_price': discountPrice,
        'rating': rating,
        'total_reviews': totalReviews,
        'price': price,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [ProductMessage].
  factory ProductMessage.fromJson(String data) {
    return ProductMessage.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [ProductMessage] to a JSON string.
  String toJson() => json.encode(toMap());
}
