import 'dart:math';
import 'package:flutter/material.dart';

enum LoadingType { circular, linear, dots, spinner }

enum LoadingSize { small, medium, large }

class LoadingData extends StatefulWidget {
  final String? message;
  final LoadingType type;
  final LoadingSize size;
  final Color? color;
  final Color? backgroundColor;
  final double? strokeWidth;
  final bool showMessage;
  final TextStyle? messageStyle;
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool overlay;
  final Color? overlayColor;
  final double? progress;

  const LoadingData({
    super.key,
    this.message,
    this.type = LoadingType.circular,
    this.size = LoadingSize.medium,
    this.color,
    this.backgroundColor,
    this.strokeWidth,
    this.showMessage = true,
    this.messageStyle,
    this.padding,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.overlay = false,
    this.overlayColor,
    this.progress,
  });

  @override
  State<LoadingData> createState() => _LoadingDataState();
}

class _LoadingDataState extends State<LoadingData> with TickerProviderStateMixin {
  late AnimationController _dotsController;
  late AnimationController _spinnerController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..repeat();
    _spinnerController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)..repeat();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _spinnerController.dispose();
    super.dispose();
  }

  double get _indicatorSize {
    switch (widget.size) {
      case LoadingSize.small:
        return 20.0;
      case LoadingSize.medium:
        return 40.0;
      case LoadingSize.large:
        return 60.0;
    }
  }

  double get _spacing {
    switch (widget.size) {
      case LoadingSize.small:
        return 8.0;
      case LoadingSize.medium:
        return 16.0;
      case LoadingSize.large:
        return 24.0;
    }
  }

  Widget _buildLoadingIndicator() {
    final color = widget.color ?? Theme.of(context).primaryColor;

    switch (widget.type) {
      case LoadingType.circular:
        return SizedBox(
          width: _indicatorSize,
          height: _indicatorSize,
          child: CircularProgressIndicator(color: color, backgroundColor: widget.backgroundColor, strokeWidth: widget.strokeWidth ?? 4.0, value: widget.progress),
        );

      case LoadingType.linear:
        return SizedBox(
          width: _indicatorSize * 3,
          child: LinearProgressIndicator(color: color, backgroundColor: widget.backgroundColor, value: widget.progress),
        );

      case LoadingType.dots:
        return _buildDotsIndicator(color);

      case LoadingType.spinner:
        return _buildSpinnerIndicator(color);
    }
  }

  Widget _buildDotsIndicator(Color color) {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_dotsController.value - delay).clamp(0.0, 1.0);
            final scale = (sin(animationValue * pi) * 0.5 + 0.5).clamp(0.5, 1.0);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: _spacing / 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: _indicatorSize / 3,
                  height: _indicatorSize / 3,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSpinnerIndicator(Color color) {
    return AnimatedBuilder(
      animation: _spinnerController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _spinnerController.value * 2 * pi,
          child: Container(
            width: _indicatorSize,
            height: _indicatorSize,
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.3), width: widget.strokeWidth ?? 3.0),
              borderRadius: BorderRadius.circular(_indicatorSize / 2),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: color, width: widget.strokeWidth ?? 3.0),
                ),
                borderRadius: BorderRadius.circular(_indicatorSize / 2),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    final children = <Widget>[_buildLoadingIndicator()];

    if (widget.showMessage && widget.message != null) {
      children.add(SizedBox(height: _spacing));
      children.add(
        Text(
          widget.message!,
          style: widget.messageStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(mainAxisAlignment: widget.mainAxisAlignment, crossAxisAlignment: widget.crossAxisAlignment, mainAxisSize: MainAxisSize.min, children: children);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(padding: widget.padding, child: _buildContent());

    if (widget.overlay) {
      content = Container(
        color: widget.overlayColor ?? Colors.black.withValues(alpha: 0.3),
        child: Center(child: content),
      );
    } else {
      content = Center(child: content);
    }

    return content;
  }
}
