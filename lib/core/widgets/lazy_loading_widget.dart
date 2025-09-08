import 'package:flutter/material.dart';

/// A widget that loads its child lazily when it becomes visible
class LazyLoadingWidget extends StatefulWidget {
  final Widget Function() builder;
  final Widget? placeholder;
  final double visibilityThreshold;

  const LazyLoadingWidget({
    super.key,
    required this.builder,
    this.placeholder,
    this.visibilityThreshold = 0.1,
  });

  @override
  State<LazyLoadingWidget> createState() => _LazyLoadingWidgetState();
}

class _LazyLoadingWidgetState extends State<LazyLoadingWidget> {
  bool _isVisible = false;
  Widget? _child;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? UniqueKey(),
      onVisibilityChanged: (info) {
        if (!_isVisible && info.visibleFraction >= widget.visibilityThreshold) {
          setState(() {
            _isVisible = true;
            _child = widget.builder();
          });
        }
      },
      child: _isVisible 
          ? _child! 
          : widget.placeholder ?? const SizedBox.shrink(),
    );
  }
}

/// Custom visibility detector that doesn't require external packages
class VisibilityDetector extends StatefulWidget {
  final Key key;
  final Widget child;
  final void Function(VisibilityInfo) onVisibilityChanged;

  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      final size = renderObject.size;
      final position = renderObject.localToGlobal(Offset.zero);
      final screenSize = MediaQuery.of(context).size;
      
      // Calculate visibility fraction
      final visibleArea = _calculateVisibleArea(position, size, screenSize);
      final totalArea = size.width * size.height;
      final visibleFraction = totalArea > 0 ? visibleArea / totalArea : 0.0;
      
      widget.onVisibilityChanged(VisibilityInfo(visibleFraction));
    }
  }

  double _calculateVisibleArea(Offset position, Size size, Size screenSize) {
    final left = position.dx.clamp(0.0, screenSize.width);
    final top = position.dy.clamp(0.0, screenSize.height);
    final right = (position.dx + size.width).clamp(0.0, screenSize.width);
    final bottom = (position.dy + size.height).clamp(0.0, screenSize.height);
    
    final visibleWidth = (right - left).clamp(0.0, double.infinity);
    final visibleHeight = (bottom - top).clamp(0.0, double.infinity);
    
    return visibleWidth * visibleHeight;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class VisibilityInfo {
  final double visibleFraction;
  
  const VisibilityInfo(this.visibleFraction);
}