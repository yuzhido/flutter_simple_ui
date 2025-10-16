import 'package:example/pages/loading_data/index.dart';
import 'package:example/pages/user_list/index.dart';
import 'package:flutter/material.dart';

class FormBuilderExamplePage extends StatefulWidget {
  const FormBuilderExamplePage({super.key});
  @override
  State<FormBuilderExamplePage> createState() => _FormBuilderExamplePageState();
}

class _FormBuilderExamplePageState extends State<FormBuilderExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('表单构件示例')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UserListPage()));
            },
            child: Text('跳转查看数据驱动表单（UserListPage）用户管理页面示例'),
          ),
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoadingDataPage()));
            },
            child: Text('跳转查看数据驱动表单（LoadingDataPage）加载数据示例'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
