import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';
import 'package:example/utils/config.dart';

class CustomFileUploadExample extends StatefulWidget {
  const CustomFileUploadExample({super.key});

  @override
  State<CustomFileUploadExample> createState() => _CustomFileUploadExampleState();
}

class _CustomFileUploadExampleState extends State<CustomFileUploadExample> {
  List<FileUploadModel> customFiles1 = [];
  List<FileUploadModel> customFiles2 = [];
  List<FileUploadModel> customFiles3 = [];
  String _uploadStatus = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自定义上传区域示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 功能说明
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '自定义上传区域功能说明',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 支持完全自定义上传区域样式\n'
                    '• 可自定义文件列表展示方式\n'
                    '• 灵活的布局和交互设计\n'
                    '• 支持各种文件来源和限制',
                    style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 示例1：自定义拖拽上传区域
            _buildExampleCard(
              title: '1. 自定义拖拽上传区域（真实接口）',
              description: '使用真实接口上传文件，支持进度显示和错误处理',
              child: Column(
                children: [
                  FileUpload(
                    fileListType: FileListType.custom,
                    autoUpload: true,
                    limit: 5,
                    customUpload: _customUploadFunction,
                    onUploadSuccess: (file) {
                      print('✅ 自定义上传成功 - 文件: ${file.name}');
                      setState(() {
                        _uploadStatus = '✅ ${file.name} 上传成功！';
                      });
                    },
                    onUploadFailed: (file, error) {
                      print('❌ 自定义上传失败 - 文件: ${file.name}, 错误: $error');
                      setState(() {
                        _uploadStatus = '❌ ${file.name} 上传失败: $error';
                      });
                    },
                    onUploadProgress: (file, progress) {
                      print('📤 自定义上传进度 - 文件: ${file.name}, 进度: ${(progress * 100).toInt()}%');
                      setState(() {
                        _uploadStatus = '📤 ${file.name} 上传中: ${(progress * 100).toInt()}%';
                      });
                    },
                    onFileChange: (file, files, action) {
                      setState(() {
                        customFiles1 = files;
                      });
                      print('文件变更: $action, 当前文件数: ${files.length}');
                    },
                    customAreaContent: (onTap) => Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.shade300, width: 2, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue.shade50,
                      ),
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.blue.shade600),
                            const SizedBox(height: 8),
                            Text(
                              '拖拽文件到此处或点击选择',
                              style: TextStyle(fontSize: 16, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text('支持多种文件格式，最多5个文件', style: TextStyle(fontSize: 12, color: Colors.blue.shade500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_uploadStatus.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
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
                      child: Text(_uploadStatus, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 示例2：卡片式自定义上传区域
            _buildExampleCard(
              title: '2. 卡片式自定义上传区域',
              description: '带阴影的卡片样式，更加精美',
              child: FileUpload(
                fileListType: FileListType.custom,
                autoUpload: false,
                fileSource: FileSource.image,
                limit: 3,
                onFileChange: (file, files, action) {
                  setState(() {
                    customFiles2 = files;
                  });
                  print('图片变更: $action, 当前图片数: ${files.length}');
                },
                customAreaContent: (onTap) => Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(colors: [Colors.purple.shade100, Colors.purple.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 32, color: Colors.purple.shade600),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '选择图片',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                              ),
                              Text('最多3张图片', style: TextStyle(fontSize: 12, color: Colors.purple.shade500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 示例3：自定义文件列表展示
            _buildExampleCard(
              title: '3. 自定义文件列表展示',
              description: '自定义上传区域 + 自定义文件列表样式',
              child: FileUpload(
                fileListType: FileListType.custom,
                autoUpload: false,
                limit: 4,
                onFileChange: (file, files, action) {
                  setState(() {
                    customFiles3 = files;
                  });
                  print('文件变更: $action, 当前文件数: ${files.length}');
                },
                customAreaContent: (onTap) => Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                          child: Icon(Icons.attach_file, color: Colors.green.shade700),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '添加附件',
                          style: TextStyle(fontSize: 16, color: Colors.green.shade700, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                customFileList: customFiles3.isEmpty
                    ? const SizedBox.shrink()
                    : Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('已选择的文件 (${customFiles3.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...customFiles3.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.insert_drive_file, color: Colors.blue.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(file.name, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          customFiles3.removeAt(index);
                                        });
                                      },
                                      icon: Icon(Icons.close, color: Colors.red.shade400, size: 18),
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // 文件统计信息
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('文件统计信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('示例1 - 拖拽上传区域: ${customFiles1.length} 个文件'),
                  Text('示例2 - 卡片式上传区域: ${customFiles2.length} 个图片'),
                  Text('示例3 - 自定义文件列表: ${customFiles3.length} 个文件'),
                  Text('总计: ${customFiles1.length + customFiles2.length + customFiles3.length} 个文件'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard({required String title, required String description, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            child,
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
      formData.fields.addAll([const MapEntry('category', 'document'), const MapEntry('description', '通过Flutter自定义上传区域上传')]);

      // 发送请求
      final response = await dio.request(
        '${Config.baseUrl}/upload/api/upload-file',
        data: formData,
        options: Options(method: 'POST', headers: {'Authorization': 'Bearer your-token-here'}),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            onProgress(progress);
          }
        },
      );

      if (response.statusCode == 200) {
        print('✅ 自定义上传成功！响应数据: ${response.data}');

        // 解析服务器响应
        final responseData = response.data;
        final serverUrl = responseData['url'] ?? responseData['path'] ?? 'https://picsum.photos/300/200?random=${DateTime.now().millisecondsSinceEpoch}';

        final fileInfo = FileInfo(id: DateTime.now().millisecondsSinceEpoch, fileName: fileName, requestPath: responseData['path'] ?? '');

        return FileUploadModel(fileInfo: fileInfo, name: fileName, path: serverUrl, status: UploadStatus.success, progress: 1.0, url: serverUrl);
      } else {
        print('❌ 自定义上传失败：HTTP状态码 ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ 自定义上传异常: $e');
      return null;
    }
  }
}
