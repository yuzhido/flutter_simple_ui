# ScanQrcode 二维码扫描组件

一个功能完整的二维码扫描组件，支持相机扫描、相册选择、闪光灯控制等功能。

## 示例展示

<img src="Snipaste_2025-10-15_14-31-48.png" width="300" alt="二维码扫描界面" />
<img src="Snipaste_2025-10-15_14-32-05.png" width="300" alt="扫描成功提示" />
<img src="Snipaste_2025-10-15_14-32-20.png" width="300" alt="相册选择功能" />

## 功能特性

- **相机扫描**: 使用设备相机实时扫描二维码
- **相册选择**: 支持从相册选择图片进行二维码识别
- **闪光灯控制**: 可开启/关闭闪光灯辅助扫描
- **自定义扫描框**: 可自定义扫描框的颜色、大小和显示状态
- **全屏界面**: 提供完整的扫码界面，包含导航栏和控制按钮
- **错误处理**: 完善的错误处理和用户反馈机制
- **权限管理**: 自动处理相机和相册访问权限

## 依赖配置

在使用此组件前，需要在 `pubspec.yaml` 中添加以下依赖：

```yaml
dependencies:
  mobile_scanner: ^5.0.0
  image_picker: ^1.0.0
```

### iOS 权限配置

在 `ios/Runner/Info.plist` 中添加：

```xml
<!-- 相机权限 -->
<key>NSCameraUsageDescription</key>
<string>此应用需要访问相机以拍摄照片</string>

<!-- 相册权限 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>此应用需要访问相册以选择图片</string>
```

### Android 权限配置

在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## 基础用法

### 简单扫码

```dart
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

// 打开扫码页面
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ScanQrcode(
      onScanSuccess: (result) {
        // 扫码成功回调
        print('扫码结果: $result');
        Navigator.pop(context);
      },
      onScanError: (error) {
        // 扫码失败回调
        print('扫码错误: $error');
      },
    ),
  ),
);
```

### 模态窗口方式

```dart
void _openScannerModal() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ScanQrcode(
        onScanSuccess: (result) {
          Navigator.of(context).pop(); // 关闭扫码页面
          _handleScanResult(result);
        },
        onScanError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        },
        hintText: '请将二维码放入扫描框内',
      ),
      fullscreenDialog: true, // 全屏模态
    ),
  );
}
```

## 自定义配置

### 自定义扫描框

```dart
ScanQrcode(
  showScanArea: true,              // 显示扫描框
  scanAreaColor: Colors.blue,      // 扫描框颜色
  scanAreaSize: 300.0,             // 扫描框大小
  onScanSuccess: (result) {
    // 处理扫码结果
  },
)
```

### 控制按钮配置

```dart
ScanQrcode(
  showFlashButton: true,           // 显示闪光灯按钮
  showGalleryButton: true,         // 显示相册按钮
  onScanSuccess: (result) {
    // 处理扫码结果
  },
)
```

### 添加提示文字

```dart
ScanQrcode(
  hintText: '请将二维码对准扫描框',
  onScanSuccess: (result) {
    // 处理扫码结果
  },
)
```

## 完整示例

```dart
class ScanQrcodeExample extends StatefulWidget {
  @override
  _ScanQrcodeExampleState createState() => _ScanQrcodeExampleState();
}

class _ScanQrcodeExampleState extends State<ScanQrcodeExample> {
  String? scanResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('扫码示例')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 显示扫码结果
            if (scanResult != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '扫码结果:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(scanResult!),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: scanResult!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('已复制到剪贴板')),
                          );
                        },
                        child: Text('复制结果'),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 20),

            // 开始扫码按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _startScan,
                icon: Icon(Icons.qr_code_scanner),
                label: Text('开始扫码'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanQrcode(
          onScanSuccess: (result) {
            Navigator.pop(context);
            setState(() {
              scanResult = result;
            });
            _showResultDialog(result);
          },
          onScanError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red,
              ),
            );
          },
          showScanArea: true,
          scanAreaColor: Colors.green,
          scanAreaSize: 250.0,
          showFlashButton: true,
          showGalleryButton: true,
          hintText: '请将二维码放入扫描框内',
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('扫码成功'),
        content: Text('扫码结果：$result'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }
}
```

## 高级用法

### 自定义扫码界面

```dart
class CustomScanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScanQrcode(
      // 隐藏默认扫描框，使用自定义UI
      showScanArea: false,
      showFlashButton: false,
      showGalleryButton: false,
      onScanSuccess: (result) {
        // 处理扫码结果
        Navigator.pop(context, result);
      },
      onScanError: (error) {
        // 处理扫码错误
        print('扫码失败: $error');
      },
    );
  }
}
```

### 批量扫码

```dart
class BatchScanExample extends StatefulWidget {
  @override
  _BatchScanExampleState createState() => _BatchScanExampleState();
}

class _BatchScanExampleState extends State<BatchScanExample> {
  List<String> scanResults = [];

  void _startBatchScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanQrcode(
          onScanSuccess: (result) {
            // 不关闭页面，继续扫码
            if (!scanResults.contains(result)) {
              setState(() {
                scanResults.add(result);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已添加: $result'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
          hintText: '继续扫描更多二维码',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('批量扫码'),
        actions: [
          IconButton(
            onPressed: _startBatchScan,
            icon: Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: scanResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.qr_code),
            title: Text(scanResults[index]),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  scanResults.removeAt(index);
                });
              },
              icon: Icon(Icons.delete),
            ),
          );
        },
      ),
    );
  }
}
```

## API 参考

### ScanQrcode 属性

| 属性                | 类型                | 默认值         | 说明                         |
| ------------------- | ------------------- | -------------- | ---------------------------- |
| `onScanSuccess`     | `Function(String)?` | `null`         | 扫码成功回调，参数为扫码结果 |
| `onScanError`       | `Function(String)?` | `null`         | 扫码失败回调，参数为错误信息 |
| `showScanArea`      | `bool`              | `true`         | 是否显示扫描框               |
| `scanAreaColor`     | `Color`             | `Colors.green` | 扫描框颜色                   |
| `scanAreaSize`      | `double`            | `250.0`        | 扫描框大小                   |
| `showFlashButton`   | `bool`              | `true`         | 是否显示闪光灯按钮           |
| `showGalleryButton` | `bool`              | `true`         | 是否显示相册按钮             |
| `hintText`          | `String?`           | `null`         | 提示文字                     |

### 回调函数

#### onScanSuccess

```dart
Function(String result)? onScanSuccess
```

扫码成功时触发，参数 `result` 为扫码得到的字符串内容。

#### onScanError

```dart
Function(String error)? onScanError
```

扫码失败时触发，参数 `error` 为错误信息字符串。

## 扫描框自定义

### ScannerOverlayPainter 参数

组件内部使用 `ScannerOverlayPainter` 绘制扫描框，支持以下自定义参数：

- `borderColor`: 边框颜色
- `borderLength`: 边框长度 (默认 30.0)
- `borderWidth`: 边框宽度 (默认 10.0)
- `cutOutSize`: 扫描区域大小

### 扫描框样式

扫描框采用四角边框设计，中间为透明区域，周围为半透明遮罩，突出扫描区域。

## 权限处理

### 相机权限

组件会自动请求相机权限，如果用户拒绝授权，会通过 `onScanError` 回调通知。

### 相册权限

当用户点击相册按钮时，会自动请求相册访问权限。

### 权限被拒绝的处理

```dart
ScanQrcode(
  onScanError: (error) {
    if (error.contains('权限')) {
      // 引导用户到设置页面开启权限
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('权限提示'),
          content: Text('请在设置中开启相机权限'),
          actions: [
            TextButton(
              onPressed: () {
                // 打开应用设置页面
                openAppSettings();
              },
              child: Text('去设置'),
            ),
          ],
        ),
      );
    }
  },
)
```

## 性能优化

1. **相机资源管理**: 组件会自动管理相机资源，在页面销毁时释放
2. **重复扫码防护**: 内置防重复扫码机制，避免短时间内重复触发
3. **内存优化**: 相册图片分析后会及时释放内存

## 使用限制

1. **平台支持**: 仅支持 iOS 和 Android 平台
2. **权限要求**: 需要相机和相册访问权限
3. **网络要求**: 相册图片分析功能需要在本地进行，无需网络
4. **格式支持**: 支持常见的二维码格式，如 QR Code

## 最佳实践

1. **权限引导**: 在首次使用前向用户说明权限用途
2. **错误处理**: 提供友好的错误提示和处理方案
3. **用户体验**: 扫码成功后提供明确的反馈
4. **界面适配**: 考虑不同屏幕尺寸的适配
5. **性能考虑**: 避免在列表中频繁创建扫码组件

## 常见问题

### Q: 扫码识别率低怎么办？

A: 确保二维码清晰、光线充足，可以使用闪光灯辅助。

### Q: 如何支持条形码扫描？

A: 当前版本主要针对二维码优化，条形码支持有限。

### Q: 可以自定义扫码界面吗？

A: 可以通过设置 `showScanArea`、`showFlashButton` 等参数隐藏默认 UI，实现自定义界面。

### Q: 如何处理扫码结果？

A: 在 `onScanSuccess` 回调中处理扫码结果，可以进行数据验证、网络请求等操作。

## 注意事项

- 首次使用需要用户授权相机权限
- 在模拟器上可能无法正常使用相机功能
- 扫码页面会占用整个屏幕，注意导航逻辑
- 相册选择功能需要相册访问权限
- 组件会自动处理相机资源的创建和销毁
