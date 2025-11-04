import 'package:dio/dio.dart';

abstract class BlogServiceBase {
  Future<Response> getBlogs(
      {required int page, required int perPage, int? categoryId});

  Future<Response> getBlogDetails({required int blogId});
}
