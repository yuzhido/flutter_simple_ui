import 'package:flutter/material.dart';

class DatabaseDemoPage extends StatefulWidget {
  const DatabaseDemoPage({super.key});
  @override
  State<DatabaseDemoPage> createState() => _DatabaseDemoPageState();
}

class _DatabaseDemoPageState extends State<DatabaseDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航栏标题')),
      body: const Text('页面内容正在开发中...'),
    );
  }
}
