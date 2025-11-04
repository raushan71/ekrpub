import 'dart:convert';

import 'data.dart';

class ReturnOrderDetailsModel {
  String? message;
  Data? data;

  ReturnOrderDetailsModel({this.message, this.data});

  factory ReturnOrderDetailsModel.fromMap(Map<String, dynamic> data) {
    return ReturnOrderDetailsModel(
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
  /// Parses the string and returns the resulting Json object as [ReturnOrderDetailsModel].
  factory ReturnOrderDetailsModel.fromJson(String data) {
    return ReturnOrderDetailsModel.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [ReturnOrderDetailsModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
