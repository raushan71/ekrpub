import 'dart:convert';

class RunningFlashSale {
  int? id;
  String? name;
  String? thumbnail;
  String? startDate;
  String? endDate;
  dynamic products;

  RunningFlashSale({
    this.id,
    this.name,
    this.thumbnail,
    this.startDate,
    this.endDate,
    this.products,
  });

  factory RunningFlashSale.fromMap(Map<String, dynamic> data) {
    return RunningFlashSale(
      id: data['id'] as int?,
      name: data['name'] as String?,
      thumbnail: data['thumbnail'] as String?,
      startDate: data['start_date'] as String?,
      endDate: data['end_date'] as String?,
      products: data['products'] as dynamic,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'thumbnail': thumbnail,
        'start_date': startDate,
        'end_date': endDate,
        'products': products,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [RunningFlashSale].
  factory RunningFlashSale.fromJson(String data) {
    return RunningFlashSale.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [RunningFlashSale] to a JSON string.
  String toJson() => json.encode(toMap());
}
