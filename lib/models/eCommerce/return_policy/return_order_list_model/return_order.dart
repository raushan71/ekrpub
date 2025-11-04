import 'dart:convert';

class ReturnOrder {
  int? id;
  String? orderId;
  String? reason;
  double? amount;
  String? status;
  String? paymentStatus;
  dynamic rejectNote;
  String? returnDate;
  String? returnAddress;

  ReturnOrder({
    this.id,
    this.orderId,
    this.reason,
    this.amount,
    this.status,
    this.paymentStatus,
    this.rejectNote,
    this.returnDate,
    this.returnAddress,
  });

  factory ReturnOrder.fromMap(Map<String, dynamic> data) => ReturnOrder(
        id: data['id'] as int?,
        orderId: data['order_id'] as String?,
        reason: data['reason'] as String?,
        amount: data['amount'] as double?,
        status: data['status'] as String?,
        paymentStatus: data['payment_status'] as String?,
        rejectNote: data['reject_note'] as dynamic,
        returnDate: data['return_date'] as String?,
        returnAddress: data['return_address'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'order_id': orderId,
        'reason': reason,
        'amount': amount,
        'status': status,
        'payment_status': paymentStatus,
        'reject_note': rejectNote,
        'return_date': returnDate,
        'return_address': returnAddress,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [ReturnOrder].
  factory ReturnOrder.fromJson(String data) {
    return ReturnOrder.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [ReturnOrder] to a JSON string.
  String toJson() => json.encode(toMap());
}
