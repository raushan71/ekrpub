import 'dart:convert';

class ShopGift {
  final int id;
  final String name;
  final int price;
  final String thumbnail;
  ShopGift({
    required this.id,
    required this.name,
    required this.price,
    required this.thumbnail,
  });

  ShopGift copyWith({
    int? id,
    String? name,
    int? price,
    String? thumbnail,
  }) {
    return ShopGift(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      'thumbnail': thumbnail,
    };
  }

  factory ShopGift.fromMap(Map<String, dynamic> map) {
    return ShopGift(
      id: map['id'].toInt() as int,
      name: map['name'] as String,
      price: map['price'].toInt() as int,
      thumbnail: map['thumbnail'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ShopGift.fromJson(String source) =>
      ShopGift.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'GiftItem(id: $id, name: $name, price: $price, thumbnail: $thumbnail)';
  }

  @override
  bool operator ==(covariant ShopGift other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.price == price &&
        other.thumbnail == thumbnail;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ price.hashCode ^ thumbnail.hashCode;
  }
}
