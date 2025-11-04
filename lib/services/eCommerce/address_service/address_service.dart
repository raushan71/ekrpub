import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/models/eCommerce/address/add_address.dart';
import 'package:ekray/services/base/eCommerce/address_provider_base.dart';
import 'package:ekray/utils/api_client.dart';

final addressServiceProvider = Provider((ref) => AddressService(ref));

class AddressService implements AddressProviderBase {
  final Ref ref;
  AddressService(this.ref);
  @override
  Future<Response> addAddress({required AddAddress addAddress}) async {
    final response = await ref.read(apiClientProvider).post(
          AppConstants.addAddess,
          data: addAddress.toMap()..remove('id'),
        );
    return response;
  }

  @override
  Future<Response> updateAddress({required AddAddress addAddress}) async {
    final response = await ref.read(apiClientProvider).post(
          "${AppConstants.address}/${addAddress.addressId}/update",
          data: addAddress.toMap()..remove('id'),
        );
    return response;
  }

  @override
  Future<Response> deleteAddress({required int addressId}) async {
    final response = await ref
        .read(apiClientProvider)
        .delete("${AppConstants.address}/$addressId/delete");
    return response;
  }

  @override
  Future<Response> getAddress() async {
    final response =
        await ref.read(apiClientProvider).get(AppConstants.getAddress);
    return response;
  }
}
