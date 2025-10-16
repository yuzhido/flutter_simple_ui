# FileUpload 文件上传组件

一个功能强大的 Flutter 文件上传组件，支持多种文件来源、自定义上传逻辑、进度监控和多种显示样式。

## 示例展示

<img src="Snipaste_2025-10-15_14-28-12.png" width="300" alt="文件上传基本样式" />
<img src="Snipaste_2025-10-15_14-28-30.png" width="300" alt="文件上传卡片样式" />

## 功能特性

- 🔄 **多种文件来源**：支持文件选择、图片选择、拍照、网络文件等
- 📤 **自动/手动上传**：可配置自动上传或手动控制上传时机
- 📊 **上传进度监控**：实时显示上传进度和状态
- 🎨 **多种显示样式**：文本信息、卡片样式、自定义样式
- 🔧 **自定义上传逻辑**：支持自定义上传函数
- 📝 **文件信息管理**：完整的文件信息和状态管理
- 🚫 **文件数量限制**：可设置最大文件数量
- ❌ **失败处理**：上传失败时可选择是否移除文件

## 基础使用

### 简单文件上传

```dart
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

FileUpload(
  fileSource: FileSource.all,
  autoUpload: true,
  uploadConfig: UploadConfig(
    uploadUrl: 'https://your-api.com/upload',
    headers: {'Authorization': 'Bearer your-token'},
  ),
  onUploadSuccess: (file) {
    print('上传成功: ${file.name}');
  },
  onUploadFailed: (file, error) {
    print('上传失败: ${file.name}, 错误: $error');
  },
)
```

### 图片上传示例

```dart
FileUpload(
  fileSource: FileSource.image,
  fileListType: FileListType.card,
  limit: 5,
  uploadConfig: UploadConfig(
    uploadUrl: 'https://your-api.com/upload/image',
    fileFieldName: 'image',
    extraData: {'type': 'avatar'},
  ),
  onFileChange: (currentFile, selectedFiles, action) {
    print('文件${action}: ${currentFile.name}');
    print('当前文件列表: ${selectedFiles.length}个文件');
  },
)
```

### 自定义上传逻辑

```dart
FileUpload(
  fileSource: FileSource.all,
  autoUpload: true,
  customUpload: (filePath, onProgress) async {
    // 自定义上传逻辑
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(Duration(milliseconds: 100));
      onProgress(i / 100.0);
    }

    // 返回上传结果
    return FileUploadModel(
      name: filePath.split('/').last,
      path: filePath,
      status: UploadStatus.success,
      progress: 1.0,
      url: 'https://example.com/uploaded-file.jpg',
      fileInfo: FileInfo(
        id: DateTime.now().millisecondsSinceEpoch,
        fileName: filePath.split('/').last,
        requestPath: '/uploads/file.jpg',
      ),
    );
  },
  onUploadSuccess: (file) {
    print('自定义上传成功: ${file.url}');
  },
)
```

### 手动上传控制

```dart
class _MyWidgetState extends State<MyWidget> {
  final GlobalKey<FileUploadState> _fileUploadKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FileUpload(
          key: _fileUploadKey,
          autoUpload: false, // 关闭自动上传
          fileSource: FileSource.all,
          uploadConfig: UploadConfig(
            uploadUrl: 'https://your-api.com/upload',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // 手动触发上传
            _fileUploadKey.currentState?.uploadAllFiles();
          },
          child: Text('开始上传'),
        ),
      ],
    );
  }
}
```

### 自定义显示样式

```dart
FileUpload(
  fileListType: FileListType.custom,
  customAreaContent: (onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload, size: 48, color: Colors.blue),
            Text('点击上传文件'),
            Text('支持图片、文档等格式', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  },
)
```

### 预设默认文件

```dart
FileUpload(
  defaultValue: [
    FileUploadModel(
      name: '已上传的文件.pdf',
      path: '/path/to/file.pdf',
      status: UploadStatus.success,
      url: 'https://example.com/file.pdf',
      fileInfo: FileInfo(
        id: 1,
        fileName: '已上传的文件.pdf',
        requestPath: '/uploads/file.pdf',
      ),
    ),
  ],
  fileSource: FileSource.file,
)
```

## API 参考

### FileUpload 属性

| 属性                | 类型                                                           | 默认值                  | 说明                                             |
| ------------------- | -------------------------------------------------------------- | ----------------------- | ------------------------------------------------ |
| `onFileChange`      | `Function(FileUploadModel, List<FileUploadModel>, String)?`    | `null`                  | 文件变化回调，参数：当前文件、文件列表、操作类型 |
| `onUploadSuccess`   | `Function(FileUploadModel)?`                                   | `null`                  | 上传成功回调                                     |
| `onUploadFailed`    | `Function(FileUploadModel, String)?`                           | `null`                  | 上传失败回调                                     |
| `onUploadProgress`  | `Function(FileUploadModel, double)?`                           | `null`                  | 上传进度回调                                     |
| `uploadConfig`      | `UploadConfig?`                                                | `null`                  | 上传配置信息                                     |
| `fileSource`        | `FileSource`                                                   | `FileSource.all`        | 文件来源类型                                     |
| `customFileList`    | `Widget?`                                                      | `null`                  | 自定义文件列表样式                               |
| `customAreaContent` | `Widget Function(VoidCallback)?`                               | `null`                  | 自定义上传区域内容                               |
| `fileListType`      | `FileListType`                                                 | `FileListType.textInfo` | 文件列表显示类型                                 |
| `limit`             | `int`                                                          | `-1`                    | 文件数量限制，-1 表示无限制                      |
| `showFileList`      | `bool`                                                         | `true`                  | 是否显示文件列表                                 |
| `autoUpload`        | `bool`                                                         | `true`                  | 是否自动上传                                     |
| `isRemoveFailFile`  | `bool`                                                         | `false`                 | 上传失败时是否移除文件                           |
| `defaultValue`      | `List<FileUploadModel>?`                                       | `null`                  | 默认文件列表                                     |
| `uploadIcon`        | `Widget?`                                                      | `null`                  | 自定义上传区域图标                               |
| `uploadText`        | `String?`                                                      | `null`                  | 自定义上传区域文本                               |
| `customUpload`      | `Future<FileUploadModel?> Function(String, Function(double))?` | `null`                  | 自定义上传函数                                   |

### UploadConfig 配置

| 属性            | 类型                    | 默认值   | 说明               |
| --------------- | ----------------------- | -------- | ------------------ |
| `headers`       | `Map<String, String>?`  | `null`   | 请求头信息         |
| `uploadUrl`     | `String?`               | `null`   | 上传接口 URL       |
| `method`        | `String`                | `'POST'` | 请求方法           |
| `timeout`       | `int`                   | `30`     | 请求超时时间（秒） |
| `fileFieldName` | `String`                | `'file'` | 文件字段名         |
| `extraData`     | `Map<String, dynamic>?` | `null`   | 额外的表单数据     |

### FileUploadModel 文件模型

| 属性           | 类型            | 说明                 |
| -------------- | --------------- | -------------------- |
| `id`           | `String`        | 唯一标识 ID          |
| `fileInfo`     | `FileInfo?`     | 文件信息             |
| `name`         | `String`        | 文件名称             |
| `path`         | `String`        | 文件本地路径         |
| `source`       | `FileSource`    | 文件来源             |
| `status`       | `UploadStatus?` | 上传状态             |
| `progress`     | `double`        | 上传进度（0.0-1.0）  |
| `fileSize`     | `int?`          | 文件大小（字节）     |
| `fileSizeInfo` | `String?`       | 格式化的文件大小信息 |
| `url`          | `String?`       | 文件访问 URL         |
| `createTime`   | `DateTime?`     | 文件创建时间         |
| `updateTime`   | `DateTime?`     | 文件更新时间         |

### FileInfo 文件信息

| 属性          | 类型      | 说明     |
| ------------- | --------- | -------- |
| `id`          | `dynamic` | 文件 ID  |
| `fileName`    | `String`  | 文件名   |
| `requestPath` | `String`  | 请求路径 |

### 枚举类型

#### FileSource 文件来源

- `FileSource.all` - 允许所有类型：文件、图片、拍照
- `FileSource.file` - 只允许选择文件
- `FileSource.image` - 只允许选择图片
- `FileSource.camera` - 只允许拍照
- `FileSource.imageOrCamera` - 只允许选择图片或拍照
- `FileSource.network` - 网络文件

#### FileListType 文件列表类型

- `FileListType.textInfo` - 默认文本信息样式
- `FileListType.card` - 卡片样式
- `FileListType.custom` - 自定义样式

#### UploadStatus 上传状态

- `UploadStatus.pending` - 等待上传
- `UploadStatus.uploading` - 上传中
- `UploadStatus.success` - 上传成功
- `UploadStatus.failed` - 上传失败

## 回调函数说明

### onFileChange

```dart
Function(FileUploadModel currentFile, List<FileUploadModel> selectedFiles, String action)?
```

- `currentFile`: 当前操作的文件
- `selectedFiles`: 当前已选择的文件列表
- `action`: 操作类型（'add' 或 'remove'）

### onUploadSuccess

```dart
Function(FileUploadModel file)?
```

- `file`: 上传成功的文件模型

### onUploadFailed

```dart
Function(FileUploadModel file, String error)?
```

- `file`: 上传失败的文件模型
- `error`: 错误信息

### onUploadProgress

```dart
Function(FileUploadModel file, double progress)?
```

- `file`: 正在上传的文件模型
- `progress`: 上传进度（0.0-1.0）

### customUpload

```dart
Future<FileUploadModel?> Function(String filePath, Function(double) onProgress)?
```

- `filePath`: 文件路径
- `onProgress`: 进度回调函数
- 返回值: 上传成功返回更新后的 FileUploadModel，失败返回 null

## 使用限制

1. **自动上传配置**: 当 `autoUpload` 为 `true` 时，必须提供 `uploadConfig` 或 `customUpload`
2. **文件数量限制**: 当达到 `limit` 限制时，无法继续添加文件
3. **文件来源限制**: 根据 `fileSource` 设置，限制可选择的文件类型
4. **自定义样式**: 当 `fileListType` 为 `FileListType.custom` 时，需要提供 `customAreaContent`

## 最佳实践

1. **错误处理**: 始终实现 `onUploadFailed` 回调来处理上传失败的情况
2. **进度显示**: 使用 `onUploadProgress` 为用户提供上传进度反馈
3. **文件验证**: 在服务端验证文件类型、大小等安全性
4. **网络处理**: 考虑网络异常情况，提供重试机制
5. **用户体验**: 合理设置 `limit` 和 `timeout` 参数

## 注意事项

- 组件会自动处理文件选择和上传流程
- 上传失败的文件可以通过 `isRemoveFailFile` 控制是否自动移除
- 自定义上传函数需要正确处理进度回调和返回值
- 文件模型的 `id` 字段用于前端操作，与后端 ID 分离管理
- 支持同时显示已上传文件和正在上传的文件
