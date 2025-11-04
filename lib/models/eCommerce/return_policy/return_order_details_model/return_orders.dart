import 'dart:convert';

import 'return_order_product.dart';

class ReturnOrders {
  int? id;
  String? orderId;
  String? reason;
  double? amount;
  String? status;
  String? paymentStatus;
  String? shopName;
  String? shopLogo;
  double? shopRating;
  dynamic rejectNote;
  String? returnDate;
  String? returnAddress;
  String? customerName;
  String? customerPhone;
  String? customerEmail;
  List<ReturnOrderProduct>? returnOrderProducts;

  ReturnOrders({
    this.id,
    this.orderId,
    this.reason,
    this.amount,
    this.status,
    this.paymentStatus,
    this.shopName,
    this.shopLogo,
    this.shopRating,
    this.rejectNote,
    this.returnDate,
    this.returnAddress,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.returnOrderProducts,
  });

  factory ReturnOrders.fromMap(Map<String, dynamic> data) => ReturnOrders(
        id: data['id'] as int?,
        orderId: data['order_id'] as String?,
        reason: data['reason'] as String?,
        amount: data['amount'] as double?,
        status: data['status'] as String?,
        paymentStatus: data['payment_status'] as String?,
        shopName: data['shop_name'] as String?,
        shopLogo: data['shop_logo'] as String?,
        shopRating: data['shop_rating'] as double?,
        rejectNote: data['reject_note'] as dynamic,
        returnDate: data['return_date'] as String?,
        returnAddress: data['return_address'] as String?,
        customerName: data['customer_name'] as String?,
        customerPhone: data['customer_phone'] as String?,
        customerEmail: data['customer_email'] as String?,
        returnOrderProducts: (data['return_order_products'] as List<dynamic>?)
            ?.map((e) => ReturnOrderProduct.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'order_id': orderId,
        'reason': reason,
        'amount': amount,
        'status': status,
        'payment_status': paymentStatus,
        'shop_name': shopName,
        'shop_logo': shopLogo,
        'shop_rating': shopRating,
        'reject_note': rejectNote,
        'return_date': returnDate,
        'return_address': returnAddress,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_email': customerEmail,
        'return_order_products':
            returnOrderProducts?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [ReturnOrders].
  factory ReturnOrders.fromJson(String data) {
    return ReturnOrders.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [ReturnOrders] to a JSON string.
  String toJson() => json.encode(toMap());
}
