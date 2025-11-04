import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:ekray/models/eCommerce/address/add_address.dart';
import 'package:ekray/models/eCommerce/category/category.dart';
import 'package:ekray/models/eCommerce/order/order_now_cart_model.dart';
import 'package:ekray/models/eCommerce/shop_message_model/shop.dart';
import 'package:ekray/views/common/authentication/change_password_view.dart';
import 'package:ekray/views/common/authentication/confirm_otp_view.dart';
import 'package:ekray/views/common/authentication/create_new_password_view.dart';
import 'package:ekray/views/common/authentication/layouts/confirm_otp_layout.dart';
import 'package:ekray/views/common/authentication/login_view.dart';
import 'package:ekray/views/common/authentication/recover_password_view.dart';
import 'package:ekray/views/common/authentication/sign_up_view.dart';
import 'package:ekray/views/common/blog/blog_details_view.dart';
import 'package:ekray/views/common/blog/blogs_view.dart';
import 'package:ekray/views/common/language/language_view.dart';
import 'package:ekray/views/common/onboarding/onboarding_view.dart';
import 'package:ekray/views/common/other/privacy_policy_view.dart';
import 'package:ekray/views/common/other/refund_policy_view.dart';
import 'package:ekray/views/common/other/terms_confitions_view.dart';
import 'package:ekray/views/common/splash/splash_view.dart';
import 'package:ekray/views/common/support/supports_view.dart';
import 'package:ekray/views/eCommerce/address/add_update_address_view.dart';
import 'package:ekray/views/eCommerce/categories/categories_view.dart';
import 'package:ekray/views/eCommerce/checkout/checkout_view.dart';
import 'package:ekray/views/eCommerce/checkout/layouts/web_payment_page.dart';
import 'package:ekray/views/eCommerce/dashboard/dashboard_view.dart';
import 'package:ekray/views/eCommerce/favourites/favourites_products_view.dart';
import 'package:ekray/views/eCommerce/home/home_view.dart';
import 'package:ekray/views/eCommerce/home/layouts/flash_sale_details_layout.dart';
import 'package:ekray/views/eCommerce/manage_address/manage_address_view.dart';
import 'package:ekray/views/eCommerce/my_cart/my_cart_view.dart';
import 'package:ekray/views/eCommerce/my_message/my_chat_view.dart';
import 'package:ekray/views/eCommerce/my_message/my_message_view.dart';
import 'package:ekray/views/eCommerce/my_order/my_order_view.dart';
import 'package:ekray/views/eCommerce/notification/notification_view.dart';
import 'package:ekray/views/eCommerce/order_details/order_details_view.dart';
import 'package:ekray/views/eCommerce/order_now/order_now_view.dart';
import 'package:ekray/views/eCommerce/products/product_details_view.dart';
import 'package:ekray/views/eCommerce/products/products_view.dart';
import 'package:ekray/views/eCommerce/profile/profile_view.dart';
import 'package:ekray/views/eCommerce/return_order/layouts/return_order_list_layout.dart';
import 'package:ekray/views/eCommerce/return_order/return_order_details_view.dart';
import 'package:ekray/views/eCommerce/return_order/return_policy_product_view.dart';
import 'package:ekray/views/eCommerce/shops/shop_view.dart';
import 'package:ekray/views/eCommerce/shops/shops_view.dart';
import 'package:ekray/views/food/dashboard/dashboard_view.dart';
import 'package:ekray/views/food/home/home_view.dart';
import 'package:ekray/views/grocery/dashboard/dashboard_view.dart';
import 'package:ekray/views/grocery/home/home_view.dart';
import 'package:ekray/views/pharmacy/dashboard/dashboard_view.dart';
import 'package:ekray/views/pharmacy/home/home_view.dart';

import 'views/common/currency/currency_view.dart';

class Routes {
  Routes._();

  // common routes name
  static const String splash = '/';
  static const String onbarding = '/onboarding';
  static const String login = '/login';
  static const String singUp = '/singUp';
  static const String confirmOTP = '/confirmOTP';
  static const String recoverPassword = '/recoverPassword';
  static const String createPassword = '/createPassword';
  static const String changePassword = '/changePassword';
  static const String webPaymentScreen = '/webPayementScreen';
  static const String supportView = '/supportView';
  static const String refundPolicyView = '/refundPolicyView';
  static const String termsAndConditionsView = '/termsAndConditionsView';
  static const String privacyPolicyView = '/privacyPolicyView';
  static const String languageView = '/languageView';
  static const String bogs = '/bogs';
  static const String blogDetails = '/blogDetails';
  static const String currencyView = '/currencyView';
  static const String returnPolicyProductView = '/returnPolicyProductView';
  static const String returnOrderListView = '/returnOrderListView';
  static const String returnOrderDetails = '/returnOrderDetails';

  // dynamic routes name
  static const String core = '/core';
  static const String homeView = '/homeView';
  static const String categoriesView = '/categoriesView';
  static const String productsView = '/productsView';
  static const String productDetailsView = '/productDetailsView';
  static const String shopView = '/shopView';
  static const String shopsView = '/shopsView';
  static const String shopProductsView = '/shopProductsView';
  static const String myCartView = '/myCartView';
  static const String checkoutView = '/checkoutView';
  static const String addUpdateAddressView = '/addUpdateAddressView';
  static const String profileView = '/profileView';
  static const String myOrderView = '/myOrderView';
  static const String myMessageView = '/myMessageView';
  static const String myChatView = '/myChatView';
  static const String orderDetailsView = '/orderDetailsView';
  static const String manageAddressView = '/manageAddressView';
  static const String favouritesProductView = '/favouritesProductView';
  static const String orderNowView = '/orderNowView';
  static const String notificationView = '/notificationView';
  static const String flashSaleDetails = '/flashSaleDetails';

  static String getCoreRouteName(String service) {
    return '$service$core';
  }

  static String getHomeViewRouteName(String service) {
    return '$service$homeView';
  }

  static String getCategoriesViewRouteName(String service) {
    return '$service$categoriesView';
  }

  static String getProductsViewRouteName(String service) {
    return '$service$productsView';
  }

  static String getProductDetailsRouteName(String service) {
    return '$service$productDetailsView';
  }

  static String getShopViewRouteName(String service) {
    return '$service$shopView';
  }

  static String getShopsViewRouteName(String service) {
    return '$service$shopsView';
  }

  static String getShopProductsViewRouteName(String service) {
    return '$service$shopProductsView';
  }

  static String getMyCartViewRouteName(String service) {
    return '$service$myCartView';
  }

  static String getCheckoutViewRouteName(String service) {
    return '$service$checkoutView';
  }

  static String getAddUpdateAddressViewRouteName(String service) {
    return '$service$addUpdateAddressView';
  }

  static String getProfileViewRouteName(String service) {
    return '$service$profileView';
  }

  static String getMyOrderViewRouteName(String service) {
    return '$service$myOrderView';
  }

  static String getMyMessageViewRouteName(String service) {
    return '$service$myMessageView';
  }

  static String getChatViewRouteName(String service) {
    return '$service$myChatView';
  }

  static String getOrderDetailsViewRouteName(String service) {
    return '$service$orderDetailsView';
  }

  static String getManageAddressViewRouteName(String service) {
    return '$service$manageAddressView';
  }

  static String getFavouritesProductsViewRouteName(String service) {
    return '$service$favouritesProductView';
  }

  static String getOrderNowViewRouteName(String service) {
    return '$service$orderNowView';
  }

  static String getNotificationRouteName(String service) {
    return '$service$notificationView';
  }

  static String getReturnPolicyProductViewRouteName(String service) {
    return '$service$returnPolicyProductView';
  }

  static String getReturnOrderListViewRouteName(String service) {
    return '$service$returnOrderListView';
  }
  static String getReturnOrderDetailsViewRouteName(String service) {
    return '$service$returnOrderDetails';
  }
}

Widget getDashboardView(String serviceName) {
  switch (serviceName) {
    case 'ecommerce':
      return const EcommerceDashboardView();
    case 'food':
      return const FoodDashboardView();
    case 'grocery':
      return const GroceryDashboardView();
    case 'pharmacy':
      return const PharmacyDashboardView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getHomeView(String serviceName) {
  switch (serviceName) {
    case 'ecommerce':
      return const EcommerceHomeView();
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getCategoriesView(String serviceName) {
  switch (serviceName) {
    case 'ecommerce':
      return const EcommerceCategoriesView();
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getProductsView(
    String serviceName,
    int? categoryId,
    String categoryName,
    String? sortType,
    int? subCategoryId,
    String? shopName,
    List<SubCategory> subCategories) {
  switch (serviceName) {
    case 'ecommerce':
      return EcommerceProductsView(
        categoryId: categoryId,
        categoryName: categoryName,
        sortType: sortType,
        subCategoryId: subCategoryId,
        shopName: shopName,
        subCategories: subCategories,
      );
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getProductDetailsView(String serviceName, int productId) {
  switch (serviceName) {
    case 'ecommerce':
      return EcommerceProductDetailsView(
        productId: productId,
      );
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getShopsView(String serviceName) {
  switch (serviceName) {
    case 'ecommerce':
      return const EcommerceShopsView();
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getShopView(String serviceName, int shopId) {
  switch (serviceName) {
    case 'ecommerce':
      return EcommerceShopView(
        shopId: shopId,
      );
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

// Widget getShopProductsView(String serviceName, int shopId, String shopName,
//     int categoryId, List<Category> categories) {
//   switch (serviceName) {
//     case 'ecommerce':
//       return EcommerceShopProductsView(
//         shopId: shopId,
//         shopName: shopName,
//         categoryId: categoryId,
//         categories: categories,
//       );
//     case 'food':
//       return const FoodHomeView();
//     case 'grocery':
//       return const GroceryHomeView();
//     case 'pharmacy':
//       return const PharmacyHomeView();
//     default:
//       throw Exception('Invalid service name: $serviceName');
//   }
// }

Widget getMyCartView(String serviceName, bool isRoot, bool isBuyNow) {
  switch (serviceName) {
    case 'ecommerce':
      return EcommerceMyCartView(
        isRoot: isRoot,
        isBuyNow: isBuyNow,
      );
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getCheckoutView(
  String serviceName,
  double payableAmount,
  String? couponCode,
  bool? isBuyNow,
) {
  switch (serviceName) {
    case 'ecommerce':
      return EcommerceCheckoutView(
        payableAmount: payableAmount,
        couponCode: couponCode,
        isBuyNow: isBuyNow ?? false,
      );
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getAddUpdateAddressView(String serviceName, AddAddress? address) {
  switch (serviceName) {
    case 'ecommerce':
      return AddUpdateAddressView(
        address: address,
      );
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getProfileView(String serviceName) {
  switch (serviceName) {
    case 'ecommerce':
      return const ProfileView();
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getMyOrderView(String serviceName) {
  switch (serviceName) {
    case 'ecommerce':
      return const MyOrderView();
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getMyMessageView(String serviceName) {
  switch (serviceName) {
    case 'ecommerce':
      return const MyMessageView();
    case 'food':
      return const MyMessageView();
    case 'grocery':
      return const MyMessageView();
    case 'pharmacy':
      return const MyMessageView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getMyChatView(String serviceName, Shop shop) {
  switch (serviceName) {
    case 'ecommerce':
      return MyChatView(
        shop: shop,
      );
    case 'food':
      return MyChatView(
        shop: shop,
      );
    case 'grocery':
      return MyChatView(
        shop: shop,
      );
    case 'pharmacy':
      return MyChatView(
        shop: shop,
      );
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getOrderDetailsView(String serviceName, int orderId) {
  switch (serviceName) {
    case 'ecommerce':
      return OrderDetailsView(
        orderId: orderId,
      );
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}
Widget getReturnOrderDetailsView(String serviceName, int orderId) {
  switch (serviceName) {
    case 'ecommerce':
      return ReturnOrderDetailsView(
        orderId: orderId,
      );
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getManageAddressView(String serviceName) {
  switch (serviceName) {
    case 'ecommerce':
      return const ManageAddressView();
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getFavouritesProductsView(String serviceName) {
  switch (serviceName) {
    case 'ecommerce':
      return const FavouritesProductsView();
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getOrderNowView(
    String serviceName, OrderNowCartModel orderNowCartModel) {
  switch (serviceName) {
    case 'ecommerce':
      return EcommerceOrderNowView(
        orderNowCartModel: orderNowCartModel,
      );
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getNotificationView(String serviceName) {
  switch (serviceName) {
    case 'ecommerce':
      return const NotificationView();
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getReturnPolicyProductView(String serviceName, int orderId) {
  switch (serviceName) {
    case 'ecommerce':
      return ReturnPolicyProductView(orderId: orderId);
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

Widget getReturnOrderListView(
  String serviceName,
) {
  switch (serviceName) {
    case 'ecommerce':
      return ReturnOrderListLayout();
    case 'food':
      return const FoodHomeView();
    case 'grocery':
      return const GroceryHomeView();
    case 'pharmacy':
      return const PharmacyHomeView();
    default:
      throw Exception('Invalid service name: $serviceName');
  }
}

String? getServiceName(RouteSettings settings) {
  if (settings.name != null) {
    List<String> parts = settings.name!.split('/');
    if (parts.length > 1) {
      return parts[0];
    }
  }
  return null;
}

Widget handleCommonRoutes(String? routeName, RouteSettings settings) {
  switch (routeName) {
    case Routes.splash:
      return const SplashView();
    case Routes.onbarding:
      return const OnboardingView();
    case Routes.login:
      return const LoginView();
    case Routes.singUp:
      return const SignUpView();
    case Routes.confirmOTP:
      final ConfirmOTPScreenArguments arguments =
          settings.arguments as ConfirmOTPScreenArguments;
      return ConfirmOTPView(
        arguments: arguments,
      );
    case Routes.recoverPassword:
      final bool isRecoverPassword = settings.arguments as bool;
      return RecoverPasswordView(
        isPasswordRecovery: isRecoverPassword,
      );
    case Routes.createPassword:
      final String forgotPasswordToken = settings.arguments as String;
      return CreateNewPasswordView(
        forgotPasswordToken: forgotPasswordToken,
      );
    case Routes.changePassword:
      return const ChangePasswordView();
    case Routes.webPaymentScreen:
      final WebPaymentScreenArg webPaymentScreenArg =
          settings.arguments as WebPaymentScreenArg;
      return WebPayementScreen(
        webPaymentScreenAr: webPaymentScreenArg,
      );
    case Routes.supportView:
      return const SupportView();
    case Routes.termsAndConditionsView:
      return const TermsAndConditionsView();
    case Routes.refundPolicyView:
      return const RefundPolicyView();
    case Routes.privacyPolicyView:
      return const PrivacyPolicyView();
    case Routes.languageView:
      return const LanguageView();
    case Routes.currencyView:
      return const CurrencyView();
    case Routes.flashSaleDetails:
      return FlashSaleDetailsLayout(
        title: settings.arguments as String,
      );
    case Routes.bogs:
      return const BlogsView();
    case Routes.blogDetails:
      final int blogId = settings.arguments as int;
      return BlogDetailsView(blogId: blogId);

    default:
      throw Exception('Invalid route: $routeName');
  }
}

Route generatedRoutes(RouteSettings settings) {
  final String? serviceName = getServiceName(settings);

  if (serviceName != null &&
      settings.name == Routes.getCoreRouteName(serviceName)) {
    final Widget view = getDashboardView(serviceName);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getHomeViewRouteName(serviceName)) {
    final Widget view = getHomeView(serviceName);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getCategoriesViewRouteName(serviceName)) {
    final Widget view = getCategoriesView(serviceName);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getProductsViewRouteName(serviceName)) {
    final List arguments = settings.arguments as List;
    final int? categoryId = arguments[0];
    final String categoryName = arguments[1];
    final String? sortType = arguments[2];
    final int? subCategoryId = arguments[3];
    final String? shopName = arguments[4];
    final List<SubCategory> subCategories = arguments[5] as List<SubCategory>;
    final Widget view = getProductsView(serviceName, categoryId, categoryName,
        sortType, subCategoryId, shopName, subCategories);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getProductDetailsRouteName(serviceName)) {
    final int productId = settings.arguments as int;
    final Widget view = getProductDetailsView(serviceName, productId);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getShopViewRouteName(serviceName)) {
    final shopId = settings.arguments as int;
    final Widget view = getShopView(serviceName, shopId);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getShopsViewRouteName(serviceName)) {
    final Widget view = getShopsView(serviceName);
    return go(view, settings);
  }
  // else if (serviceName != null &&
  //     settings.name == Routes.getShopProductsViewRouteName(serviceName)) {
  //   final List arguments = settings.arguments as List;
  //   final int shopId = arguments[0];
  //   final int categoryId = arguments[1];
  //   final List<Category> categories = arguments[2];
  //   final String shopName = arguments[3];
  //   // final Widget view = getShopProductsView(
  //   //     serviceName, shopId, shopName, categoryId, categories);
  //   // return go(view, settings);
  // }
  else if (serviceName != null &&
      settings.name == Routes.getMyCartViewRouteName(serviceName)) {
    final List arg = settings.arguments as List;
    final bool isRoot = arg[0] as bool;
    final bool isBuyNow = arg[1] as bool;
    final Widget view = getMyCartView(serviceName, isRoot, isBuyNow);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getCheckoutViewRouteName(serviceName)) {
    final List arg = settings.arguments as List;

    final double payableAmount = arg[0];
    final String? couponCode = arg[1];
    final bool? isBuyNow = arg[2];
    final Widget view = getCheckoutView(
      serviceName,
      payableAmount,
      couponCode,
      isBuyNow,
    );
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getAddUpdateAddressViewRouteName(serviceName)) {
    final AddAddress? address = settings.arguments as AddAddress?;
    final Widget view = getAddUpdateAddressView(serviceName, address);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getProfileViewRouteName(serviceName)) {
    final Widget view = getProfileView(serviceName);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getMyOrderViewRouteName(serviceName)) {
    final Widget view = getMyOrderView(serviceName);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getMyMessageViewRouteName(serviceName)) {
    final Widget view = getMyMessageView(serviceName);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getChatViewRouteName(serviceName)) {
    final Shop shop = settings.arguments as Shop;
    final Widget view = getMyChatView(serviceName, shop);
    return go(view, settings);
  } 
  else if (serviceName != null &&
      settings.name == Routes.getOrderDetailsViewRouteName(serviceName)) {
    final int orderId = settings.arguments as int;
    final Widget view = getOrderDetailsView(serviceName, orderId);
    return go(view, settings);
  } 
  else if (serviceName != null &&
      settings.name == Routes.getManageAddressViewRouteName(serviceName)) {
    final Widget view = getManageAddressView(serviceName);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getFavouritesProductsViewRouteName(serviceName)) {
    final Widget view = getFavouritesProductsView(serviceName);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getOrderNowViewRouteName(serviceName)) {
    final OrderNowCartModel orderNowCartModel =
        settings.arguments as OrderNowCartModel;
    final Widget view = getOrderNowView(serviceName, orderNowCartModel);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getNotificationRouteName(serviceName)) {
    final Widget view = getNotificationView(serviceName);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name ==
          Routes.getReturnPolicyProductViewRouteName(serviceName)) {
    final int orderId = settings.arguments as int;
    final Widget view = getReturnPolicyProductView(serviceName, orderId);
    return go(view, settings);
  } else if (serviceName != null &&
      settings.name == Routes.getReturnOrderListViewRouteName(serviceName)) {
    final Widget view = getReturnOrderListView(serviceName);
    return go(view, settings);
  } 
   else if (serviceName != null &&
      settings.name == Routes.getReturnOrderDetailsViewRouteName(serviceName)) {
    final int orderId = settings.arguments as int;
    final Widget view = getReturnOrderDetailsView(serviceName, orderId);
    return go(view, settings);
  } 
  
   else {
    final Widget view = handleCommonRoutes(settings.name, settings);
    return go(view, settings);
  }
}

PageTransition<dynamic> go(Widget view, RouteSettings settings) {
  debugPrint("Route Name:  ${settings.name}");
  return PageTransition(
    child: view,
    type: PageTransitionType.theme,
    settings: settings,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 300),
  );
}
