import 'dart:convert';

import 'country.dart';

class Data {
  List<Country>? countries;

  Data({this.countries});

  factory Data.fromMap(Map<String, dynamic> data) => Data(
        countries: (data['countries'] as List<dynamic>?)
            ?.map((e) => Country.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'countries': countries?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Data].
  factory Data.fromJson(String data) {
    return Data.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Data] to a JSON string.
  String toJson() => json.encode(toMap());
}
