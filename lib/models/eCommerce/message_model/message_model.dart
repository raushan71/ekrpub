import 'dart:convert';

import 'data.dart';

class MessageModel {
  String? message;
  Data? data;

  MessageModel({this.message, this.data});

  factory MessageModel.fromMap(Map<String, dynamic> data) => MessageModel(
        message: data['message'] as String?,
        data: data['data'] == null
            ? null
            : Data.fromMap(data['data'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'message': message,
        'data': data?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [MessageModel].
  factory MessageModel.fromJson(String data) {
    return MessageModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [MessageModel] to a JSON string.
  String toJson() => json.encode(toMap());
}
