import 'package:dio/dio.dart';

abstract class CountryProviderBase {
  Future<Response> getAllCountry();
}
