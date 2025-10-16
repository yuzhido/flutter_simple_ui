import 'package:example/pages/tree_select/address_demo.dart';
import 'package:example/pages/tree_select/index.dart';
import 'package:example/pages/tree_select/new_tree_example.dart';
import 'package:flutter/material.dart';

class TreeSelectExamplePage extends StatefulWidget {
  const TreeSelectExamplePage({super.key});
  @override
  State<TreeSelectExamplePage> createState() => _TreeSelectExamplePageState();
}

class _TreeSelectExamplePageState extends State<TreeSelectExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('多级选择示例')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NewTreeExamplePage()));
            },
            child: Text('跳转查看最新树形选择（NewTreeExamplePage）示例'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TreeSelectPage()));
            },
            child: Text('跳转查看树形选择（TreeSelect）示例'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressDemoPage()));
            },
            child: Text('跳转查看树形选择（TreeSelect）示例（AddressDemoPage）'),
          ),
        ],
      ),
    );
  }
}
