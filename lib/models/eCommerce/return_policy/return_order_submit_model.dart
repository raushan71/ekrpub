// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class ReturnOrderSubmitModel {
  final int orderId;
  final String reason;
  final String retrunAddress;
  final String bankAccountNo;
  final List<int> productIds;
  ReturnOrderSubmitModel({
    required this.orderId,
    required this.reason,
    required this.retrunAddress,
    required this.bankAccountNo,
    required this.productIds,
  });

  ReturnOrderSubmitModel copyWith({
    int? orderId,
    String? reason,
    String? retrunAddress,
    String? bankAccountNo,
    List<int>? productIds,
  }) {
    return ReturnOrderSubmitModel(
      orderId: orderId ?? this.orderId,
      reason: reason ?? this.reason,
      retrunAddress: retrunAddress ?? this.retrunAddress,
      bankAccountNo: bankAccountNo ?? this.bankAccountNo,
      productIds: productIds ?? this.productIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'order_id': orderId,
      'reason': reason,
      'return_address': retrunAddress,
      'bank_account_number': bankAccountNo,
      'product_ids': productIds,
    };
  }

  factory ReturnOrderSubmitModel.fromMap(Map<String, dynamic> map) {
    return ReturnOrderSubmitModel(
        orderId: map['orderId'] as int,
        reason: map['reason'] as String,
        retrunAddress: map['retrunAddress'] as String,
        bankAccountNo: map['bankAccountNo'] as String,
        productIds: List<int>.from(
          (map['productIds'] as List<int>),
        ));
  }

  factory ReturnOrderSubmitModel.fromJson(String source) =>
      ReturnOrderSubmitModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ReturnOrderSubmitModel(orderId: $orderId, reason: $reason, retrunAddress: $retrunAddress, bankAccountNo: $bankAccountNo, productIds: $productIds)';
  }

  @override
  bool operator ==(covariant ReturnOrderSubmitModel other) {
    if (identical(this, other)) return true;

    return other.orderId == orderId &&
        other.reason == reason &&
        other.retrunAddress == retrunAddress &&
        other.bankAccountNo == bankAccountNo &&
        listEquals(other.productIds, productIds);
  }

  @override
  int get hashCode {
    return orderId.hashCode ^
        reason.hashCode ^
        retrunAddress.hashCode ^
        bankAccountNo.hashCode ^
        productIds.hashCode;
  }
}
