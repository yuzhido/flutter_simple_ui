import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

class NoticeInfoPage extends StatefulWidget {
  const NoticeInfoPage({super.key});
  @override
  State<NoticeInfoPage> createState() => _NoticeInfoState();
}

class _NoticeInfoState extends State<NoticeInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('消息通知组件示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('基础用法:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const NoticeInfo(),

            const SizedBox(height: 24),
            const Text('自定义消息:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const NoticeInfo(message: '这是一条自定义消息通知'),

            const SizedBox(height: 24),
            const Text('带点击事件:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            NoticeInfo(
              message: '点击我查看详情',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('你点击了消息通知！')));
              },
            ),

            const SizedBox(height: 24),
            const Text('自定义样式:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const NoticeInfo(message: '自定义高度和内边距的通知', height: 60.0, padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0)),

            const SizedBox(height: 24),
            const Text('长文本消息:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const NoticeInfo(message: '这是一条很长的消息通知，用来测试文本换行和组件自适应能力，确保在不同长度的文本下都能正常显示。'),

            const SizedBox(height: 24),
            const Text('启用滚动功能:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const NoticeInfo(message: '这是一条超长的消息通知，当文本内容超出容器宽度时，会自动启用无限循环滚动功能，让用户能够看到完整的消息内容。', enableScroll: true),

            const SizedBox(height: 24),
            const Text('自定义滚动参数:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const NoticeInfo(
              message: '这条消息使用自定义的滚动速度和暂停时间，滚动速度更快，暂停时间更短，适合需要快速展示信息的场景。',
              enableScroll: true,
              scrollDuration: Duration(seconds: 5),
              pauseDuration: Duration(seconds: 1),
            ),

            const SizedBox(height: 24),
            const Text('超长文本滚动示例:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const NoticeInfo(
              message: '这是一条非常非常长的消息通知，包含了大量的文字内容，用来演示当文本内容远远超出容器宽度时的滚动效果。滚动功能会自动检测文本长度，只有在需要时才会启用，确保用户体验的流畅性。',
              enableScroll: true,
              scrollDuration: Duration(seconds: 8),
              pauseDuration: Duration(seconds: 3),
            ),
          ],
        ),
      ),
    );
  }
}
