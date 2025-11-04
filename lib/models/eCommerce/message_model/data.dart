import 'dart:convert';

import 'package:ekray/models/eCommerce/message_model/messages.dart';

class Data {
  List<Messages>? data;

  Data({this.data});

  factory Data.fromMap(Map<String, dynamic> data) => Data(
        data: (data['data'] as List<dynamic>?)
            ?.map((e) => Messages.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'data': data?.map((e) => e.toMap()).toList(),
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
