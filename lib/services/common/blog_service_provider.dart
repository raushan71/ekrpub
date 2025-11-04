import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_constants.dart';
import '../../utils/api_client.dart';
import '../base/eCommerce/blog_service_base.dart';

class BlogsServiceProvider extends BlogServiceBase {
  final Ref ref;
  BlogsServiceProvider(this.ref);
  @override
  Future<Response> getBlogs(
      {required int page, required int perPage, int? categoryId}) async {
    final response = await ref.read(apiClientProvider).get(
      AppConstants.blogs,
      query: {
        'page': page,
        'per_page': perPage,
        'category_id': categoryId,
      },
    );
    return response;
  }

  @override
  Future<Response> getBlogDetails({required int blogId}) async {
    final response = await ref.read(apiClientProvider).get(
          "${AppConstants.blogDetails}/$blogId/details",
        );
    return response;
  }
}

final blogServiceProvider = Provider((ref) => BlogsServiceProvider(ref));
