import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/services/base/eCommerce/category_provider_base.dart';
import 'package:ekray/utils/api_client.dart';

class CategoryService implements CategoryProviderBase {
  final Ref ref;
  CategoryService(this.ref);
  @override
  Future<Response> getCategories() async {
    final response =
        await ref.read(apiClientProvider).get(AppConstants.getCategories);
    return response;
  }

  @override
  Future<Response> getSubCategories({required int id}) {
    final response = ref
        .read(apiClientProvider)
        .get(AppConstants.getSubCategories, query: {'category_id': id});
    return response;
  }
}

final categoryServiceProvider = Provider((ref) => CategoryService(ref));
