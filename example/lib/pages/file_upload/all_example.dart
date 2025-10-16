import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

class AllExamplePage extends StatefulWidget {
  const AllExamplePage({super.key});
  @override
  State<AllExamplePage> createState() => _AllExamplePageState();
}

class _AllExamplePageState extends State<AllExamplePage> {
  List<FileUploadModel> selectedFiles0 = [];
  List<FileUploadModel> selectedFiles1 = [];
  List<FileUploadModel> selectedFiles2 = [];
  List<FileUploadModel> selectedFiles3 = [];
  List<FileUploadModel> selectedFiles4 = [];
  List<FileUploadModel> selectedFiles5 = [];
  List<FileUploadModel> selectedFiles6 = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FileUpload 组件示例')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 自定义上传区域示例
            _buildSection(
              title: '0. 自定义上传区域',
              description: '自定义上传按钮的图标和文本样式',
              child: FileUpload(
                fileListType: FileListType.custom,
                uploadIcon: const Icon(Icons.cloud_upload, size: 48, color: Colors.blue),
                uploadText: const Text(
                  '点击上传文件\n支持拖拽上传',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                autoUpload: false,
                onFileChange: (file, files, action) {
                  setState(() {
                    selectedFiles0 = files;
                  });
                  print('自定义上传区域文件变更: $action');
                },
              ),
            ),

            // 基础示例
            _buildSection(
              title: '1. 基础文件上传（卡片样式）',
              description: '默认配置，支持所有文件类型，卡片样式展示',
              child: FileUpload(
                fileListType: FileListType.card,
                autoUpload: false,
                onFileChange: (file, files, action) {
                  setState(() {
                    selectedFiles1 = files;
                  });
                  print('文件变更: $action, 当前文件数: ${files.length}');
                },
              ),
            ),

            // 文本信息样式
            _buildSection(
              title: '2. 文本信息样式',
              description: '使用文本信息样式展示文件列表',
              child: FileUpload(
                fileListType: FileListType.textInfo,
                autoUpload: false,
                onFileChange: (file, files, action) {
                  setState(() {
                    selectedFiles2 = files;
                  });
                },
              ),
            ),

            // 限制文件数量
            _buildSection(
              title: '3. 限制文件数量',
              description: '最多只能选择2个文件',
              child: FileUpload(
                limit: 2,
                autoUpload: false,
                onFileChange: (file, files, action) {
                  setState(() {
                    selectedFiles3 = files;
                  });
                },
              ),
            ),

            // 只允许图片
            _buildSection(
              title: '4. 只允许选择图片',
              description: '限制文件来源为图片',
              child: FileUpload(
                fileSource: FileSource.image,
                autoUpload: false,
                onFileChange: (file, files, action) {
                  setState(() {
                    selectedFiles4 = files;
                  });
                },
              ),
            ),

            // 图片或拍照
            _buildSection(
              title: '5. 图片选择或拍照',
              description: '支持从相册选择图片或拍照',
              child: FileUpload(
                fileSource: FileSource.imageOrCamera,
                autoUpload: false,
                onFileChange: (file, files, action) {
                  setState(() {
                    selectedFiles5 = files;
                  });
                },
              ),
            ),

            // 自定义上传配置
            _buildSection(
              title: '6. 自定义上传配置',
              description: '配置上传URL和自定义参数',
              child: FileUpload(
                uploadConfig: UploadConfig(uploadUrl: 'https://httpbin.org/post', headers: {'Authorization': 'Bearer token'}, extraData: {'userId': '123', 'category': 'document'}),
                onUploadSuccess: (file) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('文件 ${file.name} 上传成功')));
                },
                onUploadFailed: (file, error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('文件 ${file.name} 上传失败: $error')));
                },
                onUploadProgress: (file, progress) {
                  print('文件 ${file.name} 上传进度: ${(progress * 100).toInt()}%');
                },
                onFileChange: (file, files, action) {
                  setState(() {
                    selectedFiles6 = files;
                  });
                },
              ),
            ),

            // 自定义上传函数
            _buildSection(
              title: '7. 自定义上传函数',
              description: '使用自定义上传逻辑',
              child: FileUpload(
                customUpload: (filePath, onProgress) async {
                  // 模拟上传过程
                  for (int i = 0; i <= 100; i += 10) {
                    await Future.delayed(const Duration(milliseconds: 100));
                    onProgress(i / 100.0);
                  }

                  // 返回上传成功的文件信息
                  return FileUploadModel(
                    name: filePath.split('/').last,
                    path: filePath,
                    status: UploadStatus.success,
                    progress: 1.0,
                    url: 'https://example.com/uploaded/${filePath.split('/').last}',
                    fileInfo: FileInfo(id: DateTime.now().millisecondsSinceEpoch, fileName: filePath.split('/').last, requestPath: '/uploads/${filePath.split('/').last}'),
                  );
                },
                onUploadSuccess: (file) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('自定义上传成功: ${file.name}')));
                },
                onFileChange: (file, files, action) {
                  print('自定义上传文件变更: $action');
                },
              ),
            ),

            // 预设文件列表
            _buildSection(
              title: '8. 预设文件列表',
              description: '显示已上传的默认文件',
              child: FileUpload(
                defaultValue: [
                  FileUploadModel(
                    name: '预设文档.pdf',
                    path: '/default/document.pdf',
                    status: UploadStatus.success,
                    progress: 1.0,
                    url: 'https://example.com/document.pdf',
                    fileInfo: FileInfo(id: 'default_1', fileName: '预设文档.pdf', requestPath: '/uploads/document.pdf'),
                  ),
                  FileUploadModel(
                    name: '预设图片.jpg',
                    path: '/default/image.jpg',
                    status: UploadStatus.success,
                    progress: 1.0,
                    url: 'https://example.com/image.jpg',
                    fileInfo: FileInfo(id: 'default_2', fileName: '预设图片.jpg', requestPath: '/uploads/image.jpg'),
                  ),
                ],
                autoUpload: false,
                onFileChange: (file, files, action) {
                  print('预设文件列表变更: $action, 文件数: ${files.length}');
                },
              ),
            ),

            // 自定义上传区域
            _buildSection(
              title: '9. 自定义上传区域（高级）',
              description: '更多自定义上传按钮样式选项',
              child: FileUpload(
                uploadIcon: const Icon(Icons.file_upload_outlined, size: 32, color: Colors.green),
                uploadText: const Text(
                  '拖拽文件到此处\n或点击选择文件',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green, fontSize: 14),
                ),
                autoUpload: false,
                onFileChange: (file, files, action) {
                  print('高级自定义上传区域文件变更: $action');
                },
              ),
            ),

            // 上传失败自动移除
            _buildSection(
              title: '10. 上传失败自动移除',
              description: '上传失败时自动从列表中移除文件',
              child: FileUpload(
                isRemoveFailFile: true,
                uploadConfig: UploadConfig(uploadUrl: 'https://invalid-url-for-demo.com/upload'),
                onUploadFailed: (file, error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('文件已自动移除: ${file.name}')));
                },
                onFileChange: (file, files, action) {
                  print('失败移除示例文件变更: $action');
                },
              ),
            ),

            const SizedBox(height: 32),

            // 当前选择的文件信息
            _buildFileInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String description, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildFileInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '当前选择的文件统计',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text('自定义上传区域: ${selectedFiles0.length} 个文件'),
          Text('基础示例: ${selectedFiles1.length} 个文件'),
          Text('文本样式: ${selectedFiles2.length} 个文件'),
          Text('限制数量: ${selectedFiles3.length} 个文件'),
          Text('只允许图片: ${selectedFiles4.length} 个文件'),
          Text('图片或拍照: ${selectedFiles5.length} 个文件'),
          Text('自定义配置: ${selectedFiles6.length} 个文件'),
        ],
      ),
    );
  }
}
