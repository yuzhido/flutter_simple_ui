import 'package:example/pages/table_show/index.dart';
import 'package:flutter/material.dart';

class TableShowExamplePage extends StatefulWidget {
  const TableShowExamplePage({super.key});
  @override
  State<TableShowExamplePage> createState() => _TableShowExamplePageState();
}

class _TableShowExamplePageState extends State<TableShowExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('表格展示示例')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TableShowPage())),
            child: const Text('表格展示（TableShow）示例'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
