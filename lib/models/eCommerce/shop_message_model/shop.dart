import 'dart:convert';

class Shop {
  int? id;
  String? name;
  String? logo;
  double? rating;
  bool? lastOnline;

  Shop({this.id, this.name, this.logo, this.rating, this.lastOnline});

  Shop copyWith({
    int? id,
    String? name,
    String? logo,
    double? rating,
    bool? lastOnline,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      rating: rating ?? this.rating,
      lastOnline: lastOnline ?? this.lastOnline,
    );
  }

  factory Shop.fromMap(Map<String, dynamic> data) => Shop(
        id: data['id'] as int?,
        name: data['name'] as String?,
        logo: data['logo'] as String?,
        rating: data['rating'] as double?,
        lastOnline: data['last_online'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'logo': logo,
        'rating': rating,
        'last_online': lastOnline,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Shop].
  factory Shop.fromJson(String data) {
    return Shop.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Shop] to a JSON string.
  String toJson() => json.encode(toMap());
}
