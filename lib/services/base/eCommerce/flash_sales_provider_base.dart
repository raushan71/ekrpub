import 'package:dio/dio.dart';

abstract class FlashSalesProviderBase {
  Future<Response> getFlashSalesList();
  Future<Response> getFlashSalesDetail({required int id});
}
