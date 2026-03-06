import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// 扫码类型枚举
enum ScanCodeType {
  /// 二维码
  qrCode,

  /// 条形码
  barCode,

  /// 所有类型
  all,
}

class ScanQrcode extends StatefulWidget {
  /// 扫码成功回调
  final Function(String)? onScanSuccess;

  /// 扫码失败回调
  final Function(String)? onScanError;

  /// 是否显示扫描框
  final bool showScanArea;

  /// 扫描框颜色
  final Color scanAreaColor;

  /// 扫描框大小（已废弃，将使用响应式计算）
  final double? scanAreaSize;

  /// 是否显示闪光灯按钮
  final bool showFlashButton;

  /// 是否显示相册按钮
  final bool showGalleryButton;

  /// 提示文字
  final String? hintText;

  /// 扫码类型
  final ScanCodeType scanType;

  const ScanQrcode({
    super.key,
    this.onScanSuccess,
    this.onScanError,
    this.showScanArea = false,
    this.scanAreaColor = Colors.green,
    this.scanAreaSize,
    this.showFlashButton = true,
    this.showGalleryButton = true,
    this.hintText,
    this.scanType = ScanCodeType.qrCode,
  });

  @override
  State<ScanQrcode> createState() => _ScanQrcodeState();
}

class _ScanQrcodeState extends State<ScanQrcode> with SingleTickerProviderStateMixin {
  late MobileScannerController controller;
  late AnimationController _scanAnimationController;
  bool isFlashOn = false;
  bool isStarted = false;
  // 标记是否正在处理一次识别结果，防止重复回调或重复跳转
  bool _isHandling = false;

  // 多二维码选择相关状态
  List<Barcode>? _multipleBarcodes;
  Size? _captureSize;
  Uint8List? _captureImage;

  // 缓冲机制
  Timer? _debounceTimer;
  BarcodeCapture? _pendingCapture;
  DateTime? _lastToastTime;

  // 不支持类型的视觉反馈状态
  bool _showMismatchError = false;
  Timer? _mismatchErrorTimer;

  @override
  void initState() {
    super.initState();

    // 启用检测，允许返回图片用于后续处理
    // detectionSpeed 设置为 normal 以便持续检测，从而实现持续的错误反馈（需配合限流逻辑）
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: true,
      // 支持所有格式，以便我们在逻辑层进行过滤和提示
      formats: const [BarcodeFormat.all],
    );

    _scanAnimationController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  /// 二维码扫描回调
  void _onDetect(BarcodeCapture capture) {
    if (_isHandling) return;
    if (capture.image == null) return;

    final validBarcodes = capture.barcodes.where((b) => b.rawValue != null).toList();
    if (validBarcodes.isEmpty) return;

    // 保存当前帧信息用于后续可能的覆盖层绘制
    // 使用最新的一帧，确保画面和识别结果同步
    _pendingCapture = capture;

    // 重置防抖定时器
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // 200ms 缓冲期，等待更多码被识别（或者等待用户手持稳定）
    _debounceTimer = Timer(const Duration(milliseconds: 200), _processDetectedBarcodes);
  }

  /// 处理缓冲后的条码
  void _processDetectedBarcodes() async {
    if (_isHandling || _pendingCapture == null) return;

    final capture = _pendingCapture!;
    _pendingCapture = null;
    final allBarcodes = capture.barcodes;

    // 根据 scanType 过滤
    final List<Barcode> validBarcodes = [];
    final List<Barcode> invalidBarcodes = [];

    for (var barcode in allBarcodes) {
      bool isValid = false;
      if (widget.scanType == ScanCodeType.all) {
        isValid = true;
      } else if (widget.scanType == ScanCodeType.qrCode) {
        isValid = barcode.format == BarcodeFormat.qrCode;
      } else if (widget.scanType == ScanCodeType.barCode) {
        // 简单判断：非二维码即视为条形码（或根据需求更严格判断）
        isValid = barcode.format != BarcodeFormat.qrCode && barcode.format != BarcodeFormat.dataMatrix;
      }

      if (isValid) {
        validBarcodes.add(barcode);
      } else {
        invalidBarcodes.add(barcode);
      }
    }

    // 如果没有有效码，但有无效码，提示用户
    if (validBarcodes.isEmpty) {
      if (invalidBarcodes.isNotEmpty) {
        _showTypeMismatchToast();
      }
      // 继续扫描
      return;
    }

    // 找到有效码，开始处理
    _isHandling = true;
    try {
      await controller.stop();
    } catch (e) {
      // 忽略停止异常
    }

    if (!mounted) return;

    // 震动
    HapticFeedback.lightImpact();

    // 立即清除错误提示状态
    _mismatchErrorTimer?.cancel();

    setState(() {
      _showMismatchError = false;
      _multipleBarcodes = validBarcodes;
      _captureSize = capture.size;
      _captureImage = capture.image;
    });
    _scanAnimationController.stop();

    // 如果只有一个码，显示聚焦效果后自动跳转
    if (validBarcodes.length == 1) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          widget.onScanSuccess?.call(validBarcodes.first.rawValue!);
        }
      });
    }
    // 如果有多个码，保持在当前界面等待用户选择（UI会自动渲染选择框）
  }

  void _showTypeMismatchToast() {
    final now = DateTime.now();
    // 持续扫描时，每隔2秒提示一次
    if (_lastToastTime != null && now.difference(_lastToastTime!) < const Duration(seconds: 2)) {
      return;
    }
    _lastToastTime = now;

    // 显示红色警告视觉反馈
    if (mounted) {
      setState(() {
        _showMismatchError = true;
      });
      _mismatchErrorTimer?.cancel();
      _mismatchErrorTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _showMismatchError = false;
          });
        }
      });
    }
  }

  /// 切换闪光灯
  Future<void> _toggleFlash() async {
    try {
      await controller.toggleTorch();
    } catch (e) {
      widget.onScanError?.call('闪光灯切换失败: $e');
    }
  }

  /// 从相册选择图片
  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // 使用mobile_scanner分析选中的图片
        final result = await controller.analyzeImage(image.path);

        if (result != null && result.barcodes.isNotEmpty) {
          // 如果 result.image 为空，手动读取
          Uint8List? imageBytes = result.image;
          if (imageBytes == null) {
            imageBytes = await image.readAsBytes();
          }

          // 尝试获取图片尺寸
          Size? imageSize = result.size;
          // 如果 analyzeImage 返回的尺寸无效 (宽高为0)，则手动解码获取
          if (imageSize.width == 0 || imageSize.height == 0) {
            try {
              final decodedImage = await decodeImageFromList(imageBytes);
              imageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
            } catch (e) {
              debugPrint('解码图片尺寸失败: $e');
            }
          }

          // 直接处理，跳过缓冲，但需要过滤
          _handleGalleryResult(result, imageBytes, imageSize: imageSize);
        } else {
          widget.onScanError?.call('所选图片中未找到二维码');
        }
      }
    } catch (e) {
      widget.onScanError?.call('相册选择失败: $e');
    }
  }

  void _handleGalleryResult(BarcodeCapture capture, Uint8List? imageBytes, {Size? imageSize}) async {
    final barcodes = capture.barcodes;
    // 简单处理相册结果，同样应用类型过滤
    final validBarcodes = barcodes.where((b) {
      if (widget.scanType == ScanCodeType.all) return true;
      if (widget.scanType == ScanCodeType.qrCode) return b.format == BarcodeFormat.qrCode;
      if (widget.scanType == ScanCodeType.barCode) return b.format != BarcodeFormat.qrCode;
      return false;
    }).toList();

    if (validBarcodes.isNotEmpty) {
      // 震动
      HapticFeedback.lightImpact();

      // 立即清除错误提示状态
      _mismatchErrorTimer?.cancel();
      if (_showMismatchError) {
        setState(() {
          _showMismatchError = false;
        });
      }

      final size = imageSize ?? capture.size;

      // 如果只有一个码，直接返回结果
      if (validBarcodes.length == 1) {
        if (mounted) {
          widget.onScanSuccess?.call(validBarcodes.first.rawValue ?? '');
        }
      } else {
        // 如果有多个码，进入选择模式
        // 注意：多码选择模式需要依赖 capture.size (或者传入的 imageSize) 来正确绘制覆盖层
        // 如果无法获取尺寸，则无法进行准确的坐标映射，此时只能回退到返回第一个
        if (size.isEmpty) {
          if (mounted) {
            widget.onScanSuccess?.call(validBarcodes.first.rawValue ?? '');
          }
          return;
        }

        _isHandling = true;
        controller.stop();
        _scanAnimationController.stop();

        setState(() {
          _multipleBarcodes = validBarcodes;
          _captureSize = size;
          _captureImage = capture.image ?? imageBytes;
        });
      }
    } else {
      _showTypeMismatchToast();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 动态计算提示文字
    final String hintText =
        widget.hintText ??
        switch (widget.scanType) {
          ScanCodeType.qrCode => '请对准需要识别的二维码',
          ScanCodeType.barCode => '请对准需要识别的条形码',
          ScanCodeType.all => '将二维码/条形码放入框内，即可自动扫描',
        };

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 相机预览
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
            scanWindow: widget.showScanArea
                ? Rect.fromCenter(
                    center: Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2),
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                  )
                : null,
          ),

          // 扫描动画层 (即使不显示扫描框，也可以显示全屏扫描线)
          // 如果显示扫描框，则绘制框+线；如果不显示，只绘制全屏线
          if (_multipleBarcodes == null) _buildScanOverlay(),

          // 不支持类型的视觉警告反馈 (红色半透明遮罩 + 图标)
          if (_showMismatchError)
            Container(
              color: Colors.red.withValues(alpha: 0.2),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 60),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      widget.scanType == ScanCodeType.qrCode ? '当前模式只支持扫描二维码' : '当前模式只支持扫描条形码',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          // 多二维码选择覆盖层 (包含单码聚焦效果)
          if (_multipleBarcodes != null) _buildMultiSelectOverlay(),

          // 顶部导航栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent]),
              ),
              child: Row(
                children: [
                  // 返回按钮
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 标题
                  const Text(
                    '扫一扫',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          // 底部控制区域 (提示文字 + 按钮)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 提示文字
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    hintText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black54)],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 控制按钮
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 相册按钮
                      if (widget.showGalleryButton) _buildControlButton(icon: Icons.photo_library, label: '相册', onTap: _pickFromGallery),

                      // 闪光灯按钮
                      if (widget.showFlashButton)
                        ValueListenableBuilder<MobileScannerState>(
                          valueListenable: controller,
                          builder: (context, state, child) {
                            final bool isFlashOn = state.torchState == TorchState.on;
                            return _buildControlButton(icon: isFlashOn ? Icons.flash_on : Icons.flash_off, label: isFlashOn ? '关闭闪光灯' : '打开闪光灯', onTap: _toggleFlash);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建扫描框/扫描线覆盖层
  Widget _buildScanOverlay() {
    return AnimatedBuilder(
      animation: _scanAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: ScannerOverlayPainter(
            borderColor: widget.scanAreaColor,
            borderLength: 30,
            borderWidth: 10,
            // 如果不显示扫描框，传入Size.zero或者特定标识，Painter内部处理
            scanWindowSize: widget.showScanArea ? Size(MediaQuery.of(context).size.width * 0.8, MediaQuery.of(context).size.width * 0.8) : Size.zero,
            scanLineValue: _scanAnimationController.value,
            drawBorder: widget.showScanArea,
          ),
          child: Container(),
        );
      },
    );
  }

  /// 构建控制按钮
  Widget _buildControlButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// 构建多二维码选择覆盖层 (也用于单码聚焦)
  Widget _buildMultiSelectOverlay() {
    if (_multipleBarcodes == null || _captureSize == null) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;
        final double imageWidth = _captureSize!.width;
        final double imageHeight = _captureSize!.height;

        // 计算缩放比例 (BoxFit.cover)
        final double scaleX = screenWidth / imageWidth;
        final double scaleY = screenHeight / imageHeight;
        final double scale = scaleX > scaleY ? scaleX : scaleY;

        final double scaledWidth = imageWidth * scale;
        final double scaledHeight = imageHeight * scale;

        // 计算偏移量以居中
        final double offsetX = (screenWidth - scaledWidth) / 2;
        final double offsetY = (screenHeight - scaledHeight) / 2;

        // 是否是单码模式
        final bool isSingleMode = _multipleBarcodes!.length == 1;

        return Stack(
          children: [
            // 显示定格的相机画面
            if (_captureImage != null)
              SizedBox(
                width: screenWidth,
                height: screenHeight,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(width: imageWidth, height: imageHeight, child: Image.memory(_captureImage!)),
                ),
              ),

            // 半透明背景
            // 单码模式下，背景稍微暗一点即可，或者不暗，只显示框
            Container(color: Colors.black.withValues(alpha: isSingleMode ? 0.1 : 0.4)),

            // 提示文字 (仅多码模式显示)
            if (!isSingleMode)
              Positioned(
                top: MediaQuery.of(context).padding.top + 80,
                left: 0,
                right: 0,
                child: const Text(
                  "检测到多个二维码\n请点击选择一个",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black)],
                  ),
                ),
              ),

            // 点击空白区域取消选择并重新扫描 (仅多码模式)
            if (!isSingleMode)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _multipleBarcodes = null;
                      _isHandling = false;
                      _pendingCapture = null; // 清除旧数据
                    });
                    controller.start();
                    _scanAnimationController.repeat();
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(color: Colors.transparent),
                ),
              ),

            // 绘制每个二维码的选择按钮/聚焦框
            ..._multipleBarcodes!.map((barcode) {
              if (barcode.corners.isEmpty) return const SizedBox();

              // 计算二维码区域的包围盒
              double minX = double.infinity;
              double minY = double.infinity;
              double maxX = double.negativeInfinity;
              double maxY = double.negativeInfinity;

              for (var point in barcode.corners) {
                if (point.dx < minX) minX = point.dx;
                if (point.dy < minY) minY = point.dy;
                if (point.dx > maxX) maxX = point.dx;
                if (point.dy > maxY) maxY = point.dy;
              }

              // 增加一点内边距
              const double padding = 10.0;
              final double rectLeft = (minX - padding) * scale + offsetX;
              final double rectTop = (minY - padding) * scale + offsetY;
              final double rectWidth = ((maxX - minX) + padding * 2) * scale;
              final double rectHeight = ((maxY - minY) + padding * 2) * scale;

              return Positioned(
                left: rectLeft,
                top: rectTop,
                width: rectWidth,
                height: rectHeight,
                child: GestureDetector(
                  onTap: () {
                    if (!isSingleMode && barcode.rawValue != null) {
                      widget.onScanSuccess?.call(barcode.rawValue!);
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 绿色高亮框 (单码模式下也显示，作为聚焦反馈)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.greenAccent, width: 3),
                          borderRadius: BorderRadius.circular(8),
                          color: isSingleMode ? Colors.transparent : Colors.green.withValues(alpha: 0.3),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1)],
                        ),
                      ),
                      // 中心的点击提示 (仅多码模式显示)
                      if (!isSingleMode)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.greenAccent, width: 2),
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.green.withValues(alpha: 0.6),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1)],
                          ),
                          child: const Icon(Icons.touch_app, color: Colors.white, size: 28),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mismatchErrorTimer?.cancel();
    _scanAnimationController.dispose();
    controller.dispose();
    super.dispose();
  }
}

/// 自定义扫描框绘制器
class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderLength;
  final double borderWidth;
  final Size scanWindowSize;
  final double scanLineValue;
  final bool drawBorder;

  ScannerOverlayPainter({
    required this.borderColor,
    required this.borderLength,
    required this.borderWidth,
    required this.scanWindowSize,
    required this.scanLineValue,
    required this.drawBorder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 绘制扫描线 (全屏扫描从上到下)
    if (scanLineValue > 0) {
      // 扫描范围覆盖整个屏幕高度
      final double scanLineY = size.height * scanLineValue;

      // 扫描线宽度，如果显示框则限制在框宽内，否则全屏宽
      // 用户需求：扫描动画从手机屏幕顶部扫描到底部
      // 所以无论是否显示框，扫描线最好是全屏宽或者至少宽一些
      // 如果 drawBorder 为 true，通常希望线在框内？
      // 用户原话："扫描动画就重手机屏幕顶部扫描到底部,不在只是扫描框里面"
      // 这意味着扫描线应该是全屏宽度的。

      final double lineWidth = size.width;
      final double lineLeft = 0;

      final Paint scanLinePaint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.transparent, borderColor, Colors.transparent],
          stops: const [0.1, 0.5, 0.9],
        ).createShader(Rect.fromLTWH(lineLeft, scanLineY, lineWidth, 4));

      canvas.drawRect(Rect.fromLTWH(lineLeft, scanLineY, lineWidth, 4), scanLinePaint);
    }

    if (!drawBorder) return;

    final Paint paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    // 计算扫描框的位置
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final Rect scanRect = Rect.fromCenter(center: Offset(centerX, centerY), width: scanWindowSize.width, height: scanWindowSize.height);

    // 绘制四个角的边框
    // 左上角
    canvas.drawLine(Offset(scanRect.left, scanRect.top + borderLength), Offset(scanRect.left, scanRect.top), paint);
    canvas.drawLine(Offset(scanRect.left, scanRect.top), Offset(scanRect.left + borderLength, scanRect.top), paint);

    // 右上角
    canvas.drawLine(Offset(scanRect.right - borderLength, scanRect.top), Offset(scanRect.right, scanRect.top), paint);
    canvas.drawLine(Offset(scanRect.right, scanRect.top), Offset(scanRect.right, scanRect.top + borderLength), paint);

    // 左下角
    canvas.drawLine(Offset(scanRect.left, scanRect.bottom - borderLength), Offset(scanRect.left, scanRect.bottom), paint);
    canvas.drawLine(Offset(scanRect.left, scanRect.bottom), Offset(scanRect.left + borderLength, scanRect.bottom), paint);

    // 右下角
    canvas.drawLine(Offset(scanRect.right - borderLength, scanRect.bottom), Offset(scanRect.right, scanRect.bottom), paint);
    canvas.drawLine(Offset(scanRect.right, scanRect.bottom), Offset(scanRect.right, scanRect.bottom - borderLength), paint);
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) => scanLineValue != oldDelegate.scanLineValue || drawBorder != oldDelegate.drawBorder;
}
