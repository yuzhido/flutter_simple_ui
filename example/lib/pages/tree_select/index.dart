import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

class TreeSelectPage extends StatefulWidget {
  const TreeSelectPage({super.key});
  @override
  State<TreeSelectPage> createState() => _TreeSelectPageState();
}

class _TreeSelectPageState extends State<TreeSelectPage> {
  // 单选选中的数据
  SelectData<String>? singleSelectedItem;
  // 多选选中的数据
  List<SelectData<String>> multipleSelectedItems = [];
  // 本地过滤选中的数据
  SelectData<String>? localFilterSelectedItem;
  // 远程搜索选中的数据
  SelectData<String>? remoteSearchSelectedItem;
  // 懒加载选中的数据
  SelectData<String>? lazyLoadSelectedItem;

  // 模拟树形数据
  final List<SelectData<String>> treeData = [
    SelectData(
      label: '北京市',
      value: 'beijing',
      data: 'beijing',
      hasChildren: true,
      children: [
        SelectData(label: '朝阳区', value: 'chaoyang', data: 'chaoyang'),
        SelectData(label: '海淀区', value: 'haidian', data: 'haidian'),
        SelectData(label: '西城区', value: 'xicheng', data: 'xicheng'),
      ],
    ),
    SelectData(
      label: '上海市',
      value: 'shanghai',
      data: 'shanghai',
      hasChildren: true,
      children: [
        SelectData(label: '浦东新区', value: 'pudong', data: 'pudong'),
        SelectData(label: '黄浦区', value: 'huangpu', data: 'huangpu'),
        SelectData(label: '徐汇区', value: 'xuhui', data: 'xuhui'),
      ],
    ),
    SelectData(
      label: '广州市',
      value: 'guangzhou',
      data: 'guangzhou',
      hasChildren: true,
      children: [
        SelectData(label: '天河区', value: 'tianhe', data: 'tianhe'),
        SelectData(label: '越秀区', value: 'yuexiu', data: 'yuexiu'),
        SelectData(label: '荔湾区', value: 'liwan', data: 'liwan'),
      ],
    ),
    SelectData(
      label: '深圳市',
      value: 'shenzhen',
      data: 'shenzhen',
      hasChildren: true,
      children: [
        SelectData(label: '南山区', value: 'nanshan', data: 'nanshan'),
        SelectData(label: '福田区', value: 'futian', data: 'futian'),
        SelectData(label: '罗湖区', value: 'luohu', data: 'luohu'),
      ],
    ),
  ];

  // 懒加载模式的初始数据（只有第一级，不包含children）
  final List<SelectData<String>> lazyLoadData = [
    SelectData(
      label: '北京市',
      value: 'beijing',
      data: 'beijing',
      hasChildren: true, // 标记有子节点，但不提供children数据
    ),
    SelectData(label: '上海市', value: 'shanghai', data: 'shanghai', hasChildren: true),
    SelectData(label: '广州市', value: 'guangzhou', data: 'guangzhou', hasChildren: true),
    SelectData(label: '深圳市', value: 'shenzhen', data: 'shenzhen', hasChildren: true),
    SelectData(
      label: '杭州市',
      value: 'hangzhou',
      data: 'hangzhou',
      hasChildren: false, // 没有子节点的示例
    ),
  ];

  // 模拟远程搜索函数
  Future<List<SelectData<String>>> _mockRemoteSearch(String keyword) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    if (keyword.isEmpty) {
      return treeData;
    }

    // 模拟远程搜索结果
    List<SelectData<String>> results = [];

    // 根据关键字过滤数据
    for (final item in treeData) {
      if (item.label.toLowerCase().contains(keyword.toLowerCase())) {
        results.add(item);
      } else if (item.children != null) {
        // 检查子项是否匹配
        List<SelectData<String>> matchedChildren = [];
        for (final child in item.children!) {
          if (child.label.toLowerCase().contains(keyword.toLowerCase())) {
            matchedChildren.add(child);
          }
        }
        if (matchedChildren.isNotEmpty) {
          results.add(SelectData(label: item.label, value: item.value, data: item.data, hasChildren: item.hasChildren, children: matchedChildren));
        }
      }
    }

    return results;
  }

  // 模拟懒加载函数
  Future<List<SelectData<String>>> _mockLazyLoad(SelectData<String> parentItem) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 1200));

    // 根据父节点返回对应的子节点数据
    switch (parentItem.value) {
      case 'beijing':
        return [
          SelectData(label: '朝阳区', value: 'chaoyang', data: 'chaoyang', hasChildren: false),
          SelectData(label: '海淀区', value: 'haidian', data: 'haidian', hasChildren: false),
          SelectData(label: '西城区', value: 'xicheng', data: 'xicheng', hasChildren: false),
          SelectData(label: '东城区', value: 'dongcheng', data: 'dongcheng', hasChildren: false),
        ];
      case 'shanghai':
        return [
          SelectData(label: '浦东新区', value: 'pudong', data: 'pudong', hasChildren: false),
          SelectData(label: '黄浦区', value: 'huangpu', data: 'huangpu', hasChildren: false),
          SelectData(label: '徐汇区', value: 'xuhui', data: 'xuhui', hasChildren: false),
          SelectData(label: '长宁区', value: 'changning', data: 'changning', hasChildren: false),
        ];
      case 'guangzhou':
        return [
          SelectData(label: '天河区', value: 'tianhe', data: 'tianhe', hasChildren: false),
          SelectData(label: '越秀区', value: 'yuexiu', data: 'yuexiu', hasChildren: false),
          SelectData(label: '荔湾区', value: 'liwan', data: 'liwan', hasChildren: false),
          SelectData(label: '海珠区', value: 'haizhu', data: 'haizhu', hasChildren: false),
        ];
      case 'shenzhen':
        return [
          SelectData(label: '南山区', value: 'nanshan', data: 'nanshan', hasChildren: false),
          SelectData(label: '福田区', value: 'futian', data: 'futian', hasChildren: false),
          SelectData(label: '罗湖区', value: 'luohu', data: 'luohu', hasChildren: false),
          SelectData(label: '宝安区', value: 'baoan', data: 'baoan', hasChildren: false),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('树结构选择')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 单选示例
            const Text('单选模式示例', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TreeSelect<String>(title: '选择城市（单选）', options: treeData, multiple: false, onSingleChanged: (value, selectedItem, data) {}),
            const SizedBox(height: 16),

            // 显示单选结果
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('单选结果:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(singleSelectedItem != null ? '${singleSelectedItem!.label} (${singleSelectedItem!.value})' : '未选择'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 多选示例
            const Text('多选模式示例', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TreeSelect<String>(
              title: '选择城市（多选）',
              options: treeData,
              multiple: true,
              defaultValue: [treeData[0]], // 设置默认选中第一项
              onSingleChanged: (value, selectedItem, data) {},
            ),
            const SizedBox(height: 16),

            // 显示多选结果
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('多选结果:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  if (multipleSelectedItems.isEmpty)
                    const Text('未选择')
                  else
                    ...multipleSelectedItems.map((item) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text('• ${item.label} (${item.value})'))),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 本地过滤示例
            const Text('本地过滤示例', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TreeSelect<String>(
              title: '选择城市（本地过滤）',
              options: treeData,
              multiple: false,
              filterable: true, // 启用本地过滤
              onSingleChanged: (value, selectedItem, data) {},
            ),
            const SizedBox(height: 16),

            // 显示本地过滤结果
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('本地过滤结果:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(localFilterSelectedItem != null ? '${localFilterSelectedItem!.label} (${localFilterSelectedItem!.value})' : '未选择'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 远程搜索示例
            const Text('远程搜索示例', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TreeSelect<String>(
              title: '选择城市（远程搜索）',
              options: treeData,
              multiple: false,
              remote: true, // 启用远程搜索
              remoteFetch: _mockRemoteSearch, // 远程搜索函数
              onSingleChanged: (value, selectedItem, data) {},
            ),
            const SizedBox(height: 16),

            // 显示远程搜索结果
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('远程搜索结果:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(remoteSearchSelectedItem != null ? '${remoteSearchSelectedItem!.label} (${remoteSearchSelectedItem!.value})' : '未选择'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 懒加载示例
            const Text('懒加载示例', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TreeSelect<String>(
              title: '选择城市（懒加载）',
              options: lazyLoadData, // 使用懒加载数据
              multiple: false,
              lazyLoad: true, // 启用懒加载
              lazyLoadFetch: _mockLazyLoad, // 懒加载函数
              onSingleChanged: (value, selectedItem, data) {},
            ),
            const SizedBox(height: 16),

            // 显示懒加载结果
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('懒加载结果:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(lazyLoadSelectedItem != null ? '${lazyLoadSelectedItem!.label} (${lazyLoadSelectedItem!.value})' : '未选择'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        singleSelectedItem = null;
                        multipleSelectedItems.clear();
                        localFilterSelectedItem = null;
                        remoteSearchSelectedItem = null;
                        lazyLoadSelectedItem = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600], foregroundColor: Colors.white),
                    child: const Text('清空选择'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('选择结果'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('单选: ${singleSelectedItem?.label ?? '未选择'}'),
                              const SizedBox(height: 8),
                              Text('多选: ${multipleSelectedItems.map((e) => e.label).join(', ')}'),
                              const SizedBox(height: 8),
                              Text('本地过滤: ${localFilterSelectedItem?.label ?? '未选择'}'),
                              const SizedBox(height: 8),
                              Text('远程搜索: ${remoteSearchSelectedItem?.label ?? '未选择'}'),
                              const SizedBox(height: 8),
                              Text('懒加载: ${lazyLoadSelectedItem?.label ?? '未选择'}'),
                            ],
                          ),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定'))],
                        ),
                      );
                    },
                    child: const Text('查看结果'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
