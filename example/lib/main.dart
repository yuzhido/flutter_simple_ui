import 'package:example/pages/cate_page/config_form_examples.dart';
import 'package:example/pages/cate_page/dropdown_choose_example.dart';
import 'package:example/pages/cate_page/file_upload_example.dart';
import 'package:example/pages/cate_page/form_builder_example.dart';
import 'package:example/pages/cate_page/table_show_example.dart';
import 'package:example/pages/cate_page/tree_select_example.dart';
import 'package:example/pages/notice_info/index.dart';
import 'package:example/pages/permission_request/index.dart';
import 'package:example/pages/scan_qrcode/index.dart';
import 'package:example/pages/tree_select/advanced_example.dart';
import 'package:example/pages/tree_select/use_cases_example.dart';
import 'package:example/pages/tree_select/new_tree_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple UI 组件示例',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: const [
        Locale('zh', 'CN'), // 中文
        Locale('en', 'US'), // 英文
      ],
      locale: const Locale('zh', 'CN'),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple UI 组件示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigFormExamplesPage())),
              child: const Text('配置表单（ConfigForm）示例'),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DropdownChooseExamplePage())),
              child: const Text('下拉选择（DropdownChoose）示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TableShowExamplePage())),
              child: const Text('表格展示（TableShow）示例'),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TreeSelectExamplePage())),
              child: const Text('多级选择（TreeSelect）示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TreeSelectAdvancedExample())),
              child: const Text('TreeSelect 高级示例（懒加载+远程搜索）'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TreeSelectUseCasesExample())),
              child: const Text('TreeSelect 业务场景示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewTreeExamplePage())),
              child: const Text('TreeSelect 完整功能示例'),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FileUploadExamplePage()));
              },
              child: Text('跳转查看文件上传相关示例'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NoticeInfoPage()));
              },
              child: Text('跳转查看消息通知（NoticeInfo）示例'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PermissionRequestPage()));
              },
              child: Text('跳转查看权限请求（PermissionRequest）示例'),
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FormBuilderExamplePage()));
              },
              child: Text('跳转查看表单构建（FormBuilder）示例'),
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanQrcodePage()));
              },
              child: Text('跳转查看扫码组件（ScanQrcode）示例'),
            ),
          ],
        ),
      ),
    );
  }
}
