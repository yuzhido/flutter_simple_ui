import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

class ScanQrcodePage extends StatefulWidget {
  const ScanQrcodePage({super.key});
  @override
  State<ScanQrcodePage> createState() => _ScanQrcodePageState();
}

class _ScanQrcodePageState extends State<ScanQrcodePage> {
  String? scanResult;
  bool showScanArea = true;
  Color scanAreaColor = Colors.green;
  double scanAreaSize = 250.0;
  bool showFlashButton = true;
  bool showGalleryButton = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫码组件示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: _buildConfigView(),
    );
  }

  /// 打开扫码器模态窗口
  void _openScannerModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScanQrcode(
          onScanSuccess: (result) {
            Navigator.of(context).pop(); // 关闭扫码页面
            setState(() {
              scanResult = result;
            });
            _showResultDialog(result);
          },
          onScanError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
          },
          showScanArea: showScanArea,
          scanAreaColor: scanAreaColor,
          scanAreaSize: scanAreaSize,
          showFlashButton: showFlashButton,
          showGalleryButton: showGalleryButton,
          hintText: '请将二维码放入扫描框内',
        ),
        fullscreenDialog: true, // 全屏模态
      ),
    );
  }

  /// 构建配置视图
  Widget _buildConfigView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 扫码结果显示
          if (scanResult != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.qr_code_scanner, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('扫码结果', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: scanResult!));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
                          },
                          icon: const Icon(Icons.copy),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: Text(scanResult!, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 开始扫码按钮
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                _openScannerModal();
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('开始扫码'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 配置选项
          const Text('扫码器配置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // 显示扫描框
          Card(
            child: SwitchListTile(
              title: const Text('显示扫描框'),
              subtitle: const Text('是否显示扫描区域的边框'),
              value: showScanArea,
              onChanged: (value) {
                setState(() {
                  showScanArea = value;
                });
              },
            ),
          ),

          // 扫描框颜色
          Card(
            child: ListTile(
              title: const Text('扫描框颜色'),
              subtitle: const Text('选择扫描框的边框颜色'),
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: scanAreaColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: _showColorPicker,
            ),
          ),

          // 扫描框大小
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('扫描框大小: ${scanAreaSize.toInt()}'),
                  Slider(
                    value: scanAreaSize,
                    min: 150,
                    max: 350,
                    divisions: 20,
                    onChanged: (value) {
                      setState(() {
                        scanAreaSize = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // 显示闪光灯按钮
          Card(
            child: SwitchListTile(
              title: const Text('显示闪光灯按钮'),
              subtitle: const Text('是否显示闪光灯控制按钮'),
              value: showFlashButton,
              onChanged: (value) {
                setState(() {
                  showFlashButton = value;
                });
              },
            ),
          ),

          // 显示相册按钮
          Card(
            child: SwitchListTile(
              title: const Text('显示相册按钮'),
              subtitle: const Text('是否显示从相册选择图片的按钮'),
              value: showGalleryButton,
              onChanged: (value) {
                setState(() {
                  showGalleryButton = value;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // 使用说明
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('使用说明', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('1. 点击"开始扫码"按钮启动扫码功能'),
                  const Text('2. 将二维码对准扫描框进行识别'),
                  const Text('3. 可以使用闪光灯辅助扫码'),
                  const Text('4. 扫码成功后会自动返回结果'),
                  const SizedBox(height: 8),
                  const Text(
                    '注意：首次使用需要授权相机权限',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示颜色选择器
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择扫描框颜色'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [Colors.green, Colors.blue, Colors.red, Colors.orange, Colors.purple, Colors.teal]
              .map(
                (color) => GestureDetector(
                  onTap: () {
                    setState(() {
                      scanAreaColor = color;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: scanAreaColor == color ? Colors.black : Colors.grey, width: scanAreaColor == color ? 3 : 1),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消'))],
      ),
    );
  }

  /// 显示扫码结果对话框
  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('扫码成功'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('扫码结果：'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Text(result, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: result));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
            },
            child: const Text('复制'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定')),
        ],
      ),
    );
  }
}
