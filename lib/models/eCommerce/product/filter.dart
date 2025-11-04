class Filters {
  List<Color>? sizes;
  List<Color>? colors;
  List<Brand>? brands;
  double? minPrice;
  double? maxPrice;

  Filters({
    this.sizes,
    this.colors,
    this.brands,
    this.minPrice,
    this.maxPrice,
  });

  factory Filters.fromMap(Map<String, dynamic> json) => Filters(
        sizes: json["sizes"] == null
            ? []
            : List<Color>.from(json["sizes"]!.map((x) => Color.fromJson(x))),
        colors: json["colors"] == null
            ? []
            : List<Color>.from(json["colors"]!.map((x) => Color.fromJson(x))),
        brands: json["brands"] == null
            ? []
            : List<Brand>.from(json["brands"]!.map((x) => Brand.fromJson(x))),
        minPrice: json["min_price"] is double
            ? json["min_price"]
            : json["min_price"].toDouble(),
        maxPrice: json["max_price"] is double
            ? json["max_price"]
            : json["max_price"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "sizes": sizes == null
            ? []
            : List<dynamic>.from(sizes!.map((x) => x.toJson())),
        "colors": colors == null
            ? []
            : List<dynamic>.from(colors!.map((x) => x.toJson())),
        "brands": brands == null
            ? []
            : List<dynamic>.from(brands!.map((x) => x.toJson())),
        "min_price": minPrice,
        "max_price": maxPrice,
      };
}

class Brand {
  int? id;
  String? name;

  Brand({
    this.id,
    this.name,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
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
