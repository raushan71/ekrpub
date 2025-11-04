import 'dart:convert';

class Country {
  int? id;
  String? name;
  String? phoneCode;

  Country({this.id, this.name, this.phoneCode});

  factory Country.fromMap(Map<String, dynamic> data) => Country(
        id: data['id'] as int?,
        name: data['name'] as String?,
        phoneCode: data['phone_code'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone_code': phoneCode,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Country].
  factory Country.fromJson(String data) {
    return Country.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Country] to a JSON string.
  String toJson() => json.encode(toMap());
}
