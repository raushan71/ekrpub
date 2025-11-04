import 'package:ekray/models/eCommerce/cart/gift.dart';

class CartItem {
  CartItem({
    required this.shopId,
    required this.shopName,
    required this.shopLogo,
    required this.shopRating,
    required this.cartProduct,
  });
  late final int shopId;
  late final String shopName;
  late final String shopLogo;
  late final String shopRating;
  late final bool hasGift;
  late final List<CartProduct> cartProduct;

  CartItem.fromJson(Map<String, dynamic> json) {
    shopId = json['shop_id'];
    shopName = json['shop_name'];
    shopLogo = json['shop_logo'];
    shopRating = json['shop_rating'].toString();
    hasGift = json['has_gift'] ?? false;
    cartProduct = (json['products'] as List<dynamic>)
        .map((product) => CartProduct.fromJson(product))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['shop_id'] = shopId;
    data['shop_name'] = shopName;
    data['shop_logo'] = shopLogo;
    data['shop_rating'] = shopRating;
    data['has_gift'] = hasGift;
    data['products'] = cartProduct.map((product) => product.toJson()).toList();
    return data;
  }
}

class CartProduct {
  CartProduct({
    required this.id,
    required this.quantity,
    required this.name,
    required this.thumbnail,
    required this.brand,
    required this.price,
    required this.discountPrice,
    required this.discountPercentage,
    required this.rating,
    required this.totalReviews,
    required this.totalSold,
    required this.color,
    required this.size,
    required this.unit,
  });
  late final int id;
  late final int quantity;
  late final String name;
  late final String thumbnail;
  late final String? brand;
  late final double price;
  late final double discountPrice;
  late final double discountPercentage;
  late final double rating;
  late final String totalReviews;
  late final String totalSold;
  Color? color;
  Color? size;
  late final String? unit;
  late final Gift? gift;

  CartProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    quantity = json['quantity'];
    name = json['name'];
    thumbnail = json['thumbnail'];
    brand = json['brand'];
    price = json['price'];
    discountPrice = json['discount_price'];
    discountPercentage = json['discount_percentage'];
    rating = json['rating'];
    totalReviews = json['total_reviews'];
    totalSold = json['total_sold'];
    color = json["color"] == null ? null : Color.fromJson(json["color"]);
    size = json["size"] == null ? null : Color.fromJson(json["size"]);
    unit = json['unit'];
    gift = json['gift'] != null ? Gift.fromMap(json['gift']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['quantity'] = quantity;
    data['name'] = name;
    data['thumbnail'] = thumbnail;
    data['brand'] = brand;
    data['price'] = price;
    data['discount_price'] = discountPrice;
    data['discount_percentage'] = discountPercentage;
    data['rating'] = rating;
    data['total_reviews'] = totalReviews;
    data['total_sold'] = totalSold;
    data['color'] = color?.toJson();
    data['size'] = color?.toJson();
    data['unit'] = unit;
    data['gift'] = gift?.toJson();
    return data;
  }
}

class Color {
  int? id;
  String? name;
  String? colorCode;
  double? price;

  Color({
    this.id,
    this.name,
    this.colorCode,
    this.price,
  });

  factory Color.fromJson(Map<String, dynamic> json) => Color(
        id: json["id"],
        name: json["name"],
        colorCode: json["color_code"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "color_code": colorCode,
        "price": price,
      };
}
