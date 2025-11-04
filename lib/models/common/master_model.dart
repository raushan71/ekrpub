class MasterModel {
  MasterModel({
    required this.message,
    required this.data,
  });
  late final String message;
  late final Data data;
  MasterModel.empty() {
    message = '';
    data = Data.empty();
  }
  MasterModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final jsonData = <String, dynamic>{};
    jsonData['message'] = message;
    jsonData['data'] = data.toJson();
    return jsonData;
  }
}

class Data {
  Data({
    required this.currency,
    required this.paymentGateways,
    required this.isMultiVendor,
  });
  late final Currency currency;
  late final List<Currencies> currencies;
  late final List<PaymentGateways> paymentGateways;
  late final bool isMultiVendor;
  late final String appLogo;
  late final String appName;
  late final String splashLogo;
  late final bool cashOnDelivery;
  late final bool onlinePayment;
  late final bool registerOtpVerify;
  late final bool orderPlaceAccountVerify;
  late final String registerOtpType;
  late final String forgotOtpType;

  late final ThemeColors themeColors;
  late final bool phoneRequired;
  late final int phoneMinLength;
  late final int phoneMaxLength;
  Data.empty() {
    currency = Currency.empty();
    currencies = [];
    paymentGateways = [];
    isMultiVendor = false;
    appLogo = '';
    appName = '';
    splashLogo = '';
    registerOtpType = '';
    registerOtpVerify = false;
    orderPlaceAccountVerify = false;
    forgotOtpType = '';
    themeColors = ThemeColors.empty();
    phoneRequired = false;
    phoneMinLength = 0;
    phoneMaxLength = 0;
  }
  Data.fromJson(Map<String, dynamic> json) {
    currency = Currency.fromJson(json['currency']);
    currencies = List.from(json['currencies'])
        .map((e) => Currencies.fromJson(e))
        .toList();
    paymentGateways = List.from(json['payment_gateways'])
        .map((e) => PaymentGateways.fromJson(e))
        .toList();

    isMultiVendor = json['multi_vendor'];
    appLogo = json['app_logo'];
    appName = json['app_name'];
    splashLogo = json['web_logo'];
    cashOnDelivery = json['cash_on_delivery'];
    onlinePayment = json['online_payment'];
    registerOtpType = json['register_otp_type'];
    orderPlaceAccountVerify = json['order_place_account_verify'];
    registerOtpVerify = json['register_otp_verify'];
    forgotOtpType = json['forgot_otp_type'];
    themeColors = ThemeColors.fromJson(json['theme_colors']);
    phoneRequired = json['phone_required'];
    phoneMinLength = json['phone_min_length'];
    phoneMaxLength = json['phone_max_length'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['currency'] = currency.toJson();
    data['multi_vendor'] = isMultiVendor;
    data['app_logo'] = appLogo;
    data['theme_colors'] = themeColors.toJson();
    data['app_name'] = appName;
    data['web_logo'] = splashLogo;
    data['payment_gateways'] = paymentGateways.map((e) => e.toJson()).toList();
    return data;
  }
}

class Currency {
  Currency({
    required this.name,
    required this.symbol,
    required this.position,
    required this.rate,
  });
  late final String name;
  late final String symbol;
  late final double rate;
  late final String position;

  Currency.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    symbol = json['symbol'];
    rate = json['rate'];
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['symbol'] = symbol;
    data['position'] = position;
    return data;
  }

  // empty
  Currency.empty() {
    name = '';
    symbol = '';
    rate = 0.0;
    position = '';
  }
}

class PaymentGateways {
  PaymentGateways({
    required this.id,
    required this.title,
    required this.name,
    required this.logo,
    required this.isActive,
  });
  late final int id;
  late final String title;
  late final String name;
  late final String logo;
  late final bool isActive;

  PaymentGateways.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    name = json['name'];
    logo = json['logo'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['name'] = name;
    data['logo'] = logo;
    data['is_active'] = isActive;
    return data;
  }
}

class ThemeColors {
  final String primaryColor;

  ThemeColors({required this.primaryColor});

  ThemeColors.empty() : primaryColor = '';

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['primary_color'] = primaryColor;
    return data;
  }

  factory ThemeColors.fromJson(Map<String, dynamic> json) {
    return ThemeColors(
      primaryColor: json['primary'],
    );
  }
}

class Currencies {
  Currencies({
    required this.id,
    required this.name,
    required this.rate,
    required this.symbol,
    required this.isDefault,
  });
  late final int id;
  late final String name;
  late final String symbol;
  late final double rate;
  late final bool isDefault;

  Currencies.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    rate = json['rate_from_default'];
    symbol = json['symbol'];

    isDefault = json['is_default'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['symbol'] = symbol;

    return data;
  }
}
