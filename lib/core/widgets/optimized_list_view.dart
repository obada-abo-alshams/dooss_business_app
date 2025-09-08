import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// Optimized ListView with better performance characteristics
class OptimizedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final ScrollController? controller;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Use ListView.separated if separator is provided
    if (separatorBuilder != null) {
      return ListView.separated(
        controller: controller,
        scrollDirection: scrollDirection,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        cacheExtent: cacheExtent,
        // semanticChildCount: semanticChildCount ?? items.length,
        dragStartBehavior: dragStartBehavior,
        itemCount: items.length,
        itemBuilder: (context, index) => _OptimizedListItem<T>(
          key: ValueKey('${T.toString()}_$index'),
          item: items[index],
          index: index,
          builder: itemBuilder,
        ),
        separatorBuilder: separatorBuilder!,
      );
    }

    // Use regular ListView.builder
    return ListView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      // semanticChildCount: semanticChildCount ?? items.length,
      dragStartBehavior: dragStartBehavior,
      itemCount: items.length,
      itemBuilder: (context, index) => _OptimizedListItem<T>(
        key: ValueKey('${T.toString()}_$index'),
        item: items[index],
        index: index,
        builder: itemBuilder,
      ),
    );
  }
}

/// Optimized list item with repaint boundary and key management
class _OptimizedListItem<T> extends StatelessWidget {
  final T item;
  final int index;
  final Widget Function(BuildContext context, T item, int index) builder;

  const _OptimizedListItem({
    super.key,
    required this.item,
    required this.index,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: builder(context, item, index),
    );
  }
}

/// Optimized GridView with better performance characteristics
class OptimizedGridView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final SliverGridDelegate gridDelegate;
  final ScrollController? controller;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;

  const OptimizedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.gridDelegate,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      // semanticChildCount: semanticChildCount ?? items.length,
      dragStartBehavior: dragStartBehavior,
      gridDelegate: gridDelegate,
      itemCount: items.length,
      itemBuilder: (context, index) => _OptimizedListItem<T>(
        key: ValueKey('${T.toString()}_$index'),
        item: items[index],
        index: index,
        builder: itemBuilder,
      ),
    );
  }
}