import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/models/common/all_country_model/all_country_model.dart';
import 'package:ekray/services/common/country_service_provider.dart';

class CountryListController extends StateNotifier<AsyncValue<AllCountryModel>> {
  final Ref ref;

  CountryListController(this.ref) : super(const AsyncLoading()) {
    getCountryList();
  }

  Future<void> getCountryList() async {
    try {
      final response = await ref.read(countryServiceProvider).getAllCountry();
      var newData = AllCountryModel.fromMap(response.data);
      state = AsyncData(newData);
    } catch (error) {
      debugPrint(error.toString());
      state = AsyncError(error, StackTrace.current);
    }
    return;
  }
}

final countryListControllerProvider =
    StateNotifierProvider<CountryListController, AsyncValue<AllCountryModel>>(
        (ref) => CountryListController(ref));
