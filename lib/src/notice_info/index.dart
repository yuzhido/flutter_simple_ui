import 'package:flutter/material.dart';

class NoticeInfo extends StatefulWidget {
  final String message;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final bool enableScroll;
  final Duration scrollDuration;
  final Duration pauseDuration;
  // 无缝无限循环滚动
  final bool seamless;

  const NoticeInfo({
    super.key,
    this.message = '恭述提示文字',
    this.onTap,
    this.padding,
    this.height,
    this.enableScroll = false,
    this.scrollDuration = const Duration(seconds: 10),
    this.pauseDuration = const Duration(seconds: 2),
    this.seamless = true,
  });

  @override
  State<NoticeInfo> createState() => _NoticeInfoState();
}

class _NoticeInfoState extends State<NoticeInfo> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _needsScroll = false;
  double _textWidth = 0.0;
  double _containerWidth = 0.0;
  // 无缝滚动相关
  AnimationController? _marqueeController;
  static const double _gapWidth = 32.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // 延迟检查是否需要滚动
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollNeeded();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _marqueeController?.dispose();
    super.dispose();
  }

  void _checkIfScrollNeeded() {
    if (!widget.enableScroll) return;

    // 获取文本的实际宽度
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.message,
        style: const TextStyle(color: Color(0xFF424242), fontSize: 14.0, fontWeight: FontWeight.w400),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    _textWidth = textPainter.width;

    // 获取容器的可用宽度
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      // 计算可用于文本的真实宽度：容器总宽度 - 水平内边距 - 图标宽度 - 图标与文字间距
      final EdgeInsets resolvedPadding = (widget.padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)).resolve(Directionality.of(context));
      const double iconWidth = 24.0;
      const double iconSpacing = 12.0;
      final double horizontalPadding = resolvedPadding.left + resolvedPadding.right;

      _containerWidth = renderBox.size.width - horizontalPadding - iconWidth - iconSpacing;

      if (_textWidth > _containerWidth) {
        setState(() {
          _needsScroll = true;
        });
        _startScrolling();
      } else {
        if (_needsScroll) {
          setState(() => _needsScroll = false);
        }
        _marqueeController?.stop();
      }
    }
  }

  void _startScrolling() {
    if (!_needsScroll) return;
    if (widget.seamless) {
      _startSeamlessMarquee();
    } else {
      // 开始无限循环滚动（往返，非无缝）
      _startInfiniteScroll();
    }
  }

  void _startSeamlessMarquee() {
    // 若未启用或不需要滚动，直接返回
    if (!widget.enableScroll || !_needsScroll) return;

    _marqueeController?.dispose();
    _marqueeController = AnimationController(vsync: this, duration: widget.scrollDuration);
    _marqueeController!.repeat();
  }

  void _startInfiniteScroll() {
    if (!_needsScroll) return;

    // 使用更平滑的循环方式
    _animateScroll();
  }

  void _animateScroll() {
    if (!mounted || !_needsScroll) return;

    // 如果还未挂载到视图，延迟到下一帧再尝试
    if (!_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _animateScroll();
      });
      return;
    }

    // 重置到开始位置
    _scrollController.jumpTo(0);

    // 延迟开始滚动
    Future.delayed(widget.pauseDuration, () {
      if (mounted && _needsScroll) {
        final double distance = (_textWidth - _containerWidth).clamp(0.0, double.infinity);
        if (distance <= 0) return;
        // 使用animateTo而不是jumpTo，提供更平滑的动画
        _scrollController.animateTo(distance, duration: widget.scrollDuration, curve: Curves.linear).then((_) {
          // 滚动完成后，延迟暂停时间，然后重新开始
          Future.delayed(widget.pauseDuration, () {
            if (mounted && _needsScroll) {
              _animateScroll();
            }
          });
        });
      }
    });
  }

  @override
  void didUpdateWidget(NoticeInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当消息、滚动开关、尺寸或内边距发生变化时，重新检测是否需要滚动
    if (oldWidget.message != widget.message ||
        oldWidget.enableScroll != widget.enableScroll ||
        oldWidget.height != widget.height ||
        oldWidget.padding != widget.padding ||
        oldWidget.seamless != widget.seamless ||
        oldWidget.scrollDuration != widget.scrollDuration) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkIfScrollNeeded();
          if (!widget.enableScroll || !_needsScroll || !widget.seamless) {
            _marqueeController?.stop();
          } else {
            _startSeamlessMarquee();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用 AnimatedBuilder 以像素级匀速移动，避免 jumpTo 带来的抖动
    final bool useSeamless = _needsScroll && widget.enableScroll && widget.seamless;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: widget.height ?? 48.0,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F4FF), // 浅紫色背景
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // 左侧蓝色扬声器图标
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: const Icon(
                Icons.volume_up,
                color: Color(0xFF2196F3), // 蓝色
                size: 24.0,
              ),
            ),
            const SizedBox(width: 12.0), // 图标和文字之间的间距
            // 右侧中文提示文字
            Expanded(
              child: useSeamless
                  ? AnimatedBuilder(
                      animation: _marqueeController ?? kAlwaysDismissedAnimation,
                      builder: (context, _) {
                        final double loop = (_textWidth + _gapWidth).clamp(1.0, double.infinity);
                        final double offset = ((_marqueeController?.value ?? 0.0) * loop) % loop;
                        return ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: _containerWidth > 0 ? _containerWidth : null,
                              height: widget.height ?? 48.0,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(), // 禁止手动滑动，只允许动画滚动
                                child: Transform.translate(
                                  offset: Offset(-offset, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.message,
                                        style: const TextStyle(color: Color(0xFF424242), fontSize: 14.0, fontWeight: FontWeight.w400),
                                        softWrap: false,
                                        overflow: TextOverflow.visible,
                                      ),
                                      const SizedBox(width: _gapWidth),
                                      Text(
                                        widget.message,
                                        style: const TextStyle(color: Color(0xFF424242), fontSize: 14.0, fontWeight: FontWeight.w400),
                                        softWrap: false,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : (_needsScroll && widget.enableScroll)
                  ? SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: Text(
                        widget.message,
                        style: const TextStyle(color: Color(0xFF424242), fontSize: 14.0, fontWeight: FontWeight.w400),
                      ),
                    )
                  : Text(
                      widget.message,
                      style: const TextStyle(color: Color(0xFF424242), fontSize: 14.0, fontWeight: FontWeight.w400),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: 2,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
