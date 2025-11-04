import 'dart:convert';

import 'package:ekray/models/eCommerce/shop_message_model/datum.dart';

class Data {
  int? total;
  List<ShopMessage>? data;

  Data({this.total, this.data});

  factory Data.fromMap(Map<String, dynamic> data) => Data(
        total: data['total'] as int?,
        data: (data['data'] as List<dynamic>?)
            ?.map((e) => ShopMessage.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'total': total,
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
