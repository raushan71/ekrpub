import 'dart:convert';

import 'return_orders.dart';

class Data {
  ReturnOrders? returnOrders;

  Data({this.returnOrders});

  factory Data.fromMap(Map<String, dynamic> data) => Data(
        returnOrders: data['returnOrders'] == null
            ? null
            : ReturnOrders.fromMap(
                data['returnOrders'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'returnOrders': returnOrders?.toMap(),
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
