import 'dart:convert';

import 'data.dart';

class AllCountryModel {
  String? message;
  Data? data;

  AllCountryModel({this.message, this.data});

  factory AllCountryModel.fromMap(Map<String, dynamic> data) {
    return AllCountryModel(
      message: data['message'] as String?,
      data: data['data'] == null
          ? null
          : Data.fromMap(data['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() => {
        'message': message,
        'data': data?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [AllCountryModel].
  factory AllCountryModel.fromJson(String data) {
    return AllCountryModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [AllCountryModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
