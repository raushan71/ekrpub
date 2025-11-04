import 'package:dio/dio.dart';
import 'package:ekray/models/eCommerce/address/add_address.dart';

abstract class AddressProviderBase {
  Future<Response> getAddress();
  Future<Response> addAddress({required AddAddress addAddress});
  Future<Response> updateAddress({required AddAddress addAddress});
  Future<Response> deleteAddress({required int addressId});
}
