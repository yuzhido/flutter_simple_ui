import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

class ScanQrcode extends StatefulWidget {
  /// 扫码成功回调
  final Function(String)? onScanSuccess;

  /// 扫码失败回调
  final Function(String)? onScanError;

  /// 是否显示扫描框
  final bool showScanArea;

  /// 扫描框颜色
  final Color scanAreaColor;

  /// 扫描框大小
  final double scanAreaSize;

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
    this.scanAreaSize = 250.0,
    this.showFlashButton = true,
    this.showGalleryButton = true,
    this.hintText,
  });

  @override
  State<ScanQrcode> createState() => _ScanQrcodeState();
}

class _ScanQrcodeState extends State<ScanQrcode> {
  late MobileScannerController controller;
  bool isFlashOn = false;
  bool isStarted = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates, facing: CameraFacing.back, torchEnabled: false);
  }

  /// 二维码扫描回调
  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        widget.onScanSuccess?.call(barcode.rawValue!);
        break;
      }
    }
  }

  /// 切换闪光灯
  Future<void> _toggleFlash() async {
    try {
      await controller.toggleTorch();
      setState(() {
        isFlashOn = !isFlashOn;
      });
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
          // 如果找到二维码，调用回调
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
          if (widget.showScanArea) _buildScanOverlay(),

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
                  if (widget.showFlashButton) _buildControlButton(icon: isFlashOn ? Icons.flash_on : Icons.flash_off, label: isFlashOn ? '关闭闪光灯' : '打开闪光灯', onTap: _toggleFlash),
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
    return CustomPaint(
      painter: ScannerOverlayPainter(borderColor: widget.scanAreaColor, borderLength: 30, borderWidth: 10, cutOutSize: widget.scanAreaSize),
      child: Container(),
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// 自定义扫描框绘制器
class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  ScannerOverlayPainter({required this.borderColor, required this.borderLength, required this.borderWidth, required this.cutOutSize});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    // 计算扫描框的位置
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final Rect scanRect = Rect.fromCenter(center: Offset(centerX, centerY), width: cutOutSize, height: cutOutSize);

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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
