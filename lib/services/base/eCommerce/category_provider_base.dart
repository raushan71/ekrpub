import 'package:dio/dio.dart';

abstract class CategoryProviderBase {
  Future<Response> getCategories();
  Future<Response> getSubCategories({required int id});
}
