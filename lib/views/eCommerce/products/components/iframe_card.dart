import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IframeCard extends StatefulWidget {
  final String iframeUrl;
  const IframeCard({
    super.key,
    required this.iframeUrl,
  });

  @override
  State<IframeCard> createState() => _IframeCardState();
}

class _IframeCardState extends State<IframeCard> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('Loading progress: $progress%');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('HTTP error: ${error.response}');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web resource error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('Blocked navigation to: ${request.url}');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(widget.iframeUrl);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
