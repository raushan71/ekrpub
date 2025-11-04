import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/models/common/master_model.dart';
import 'package:ekray/services/common/master_service_provider.dart';

class MasterController extends StateNotifier<bool> {
  final Ref ref;

  MasterController(this.ref) : super(false) {
    _masterModel = MasterModel.empty();
  }

  late MasterModel _masterModel;
  MasterModel get materModel => _masterModel;

  Future<MasterModel?> getMasterData() async {
    try {
      final response =
          await ref.read(masterServiceProvider).getMasterSettings();
      _masterModel = MasterModel.fromJson(response.data);

      ref
          .read(currencyProvider.notifier)
          .updateCurrency(_masterModel.data.currency);
      return _masterModel;
    } catch (error) {
      debugPrint(error.toString());
    }
    return null;
  }
}

final masterControllerProvider = StateNotifierProvider<MasterController, bool>(
    (ref) => MasterController(ref));

class CurrencyStateNotifier extends StateNotifier<Currency> {
  CurrencyStateNotifier() : super(Currency.empty());

  void updateCurrency(Currency currency) {
    state = currency;
  }
}

final currencyProvider = StateNotifierProvider<CurrencyStateNotifier, Currency>(
    (ref) => CurrencyStateNotifier());
