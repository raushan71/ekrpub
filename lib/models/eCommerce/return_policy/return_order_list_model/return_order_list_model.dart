import 'dart:convert';

import 'data.dart';

class ReturnOrderListModel {
  String? message;
  Data? data;

  ReturnOrderListModel({this.message, this.data});

  factory ReturnOrderListModel.fromMap(Map<String, dynamic> data) {
    return ReturnOrderListModel(
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
  /// Parses the string and returns the resulting Json object as [ReturnOrderListModel].
  factory ReturnOrderListModel.fromJson(String data) {
    return ReturnOrderListModel.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [ReturnOrderListModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
