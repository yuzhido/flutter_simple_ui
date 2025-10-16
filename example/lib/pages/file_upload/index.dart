import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';
import 'package:example/utils/config.dart';

class FileUploadPage extends StatefulWidget {
  const FileUploadPage({super.key});
  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  String _uploadStatus = '';
  String _compressionStatus = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文件上传示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 自定义上传真实接口示例
            const Text('1. 自定义上传真实接口示例', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('使用 Dio 进行真实的 HTTP 上传，支持进度显示和错误处理', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),

            FileUpload(fileListType: FileListType.card, customUpload: _customUploadFunction),

            if (_uploadStatus.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _uploadStatus.startsWith('✅')
                      ? Colors.green.shade50
                      : _uploadStatus.startsWith('❌')
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
                  border: Border.all(
                    color: _uploadStatus.startsWith('✅')
                        ? Colors.green
                        : _uploadStatus.startsWith('❌')
                        ? Colors.red
                        : Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_uploadStatus),
              ),
            ],

            const SizedBox(height: 32),

            // 2. 标准上传配置示例
            const Text('2. 标准上传配置示例', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('使用 UploadConfig 配置上传 URL 和请求头', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),

            FileUpload(
              fileListType: FileListType.textInfo,
              uploadConfig: UploadConfig(
                uploadUrl: '${Config.baseUrl}/upload/api/upload-file',
                headers: {'Authorization': 'Bearer your-token-here', 'X-Custom-Header': 'custom-value'},
                timeout: 30, // 30秒超时
              ),
              onUploadSuccess: (file) {
                print('✅ 标准上传成功 - 文件: ${file.name}');
              },
              onUploadFailed: (file, error) {
                print('❌ 标准上传失败 - 文件: ${file.name}, 错误: $error');
              },
              onUploadProgress: (file, progress) {
                print('📤 标准上传进度 - 文件: ${file.name}, 进度: ${(progress * 100).toInt()}%');
              },
            ),

            const SizedBox(height: 32),

            // 3. 文件类型限制示例
            const Text('3. 文件类型和大小限制示例', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('限制只能上传图片文件，最多3个文件，每个文件最大5MB', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),

            FileUpload(
              fileListType: FileListType.card,
              fileSource: FileSource.image, // 只允许图片
              limit: 3, // 最多3个文件
              customUpload: _imageUploadFunction,
              onUploadSuccess: (file) {
                print('✅ 图片上传成功 - 文件: ${file.name}');
              },
              onUploadFailed: (file, error) {
                print('❌ 图片上传失败 - 文件: ${file.name}, 错误: $error');
              },
              onUploadProgress: (file, progress) {
                print('📤 图片上传进度 - 文件: ${file.name}, 进度: ${(progress * 100).toInt()}%');
              },
            ),

            const SizedBox(height: 32),

            // 4. 自定义图标和文本示例
            const Text('4. 自定义图标和文本示例', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('自定义上传区域的图标和提示文本', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),

            FileUpload(
              fileListType: FileListType.card,
              uploadIcon: const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.orange),
              uploadText: const Text(
                '点击上传文档\n支持 PDF、DOC、DOCX 格式',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.orange, fontWeight: FontWeight.w500),
              ),
              customUpload: _documentUploadFunction,
              onUploadSuccess: (file) {
                print('✅ 文档上传成功 - 文件: ${file.name}');
              },
              onUploadFailed: (file, error) {
                print('❌ 文档上传失败 - 文件: ${file.name}, 错误: $error');
              },
            ),

            const SizedBox(height: 32),

            // 5. 图片压缩上传示例
            const Text('5. 图片压缩上传示例', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('自动检测图片文件并进行智能压缩，根据文件大小选择合适的压缩配置', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),

            FileUpload(
              fileListType: FileListType.textInfo,
              fileSource: FileSource.image,
              customUpload: _compressAndUploadFunction,
              onUploadSuccess: (file) {
                print('✅ 图片压缩上传成功 - 文件: ${file.name}');
                setState(() {
                  _compressionStatus = '✅ ${file.name} 压缩上传成功！';
                });
              },
              onUploadFailed: (file, error) {
                print('❌ 图片压缩上传失败 - 文件: ${file.name}, 错误: $error');
                setState(() {
                  _compressionStatus = '❌ ${file.name} 压缩上传失败: $error';
                });
              },
              onUploadProgress: (file, progress) {
                print('📤 图片压缩上传进度 - 文件: ${file.name}, 进度: ${(progress * 100).toInt()}%');
                setState(() {
                  _compressionStatus = '📤 ${file.name} 压缩上传中: ${(progress * 100).toInt()}%';
                });
              },
            ),

            if (_compressionStatus.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _compressionStatus.startsWith('✅')
                      ? Colors.green.shade50
                      : _compressionStatus.startsWith('❌')
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
                  border: Border.all(
                    color: _compressionStatus.startsWith('✅')
                        ? Colors.green
                        : _compressionStatus.startsWith('❌')
                        ? Colors.red
                        : Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_compressionStatus),
              ),
            ],

            const SizedBox(height: 32),

            // 6. 失败文件自动移除示例
            const Text('6. 失败文件自动移除示例', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('上传失败的文件会自动从列表中移除', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),

            FileUpload(
              fileListType: FileListType.card,
              isRemoveFailFile: true, // 失败时自动移除
              customUpload: _failureTestUploadFunction,
              onUploadSuccess: (file) {
                print('✅ 测试上传成功 - 文件: ${file.name}');
              },
              onUploadFailed: (file, error) {
                print('❌ 测试上传失败 - 文件: ${file.name}, 错误: $error');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('文件 ${file.name} 上传失败已自动移除: $error'), backgroundColor: Colors.red));
              },
            ),

            const SizedBox(height: 32),

            // 7. 手动上传模式示例
            const Text('7. 手动上传模式示例', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('选择文件后不会自动上传，需要点击文件项手动触发上传', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),

            FileUpload(
              fileListType: FileListType.textInfo,
              autoUpload: false, // 关闭自动上传
              customUpload: _manualUploadFunction,
              onUploadSuccess: (file) {
                print('✅ 手动上传成功 - 文件: ${file.name}');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('文件 ${file.name} 上传成功！'), backgroundColor: Colors.green));
              },
              onUploadFailed: (file, error) {
                print('❌ 手动上传失败 - 文件: ${file.name}, 错误: $error');
              },
              onFileChange: (currentFile, selectedFiles, action) {
                if (action == 'add') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('文件已添加，点击文件项开始上传'), backgroundColor: Colors.blue));
                }
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 自定义上传函数 - 真实接口示例
  Future<FileUploadModel?> _customUploadFunction(String filePath, Function(double) onProgress) async {
    print('🚀 开始自定义上传文件: $filePath');

    try {
      final dio = Dio();

      // 准备表单数据
      final formData = FormData();

      // 获取文件名
      final fileName = filePath.split('/').last.split('\\').last;

      // 添加文件到表单数据
      formData.files.add(MapEntry('file', await MultipartFile.fromFile(filePath, filename: fileName)));

      // 可以添加其他表单字段
      formData.fields.addAll([const MapEntry('category', 'document'), const MapEntry('description', '通过Flutter上传')]);

      // 发送请求
      final response = await dio.request(
        '${Config.baseUrl}/upload/api/upload-file',
        data: formData,
        options: Options(method: 'POST', headers: {'Authorization': 'Bearer your-token-here'}),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            onProgress(progress);

            // print('📊 上传进度: ${(progress * 100).toInt()}%');
          }
        },
      );

      if (response.statusCode == 200) {
        print('✅ 上传成功！响应数据: ${response.data}');

        // 解析服务器响应
        final responseData = response.data;
        final serverUrl = responseData['url'] ?? responseData['path'] ?? 'https://picsum.photos/300/200?random=${DateTime.now().millisecondsSinceEpoch}';

        final fileInfo = FileInfo(id: DateTime.now().millisecondsSinceEpoch, fileName: fileName, requestPath: responseData['path'] ?? '');

        return FileUploadModel(fileInfo: fileInfo, name: fileName, path: serverUrl, status: UploadStatus.success, progress: 1.0, url: serverUrl);
      } else {
        print('❌ 上传失败：HTTP状态码 ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ 上传异常: $e');
      return null;
    }
  }

  /// 图片上传函数
  Future<FileUploadModel?> _imageUploadFunction(String filePath, Function(double) onProgress) async {
    print('🖼️ 开始上传图片: $filePath');

    // 模拟图片上传过程
    for (int i = 0; i <= 100; i += 20) {
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress(i / 100.0);
    }

    // 模拟成功
    final fileName = filePath.split('/').last.split('\\').last;
    return FileUploadModel(
      name: fileName,
      path: filePath,
      source: FileSource.image,
      status: UploadStatus.success,
      progress: 1.0,
      url: 'https://picsum.photos/300/200?random=${DateTime.now().millisecondsSinceEpoch}',
      fileInfo: FileInfo(id: DateTime.now().millisecondsSinceEpoch, fileName: fileName, requestPath: '/images/$fileName'),
    );
  }

  /// 文档上传函数
  Future<FileUploadModel?> _documentUploadFunction(String filePath, Function(double) onProgress) async {
    print('📄 开始上传文档: $filePath');

    // 模拟文档上传过程
    for (int i = 0; i <= 100; i += 25) {
      await Future.delayed(const Duration(milliseconds: 150));
      onProgress(i / 100.0);
    }

    final fileName = filePath.split('/').last.split('\\').last;
    return FileUploadModel(
      name: fileName,
      path: filePath,
      source: FileSource.file,
      status: UploadStatus.success,
      progress: 1.0,
      url: 'https://example.com/documents/$fileName',
      fileInfo: FileInfo(id: DateTime.now().millisecondsSinceEpoch, fileName: fileName, requestPath: '/documents/$fileName'),
    );
  }

  /// 图片压缩上传函数
  Future<FileUploadModel?> _compressAndUploadFunction(String filePath, Function(double) onProgress) async {
    print('🗜️ 开始压缩并上传图片: $filePath');

    try {
      // 模拟压缩过程
      onProgress(0.1);
      await Future.delayed(const Duration(milliseconds: 500));
      print('📦 图片压缩中...');

      onProgress(0.3);
      await Future.delayed(const Duration(milliseconds: 500));
      print('📦 压缩完成，开始上传...');

      // 模拟上传过程
      for (int i = 30; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        onProgress(i / 100.0);
      }

      final fileName = filePath.split('/').last.split('\\').last;
      return FileUploadModel(
        name: fileName,
        path: filePath,
        source: FileSource.image,
        status: UploadStatus.success,
        progress: 1.0,
        url: 'https://picsum.photos/300/200?random=${DateTime.now().millisecondsSinceEpoch}',
        fileInfo: FileInfo(id: DateTime.now().millisecondsSinceEpoch, fileName: fileName, requestPath: '/compressed/$fileName'),
      );
    } catch (e) {
      print('❌ 压缩上传异常: $e');
      return null;
    }
  }

  /// 失败测试上传函数
  Future<FileUploadModel?> _failureTestUploadFunction(String filePath, Function(double) onProgress) async {
    print('🧪 开始测试上传（模拟失败）: $filePath');

    // 模拟上传进度
    for (int i = 0; i <= 80; i += 20) {
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress(i / 100.0);
    }

    // 模拟上传失败
    await Future.delayed(const Duration(milliseconds: 500));
    print('❌ 模拟上传失败');
    return null; // 返回null表示失败
  }

  /// 手动上传函数
  Future<FileUploadModel?> _manualUploadFunction(String filePath, Function(double) onProgress) async {
    print('👆 手动上传文件: $filePath');

    // 模拟手动上传过程
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 150));
      onProgress(i / 100.0);
    }

    final fileName = filePath.split('/').last.split('\\').last;
    return FileUploadModel(
      name: fileName,
      path: filePath,
      source: FileSource.file,
      status: UploadStatus.success,
      progress: 1.0,
      url: 'https://example.com/manual/$fileName',
      fileInfo: FileInfo(id: DateTime.now().millisecondsSinceEpoch, fileName: fileName, requestPath: '/manual/$fileName'),
    );
  }
}
