import 'package:example/pages/file_upload/index.dart';
import 'package:example/pages/file_upload/all_example.dart';
import 'package:example/pages/file_upload/custom_example.dart';
import 'package:flutter/material.dart';

class FileUploadExamplePage extends StatefulWidget {
  const FileUploadExamplePage({super.key});
  @override
  State<FileUploadExamplePage> createState() => _FileUploadExamplePageState();
}

class _FileUploadExamplePageState extends State<FileUploadExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文件上传示例')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 基础使用示例
            Card(
              child: ListTile(
                leading: const Icon(Icons.upload_file, color: Colors.blue),
                title: const Text('基础文件上传示例'),
                subtitle: const Text('查看FileUpload组件的基本使用方法'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FileUploadPage()));
                },
              ),
            ),

            const SizedBox(height: 16),

            // 完整示例
            Card(
              child: ListTile(
                leading: const Icon(Icons.library_books, color: Colors.green),
                title: const Text('完整功能示例'),
                subtitle: const Text('查看FileUpload组件的所有功能和配置选项'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AllExamplePage()));
                },
              ),
            ),

            const SizedBox(height: 16),

            // 自定义上传区域示例
            Card(
              child: ListTile(
                leading: const Icon(Icons.design_services, color: Colors.purple),
                title: const Text('自定义上传区域示例'),
                subtitle: const Text('查看如何自定义上传区域和文件列表样式'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomFileUploadExample()));
                },
              ),
            ),

            const SizedBox(height: 24),

            // 功能说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'FileUpload 组件功能',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('• 支持多种文件来源：文件选择、图片选择、拍照'),
                  const Text('• 支持卡片和文本信息两种展示样式'),
                  const Text('• 支持文件数量限制和自动上传'),
                  const Text('• 支持自定义上传配置和上传函数'),
                  const Text('• 支持上传进度监听和状态回调'),
                  const Text('• 支持预设文件列表和自定义上传区域'),
                  const Text('• 支持上传失败自动移除文件'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
