import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

// 示例数据模型
class Department {
  final String id;
  final String name;
  final String? parentId;
  final int level;

  Department({required this.id, required this.name, this.parentId, required this.level});
}

class NewTreeExamplePage extends StatefulWidget {
  const NewTreeExamplePage({super.key});
  @override
  State<NewTreeExamplePage> createState() => _NewTreeExamplePageState();
}

class _NewTreeExamplePageState extends State<NewTreeExamplePage> {
  // 选中的值
  String? selectedCity;
  List<Department> selectedDepartments = [];
  List<SelectData<String>>? defaultValue = [SelectData<String>(label: '上海市', value: 'shanghai', data: 'shanghai')];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  // 设置默认值为北京市
  void _setDefaultToBeijing() {
    setState(() {
      defaultValue = [SelectData<String>(label: '北京市', value: 'beijing', data: 'beijing')];
      selectedCity = null; // 重置用户选择，显示新的默认值
    });
  }

  // 设置默认值为上海市
  void _setDefaultToShanghai() {
    setState(() {
      defaultValue = [SelectData<String>(label: '上海市', value: 'shanghai', data: 'shanghai')];
      selectedCity = null; // 重置用户选择，显示新的默认值
    });
  }

  // 清除默认值
  void _clearDefaultValue() {
    setState(() {
      defaultValue = null;
      selectedCity = null; // 重置用户选择
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TreeSelect 组件示例'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 示例1：带默认值的单选
            _buildSectionTitle('1. 带默认值的单选示例'),
            TreeSelect<String>(
              key: ValueKey(defaultValue?.first.value), // 添加key确保组件重新渲染
              title: '选择城市',
              hintText: '请选择一个城市',
              options: _getCityData(),
              defaultValue: defaultValue,
              onSingleChanged: (value, selectedItem, data) {},
            ),
            _buildResultDisplay('选中城市: ${selectedCity ?? defaultValue?.first.label ?? '无'}（${selectedCity == null ? (defaultValue != null ? '默认值' : '无选择') : '用户选择'}）'),

            const SizedBox(height: 16),

            // 控制按钮
            _buildSectionTitle('控制默认值'),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _setDefaultToBeijing,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text('设为北京'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _setDefaultToShanghai,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('设为上海'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearDefaultValue,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('清除默认值'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 示例2：多选模式
            _buildSectionTitle('2. 多选模式示例'),
            TreeSelect<Department>(title: '选择多个部门', hintText: '可以选择多个部门', multiple: true, options: _getDepartmentData(), onSingleChanged: (value, selectedItem, data) {}),
            _buildResultDisplay('选中部门: ${selectedDepartments.map((d) => d.name).join(', ')}'),
          ],
        ),
      ),
    );
  }

  // 构建章节标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  // 构建结果显示
  Widget _buildResultDisplay(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
    );
  }

  // 获取部门数据
  List<SelectData<Department>> _getDepartmentData() {
    final departments = [
      Department(id: '1', name: '技术部', level: 1),
      Department(id: '1-1', name: '前端组', parentId: '1', level: 2),
      Department(id: '1-2', name: '后端组', parentId: '1', level: 2),
      Department(id: '1-3', name: '测试组', parentId: '1', level: 2),
      Department(id: '1-1-1', name: 'React团队', parentId: '1-1', level: 3),
      Department(id: '1-1-2', name: 'Vue团队', parentId: '1-1', level: 3),
      Department(id: '1-2-1', name: 'Java团队', parentId: '1-2', level: 3),
      Department(id: '1-2-2', name: 'Python团队', parentId: '1-2', level: 3),
      Department(id: '2', name: '产品部', level: 1),
      Department(id: '2-1', name: '产品设计组', parentId: '2', level: 2),
      Department(id: '2-2', name: '用户体验组', parentId: '2', level: 2),
      Department(id: '3', name: '运营部', level: 1),
      Department(id: '3-1', name: '市场推广组', parentId: '3', level: 2),
      Department(id: '3-2', name: '客户服务组', parentId: '3', level: 2),
    ];

    return _buildTreeStructure(departments);
  }

  // 构建树形结构
  List<SelectData<Department>> _buildTreeStructure(List<Department> departments) {
    Map<String, List<Department>> childrenMap = {};

    // 按父ID分组
    for (var dept in departments) {
      String parentId = dept.parentId ?? 'root';
      childrenMap.putIfAbsent(parentId, () => []).add(dept);
    }

    // 递归构建树形结构
    List<SelectData<Department>> buildChildren(String parentId) {
      List<Department> children = childrenMap[parentId] ?? [];
      return children.map((dept) {
        List<SelectData<Department>> subChildren = buildChildren(dept.id);
        return SelectData<Department>(label: dept.name, value: dept.id, data: dept, hasChildren: subChildren.isNotEmpty, children: subChildren.isNotEmpty ? subChildren : null);
      }).toList();
    }

    return buildChildren('root');
  }

  // 获取城市数据
  List<SelectData<String>> _getCityData() {
    return [
      SelectData<String>(
        label: '北京市',
        value: 'beijing',
        data: 'beijing',
        hasChildren: true,
        children: [
          SelectData<String>(label: '朝阳区', value: 'beijing-chaoyang', data: 'beijing-chaoyang'),
          SelectData<String>(label: '海淀区', value: 'beijing-haidian', data: 'beijing-haidian'),
          SelectData<String>(label: '西城区', value: 'beijing-xicheng', data: 'beijing-xicheng'),
        ],
      ),
      SelectData<String>(
        label: '上海市',
        value: 'shanghai',
        data: 'shanghai',
        hasChildren: true,
        children: [
          SelectData<String>(label: '浦东新区', value: 'shanghai-pudong', data: 'shanghai-pudong'),
          SelectData<String>(label: '黄浦区', value: 'shanghai-huangpu', data: 'shanghai-huangpu'),
          SelectData<String>(label: '徐汇区', value: 'shanghai-xuhui', data: 'shanghai-xuhui'),
        ],
      ),
      SelectData<String>(
        label: '广东省',
        value: 'guangdong',
        data: 'guangdong',
        hasChildren: true,
        children: [
          SelectData<String>(
            label: '广州市',
            value: 'guangzhou',
            data: 'guangzhou',
            hasChildren: true,
            children: [
              SelectData<String>(label: '天河区', value: 'guangzhou-tianhe', data: 'guangzhou-tianhe'),
              SelectData<String>(label: '越秀区', value: 'guangzhou-yuexiu', data: 'guangzhou-yuexiu'),
            ],
          ),
          SelectData<String>(
            label: '深圳市',
            value: 'shenzhen',
            data: 'shenzhen',
            hasChildren: true,
            children: [
              SelectData<String>(label: '南山区', value: 'shenzhen-nanshan', data: 'shenzhen-nanshan'),
              SelectData<String>(label: '福田区', value: 'shenzhen-futian', data: 'shenzhen-futian'),
            ],
          ),
        ],
      ),
    ];
  }
}
