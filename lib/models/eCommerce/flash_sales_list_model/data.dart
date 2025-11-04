import 'dart:convert';

import 'running_flash_sale.dart';

class Data {
  dynamic incomingFlashSale;
  RunningFlashSale? runningFlashSale;

  Data({this.incomingFlashSale, this.runningFlashSale});

  factory Data.fromMap(Map<String, dynamic> data) => Data(
        incomingFlashSale: data['incoming_flash_sale'] as dynamic,
        runningFlashSale: data['running_flash_sale'] == null
            ? null
            : RunningFlashSale.fromMap(
                data['running_flash_sale'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'incoming_flash_sale': incomingFlashSale,
        'running_flash_sale': runningFlashSale?.toMap(),
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
