import 'package:flutter/material.dart';
import 'package:flutter_clean_core/src/widgets/app_empty_widget.dart';
import 'package:flutter_clean_core/src/widgets/app_error_widget.dart';
import 'package:flutter_clean_core/src/widgets/app_loading.dart';

/// Premium generic ListView that automatically handles:
/// - Pull-to-refresh (using standard RefreshIndicator matching core styles).
/// - Infinite scroll pagination / Load More.
/// - Integrated Loading, Empty, and Error states natively.
class AppRefreshListView<T> extends StatefulWidget {
  const AppRefreshListView({
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    super.key,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.onRetry,
    this.emptyMessage = 'No items found',
    this.padding,
    this.separator,
  });

  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final VoidCallback? onRetry;
  final String emptyMessage;
  final EdgeInsetsGeometry? padding;
  final Widget? separator;

  @override
  State<AppRefreshListView<T>> createState() => _AppRefreshListViewState<T>();
}

class _AppRefreshListViewState<T> extends State<AppRefreshListView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore || widget.isLoading) return;

    const threshold = 200.0;
    if (_scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <=
        threshold) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.items.isEmpty) {
      return const AppLoading();
    }

    if (widget.error != null && widget.items.isEmpty) {
      return AppErrorWidget(
        message: widget.error!,
        onRetry: widget.onRetry,
      );
    }

    if (widget.items.isEmpty) {
      return AppEmptyWidget(
        message: widget.emptyMessage,
        onAction: widget.onRefresh,
        actionText: 'Refresh',
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: widget.padding ?? const EdgeInsets.all(16),
        itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) =>
            widget.separator ?? const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index < widget.items.length) {
            return widget.itemBuilder(context, index, widget.items[index]);
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: AppLoading(size: 28, strokeWidth: 3),
            );
          }
        },
      ),
    );
  }
}
