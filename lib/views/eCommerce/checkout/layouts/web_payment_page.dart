// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekray/components/ecommerce/custom_dialog.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/controllers/eCommerce/order/order_controller.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/routes.dart';
import 'package:ekray/utils/context_less_navigation.dart';

class WebPayementScreen extends ConsumerStatefulWidget {
  final WebPaymentScreenArg webPaymentScreenAr;
  const WebPayementScreen({
    super.key,
    required this.webPaymentScreenAr,
  });

  @override
  ConsumerState<WebPayementScreen> createState() => _WebPayementScreenState();
}

class _WebPayementScreenState extends ConsumerState<WebPayementScreen> {
  late InAppWebViewController _webViewController;
  bool _isLoading = true;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              _buildRouting();
              _buildPaymentFailedDialog();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest:
                  URLRequest(url: WebUri(widget.webPaymentScreenAr.paymentUrl)),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                String onLoadUrl = url.toString();
                if (onLoadUrl.trim().contains('/payment/success')) {
                  _buildRouting();
                  _buildPaymentDoneDialog();
                } else if (onLoadUrl.toString().contains('payment/fail')) {
                  _buildRouting();
                  _buildPaymentFailedDialog();
                } else if (onLoadUrl.toString().contains('payment/cancel')) {
                  _buildRouting();
                  _buildPaymentFailedDialog();
                }
                setState(() {
                  _isLoading = true;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  _buildRouting() {
    if (widget.webPaymentScreenAr.orderId != null) {
      final data = ref.refresh(
          orderDetailsControllerProvider(widget.webPaymentScreenAr.orderId!));
      debugPrint(data.toString());
      context.nav.pop();
    } else {
      context.nav.pushNamedAndRemoveUntil(
          Routes.getCoreRouteName(AppConstants.appServiceName),
          (route) => false);
    }
  }

  _buildPaymentDoneDialog() {
    return showDialog(
      context: ContextLess.context,
      builder: (_) => CustomDialog(
        title: S.of(context).paymentSuccess,
        des: S.of(context).paymentSuccessDes,
        assetName: Assets.svg.doneIcon,
        buttonText: S.of(context).close,
        callback: () {
          ContextLess.context.nav.pop();
        },
      ),
    );
  }

  _buildPaymentFailedDialog() {
    return showDialog(
      context: ContextLess.context,
      builder: (_) => CustomDialog(
        title: S.of(context).paymentFailed,
        des: S.of(context).paymentFailedDes,
        assetName: Assets.svg.cancelIcon,
        buttonText: S.of(context).close,
        callback: () {
          ContextLess.context.nav.pop();
        },
      ),
    );
  }
}

class WebPaymentScreenArg {
  final int? orderId;
  final String paymentUrl;
  WebPaymentScreenArg({
    this.orderId,
    required this.paymentUrl,
  });
}
