import 'package:example/pages/config_form_example/index.dart';
import 'package:flutter/material.dart';

class ConfigFormExamplesPage extends StatefulWidget {
  const ConfigFormExamplesPage({super.key});
  @override
  State<ConfigFormExamplesPage> createState() => _ConfigFormExamplesPageState();
}

class _ConfigFormExamplesPageState extends State<ConfigFormExamplesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConfigForm 示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('选择要查看的示例：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigFormExamplePage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('基础配置示例'),
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 20),
            const Text('新配置系统特点：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              '• 每个字段类型都有专门的配置类\n'
              '• 只显示该字段类型相关的属性\n'
              '• 类型安全，避免配置错误\n'
              '• 代码更清晰，维护更容易\n'
              '• 支持更多字段类型和高级功能',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
