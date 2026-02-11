import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

  const ScanQrcode({
    super.key,
    this.onScanSuccess,
    this.onScanError,
    this.showScanArea = true,
    this.scanAreaColor = Colors.green,
    this.scanAreaSize,
    this.showFlashButton = true,
    this.showGalleryButton = true,
    this.hintText,
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

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates, facing: CameraFacing.back, torchEnabled: false, returnImage: true);

    _scanAnimationController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  /// 二维码扫描回调
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isHandling) return;
    final List<Barcode> barcodes = capture.barcodes;
    // 过滤掉无效的二维码
    final validBarcodes = barcodes.where((b) => b.rawValue != null).toList();

    if (validBarcodes.isEmpty) return;

    // 如果只有一个二维码，保持原有逻辑
    if (validBarcodes.length == 1) {
      _isHandling = true;
      try {
        await controller.stop();
      } catch (e) {
        // 忽略停止异常
      }
      widget.onScanSuccess?.call(validBarcodes.first.rawValue!);
    } else {
      // 如果有多个二维码，进入选择模式
      _isHandling = true;
      try {
        await controller.stop();
      } catch (e) {
        // 忽略停止异常
      }

      setState(() {
        _multipleBarcodes = validBarcodes;
        _captureSize = capture.size;
        _captureImage = capture.image;
      });
      _scanAnimationController.stop();
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
          // 找到二维码：进入处理状态并停止相机，防止后续重复触发
          _isHandling = true;
          try {
            await controller.stop();
          } catch (e) {
            // 忽略停止异常
          }
          widget.onScanSuccess?.call(result.barcodes.first.rawValue ?? '');
        } else {
          // 如果没有找到二维码
          widget.onScanError?.call('所选图片中未找到二维码');
        }
      }
    } catch (e) {
      widget.onScanError?.call('相册选择失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 相机预览
          MobileScanner(controller: controller, onDetect: _onDetect),

          // 扫描框覆盖层
          if (widget.showScanArea && _multipleBarcodes == null) _buildScanOverlay(),

          // 多二维码选择覆盖层
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

          // 中间提示文字
          if (widget.hintText != null)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.hintText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    shadows: [Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black54)],
                  ),
                ),
              ),
            ),

          // 底部控制按钮
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 80,
            left: 0,
            right: 0,
            child: Container(
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
          ),
        ],
      ),
    );
  }

  /// 构建扫描框覆盖层
  Widget _buildScanOverlay() {
    return AnimatedBuilder(
      animation: _scanAnimationController,
      builder: (context, child) {
        // 计算响应式扫描框大小
        final double screenWidth = MediaQuery.of(context).size.width;
        // 宽度为屏幕宽度的 80%
        final double scanWidth = screenWidth * 0.8;
        // 高度与宽度一致（正方形）
        final double scanHeight = scanWidth;

        return CustomPaint(
          painter: ScannerOverlayPainter(
            borderColor: widget.scanAreaColor,
            borderLength: 30,
            borderWidth: 10,
            scanWindowSize: Size(scanWidth, scanHeight),
            scanLineValue: _scanAnimationController.value,
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

  /// 构建多二维码选择覆盖层
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

            // 半透明背景，轻微压暗，突出显示绿色选择框
            Container(color: Colors.black38),

            // 提示文字
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

            // 点击空白区域取消选择并重新扫描
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _multipleBarcodes = null;
                    _isHandling = false;
                  });
                  controller.start();
                  _scanAnimationController.repeat();
                },
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),

            // 绘制每个二维码的选择按钮
            ..._multipleBarcodes!.map((barcode) {
              if (barcode.corners.isEmpty) return const SizedBox();

              // 计算二维码区域的包围盒（在原始图像坐标系中）
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

              // 增加一点内边距，确保内容完整
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
                    if (barcode.rawValue != null) {
                      widget.onScanSuccess?.call(barcode.rawValue!);
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 绿色高亮框
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.greenAccent, width: 3),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.green.withValues(alpha: 0.3),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1)],
                        ),
                      ),
                      // 中心的点击提示
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

  ScannerOverlayPainter({required this.borderColor, required this.borderLength, required this.borderWidth, required this.scanWindowSize, required this.scanLineValue});

  @override
  void paint(Canvas canvas, Size size) {
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

    // 绘制半透明遮罩
    final Paint overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);

    // 绘制四个遮罩区域
    // 上方
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, scanRect.top), overlayPaint);
    // 下方
    canvas.drawRect(Rect.fromLTWH(0, scanRect.bottom, size.width, size.height - scanRect.bottom), overlayPaint);
    // 左侧
    canvas.drawRect(Rect.fromLTWH(0, scanRect.top, scanRect.left, scanRect.height), overlayPaint);
    // 右侧
    canvas.drawRect(Rect.fromLTWH(scanRect.right, scanRect.top, size.width - scanRect.right, scanRect.height), overlayPaint);

    // 绘制扫描线
    if (scanLineValue > 0) {
      final double scanLineY = scanRect.top + (scanRect.height * scanLineValue);
      final Paint scanLinePaint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.transparent, borderColor, Colors.transparent],
          stops: const [0.1, 0.5, 0.9],
        ).createShader(Rect.fromLTWH(scanRect.left, scanLineY, scanRect.width, 4));

      canvas.drawRect(Rect.fromLTWH(scanRect.left, scanLineY, scanRect.width, 4), scanLinePaint);
    }
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) => scanLineValue != oldDelegate.scanLineValue;
}
