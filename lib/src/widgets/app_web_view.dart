import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_core/src/theme/app_colors.dart';
import 'package:flutter_clean_core/src/widgets/app_loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Premium custom WebView page that manages:
/// - JavaScript enabled by default with Navigation delegation.
/// - Top-positioned linear progress animation bar matching core colors.
/// - Integrated PopScope to intercept device back gestures inside WebView navigation history.
/// - Header actions to Copy URL, Reload Page, and navigate back.
class AppWebView extends StatefulWidget {
  const AppWebView({
    required this.url,
    required this.title,
    super.key,
    this.showAppBar = true,
    this.onPageFinished,
    this.onPageStarted,
    this.onProgress,
  });

  final String url;
  final String title;
  final bool showAppBar;
  final ValueChanged<String>? onPageFinished;
  final ValueChanged<String>? onPageStarted;
  final ValueChanged<int>? onProgress;

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
            widget.onProgress?.call(progress);
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            widget.onPageStarted?.call(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            widget.onPageFinished?.call(url);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _handleBack(BuildContext context) async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack(context);
      },
      child: Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: Text(widget.title),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => _handleBack(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () => _controller.reload(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: () async {
                      final currentUrl = await _controller.currentUrl();
                      if (currentUrl != null) {
                        await Clipboard.setData(
                          ClipboardData(text: currentUrl),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Link copied to clipboard!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              )
            : null,
        body: Column(
          children: [
            if (_isLoading)
              LinearProgressIndicator(
                value: _loadingProgress / 100.0,
                backgroundColor: AppColors.grey100,
                color: AppColors.primary,
                minHeight: 3,
              ),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading && _loadingProgress < 10)
                    const AppLoading.fullScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
