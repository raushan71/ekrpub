import 'dart:convert';

import 'data.dart';

class FlashSalesListModel {
  String? message;
  Data? data;

  FlashSalesListModel({this.message, this.data});

  factory FlashSalesListModel.fromMap(Map<String, dynamic> data) {
    return FlashSalesListModel(
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
  /// Parses the string and returns the resulting Json object as [FlashSalesListModel].
  factory FlashSalesListModel.fromJson(String data) {
    return FlashSalesListModel.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [FlashSalesListModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
