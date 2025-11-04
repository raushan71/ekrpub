import 'dart:convert';

import 'data.dart';

class ShopMessageModel {
  String? message;
  Data? data;

  ShopMessageModel({this.message, this.data});

  factory ShopMessageModel.fromMap(Map<String, dynamic> data) {
    return ShopMessageModel(
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
  /// Parses the string and returns the resulting Json object as [ShopMessageModel].
  factory ShopMessageModel.fromJson(String data) {
    return ShopMessageModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [ShopMessageModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
