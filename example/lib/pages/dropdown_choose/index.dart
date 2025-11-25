import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';
import '../../api/user_api.dart';
import '../../api/city_api.dart';
import '../../api/models/user.dart';

// 复杂数据类型示例
class UserModel {
  final int id;
  final String name;
  final String email;
  final String department;

  UserModel({required this.id, required this.name, required this.email, required this.department});

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email, department: $department)';
}

class DropdownChoosePage extends StatefulWidget {
  const DropdownChoosePage({super.key});
  @override
  State<DropdownChoosePage> createState() => _DropdownChoosePageState();
}

class _DropdownChoosePageState extends State<DropdownChoosePage> {
  // 基础示例数据
  final List<SelectData<String>> fruitOptions = [
    SelectData(label: '苹果', value: 'apple', data: 'apple'),
    SelectData(label: '香蕉', value: 'banana', data: 'banana'),
    SelectData(label: '橙子', value: 'orange', data: 'orange'),
    SelectData(label: '葡萄', value: 'grape', data: 'grape'),
    SelectData(label: '草莓', value: 'strawberry', data: 'strawberry'),
    SelectData(label: '蓝莓', value: 'blueberry', data: 'blueberry'),
    SelectData(label: '芒果', value: 'mango', data: 'mango'),
    SelectData(label: '西瓜', value: 'watermelon', data: 'watermelon'),
  ];

  // 复杂数据类型示例数据
  final List<SelectData<UserModel>> userOptions = [
    SelectData(
      label: '张三 (技术部)',
      value: 1,
      data: UserModel(id: 1, name: '张三', email: 'zhangsan@example.com', department: '技术部'),
    ),
    SelectData(
      label: '李四 (产品部)',
      value: 2,
      data: UserModel(id: 2, name: '李四', email: 'lisi@example.com', department: '产品部'),
    ),
    SelectData(
      label: '王五 (设计部)',
      value: 3,
      data: UserModel(id: 3, name: '王五', email: 'wangwu@example.com', department: '设计部'),
    ),
    SelectData(
      label: '赵六 (运营部)',
      value: 4,
      data: UserModel(id: 4, name: '赵六', email: 'zhaoliu@example.com', department: '运营部'),
    ),
  ];

  // 各种示例的选中值
  SelectData<String>? basicSingleValue;
  List<SelectData<String>> basicMultipleValues = [];
  SelectData<String>? filterableSingleValue;
  List<SelectData<String>> filterableMultipleValues = [];
  SelectData<String>? remoteSingleValue;
  List<SelectData<String>> remoteMultipleValues = [];
  SelectData<String>? addButtonValue;
  SelectData<UserModel>? complexSingleValue;
  List<SelectData<UserModel>> complexMultipleValues = [];

  final DropdownChooseController basicSingleController = DropdownChooseController();
  final DropdownChooseController basicMultipleController = DropdownChooseController();
  final DropdownChooseController remoteSingleController = DropdownChooseController();

  @override
  void initState() {
    super.initState();
    // 设置一些默认值进行测试
    basicSingleValue = fruitOptions[1]; // 默认选中香蕉
    basicMultipleValues = [fruitOptions[0], fruitOptions[2]]; // 默认选中苹果和橙子
    complexSingleValue = userOptions[0]; // 默认选中张三
  }

  // 模拟远程搜索方法
  Future<List<SelectData<String>>> _remoteSearch(String query) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟搜索结果
    final allFruits = [
      ...fruitOptions,
      SelectData(label: '柠檬', value: 'lemon', data: 'lemon'),
      SelectData(label: '桃子', value: 'peach', data: 'peach'),
      SelectData(label: '梨子', value: 'pear', data: 'pear'),
      SelectData(label: '樱桃', value: 'cherry', data: 'cherry'),
    ];

    return allFruits.where((option) => option.label.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // 远程搜索用户信息
  Future<List<SelectData<User>>> _remoteSearchUsers(String query) async {
    try {
      // 调用真实的用户API
      final response = await UserApi.getUserList(page: 1, limit: 20, name: query.isNotEmpty ? query : null);

      // 检查响应结构
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> usersData = response['data'];

        // 将JSON数据转换为User对象，然后转换为SelectData格式
        return usersData.map((userJson) {
          final user = User.fromJson(userJson);
          return SelectData<User>(label: '${user.name} (${user.school ?? '未知学校'})', value: user.id.toString(), data: user);
        }).toList();
      }
      return [];
    } catch (e) {
      // 如果请求失败，返回空列表
      print('远程搜索用户失败: $e');
      return [];
    }
  }

  // 远程搜索城市信息
  Future<List<SelectData<City>>> _remoteSearchCities(String query) async {
    try {
      // 调用真实的城市API
      final response = await CityApi.getCityList(page: 1, limit: 20, name: query.isNotEmpty ? query : null);

      // 检查响应结构
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> citiesData = response['data'];

        // 将JSON数据转换为City对象，然后转换为SelectData格式
        return citiesData.map((cityJson) {
          final city = City.fromJson(cityJson);
          return SelectData<City>(label: '${city.name} (${city.province ?? '未知省份'})', value: city.id.toString(), data: city);
        }).toList();
      }
      return [];
    } catch (e) {
      // 如果请求失败，返回空列表
      print('远程搜索城市失败: $e');
      return [];
    }
  }

  // 显示添加对话框
  _showAddDialog(keyword) {
    print('keyword: $keyword');
    showDialog(
      context: context,
      builder: (context) {
        String newFruit = '';
        return AlertDialog(
          title: const Text('添加新水果'),
          content: TextField(
            onChanged: (value) {
              newFruit = value;
            },
            decoration: const InputDecoration(hintText: '请输入水果名称'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (newFruit.isNotEmpty) {
                  final newOption = SelectData(label: newFruit, value: newFruit.toLowerCase().replaceAll(' ', '_'), data: newFruit);
                  setState(() {
                    fruitOptions.add(newOption);
                    addButtonValue = newOption;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DropdownChoose 示例')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 基础单选示例
            _buildSectionTitle('1. 基础单选示例'),
            DropdownChoose<String>(
              options: fruitOptions,
              defaultValue: basicSingleValue,
              controller: basicSingleController,
              showClear: true,
              onClear: () {
                setState(() {
                  basicSingleValue = null;
                });
              },
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  basicSingleValue = selectData;
                });
              },
              tips: '请选择水果',
            ),
            Row(
              children: [TextButton(onPressed: () => basicSingleController.clear(), child: const Text('清空'))],
            ),
            _buildResultText('选中的值: ${basicSingleValue?.label ?? '无'}'),
            const SizedBox(height: 24),

            // 2. 基础多选示例
            _buildSectionTitle('2. 基础多选示例'),
            DropdownChoose<String>(
              options: fruitOptions,
              multiple: true,
              defaultValue: basicMultipleValues,
              controller: basicMultipleController,
              showClear: true,
              onClear: () {
                setState(() {
                  basicMultipleValues = [];
                });
              },
              onMultipleChanged: (values, datas, selectDatas) {
                setState(() {
                  basicMultipleValues = selectDatas;
                });
              },
              tips: '请选择水果（多选）',
            ),
            Row(
              children: [TextButton(onPressed: () => basicMultipleController.clear(), child: const Text('清空'))],
            ),
            _buildResultText('选中的值: ${basicMultipleValues.map((e) => e.label).join(', ')}'),
            const SizedBox(height: 24),

            // 3. 可过滤单选示例
            _buildSectionTitle('3. 可过滤单选示例'),
            DropdownChoose<String>(
              options: fruitOptions,
              filterable: true,
              defaultValue: filterableSingleValue,
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  filterableSingleValue = selectData;
                });
              },
              tips: '请输入或选择水果',
            ),
            _buildResultText('选中的值: ${filterableSingleValue?.label ?? '无'}'),
            const SizedBox(height: 24),

            // 4. 可过滤多选示例
            _buildSectionTitle('4. 可过滤多选示例'),
            DropdownChoose<String>(
              options: fruitOptions,
              filterable: true,
              multiple: true,
              defaultValue: filterableMultipleValues,
              onMultipleChanged: (values, datas, selectDatas) {
                setState(() {
                  filterableMultipleValues = selectDatas;
                });
              },
              tips: '请输入或选择水果（多选）',
            ),
            _buildResultText('选中的值: ${filterableMultipleValues.map((e) => e.label).join(', ')}'),
            const SizedBox(height: 24),

            // 5. 远程搜索单选示例
            _buildSectionTitle('5. 远程搜索单选示例'),
            DropdownChoose<String>(
              remote: true,
              remoteSearch: _remoteSearch,
              defaultValue: remoteSingleValue,
              controller: remoteSingleController,
              showClear: true,
              onClear: () {
                setState(() {
                  remoteSingleValue = null;
                });
              },
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  remoteSingleValue = selectData;
                });
              },
              tips: '请输入搜索关键词',
            ),
            Row(
              children: [TextButton(onPressed: () => remoteSingleController.clear(), child: const Text('清空'))],
            ),
            _buildResultText('选中的值: ${remoteSingleValue?.label ?? '无'}'),
            const SizedBox(height: 24),

            // 6. 远程搜索多选示例
            _buildSectionTitle('6. 远程搜索多选示例'),
            DropdownChoose<String>(
              remote: true,
              multiple: true,
              remoteSearch: _remoteSearch,
              defaultValue: remoteMultipleValues,
              onMultipleChanged: (values, datas, selectDatas) {
                setState(() {
                  remoteMultipleValues = selectDatas;
                });
              },
              tips: '请输入搜索关键词（多选）',
            ),
            _buildResultText('选中的值: ${remoteMultipleValues.map((e) => e.label).join(', ')}'),
            const SizedBox(height: 24),

            // 7. 带添加按钮的示例
            _buildSectionTitle('7. 带添加按钮的示例'),
            DropdownChoose<String>(
              options: fruitOptions,
              showAdd: true,
              remote: true,
              remoteSearch: _remoteSearch,
              defaultValue: addButtonValue,
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  addButtonValue = selectData;
                });
              },
              onAdd: (keyword) => _showAddDialog(keyword),
              tips: '请选择或添加水果',
            ),
            _buildResultText('选中的值: ${addButtonValue?.label ?? '无'}'),
            const SizedBox(height: 24),

            // 8. 复杂数据类型单选示例
            _buildSectionTitle('8. 复杂数据类型单选示例'),
            DropdownChoose<UserModel>(
              options: userOptions,
              defaultValue: complexSingleValue,
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  complexSingleValue = selectData;
                });
              },
              tips: '请选择用户',
            ),
            _buildResultText('选中的用户: ${complexSingleValue?.data.name ?? '无'} (${complexSingleValue?.data.department ?? ''})'),
            const SizedBox(height: 24),

            // 9. 复杂数据类型多选示例
            _buildSectionTitle('9. 复杂数据类型多选示例'),
            DropdownChoose<UserModel>(
              options: userOptions,
              multiple: true,
              defaultValue: complexMultipleValues,
              onMultipleChanged: (values, datas, selectDatas) {
                setState(() {
                  complexMultipleValues = selectDatas;
                });
              },
              tips: '请选择用户（多选）',
            ),
            _buildResultText('选中的用户: ${complexMultipleValues.map((e) => '${e.data.name}(${e.data.department})').join(', ')}'),
            const SizedBox(height: 24),

            // 10. 远程搜索 + 可过滤 + 多选组合示例
            _buildSectionTitle('10. 远程搜索 + 可过滤 + 多选组合示例'),
            DropdownChoose<String>(
              remote: true,
              multiple: true,
              remoteSearch: _remoteSearch,
              onMultipleChanged: (values, datas, selectDatas) {
                setState(() {
                  // 这里不设置状态，仅作为演示
                });
              },
              tips: '远程搜索 + 过滤 + 多选',
            ),
            _buildResultText('这是一个功能组合示例，展示了远程搜索、过滤和多选的组合使用'),
            const SizedBox(height: 40),

            // 真实接口示例 - 远程搜索用户信息
            _buildSectionTitle('真实接口示例 - 远程搜索用户信息'),
            DropdownChoose<User>(
              remote: true,
              remoteSearch: _remoteSearchUsers,
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  // 处理用户选择
                });
              },
              tips: '搜索用户信息（姓名、学校等）',
            ),
            _buildResultText('使用真实的getUserList接口进行远程搜索，支持按姓名、学校等条件搜索用户'),
            const SizedBox(height: 20),

            // 真实接口示例 - 远程搜索城市信息
            _buildSectionTitle('真实接口示例 - 远程搜索城市信息'),
            DropdownChoose<City>(
              remote: true,
              remoteSearch: _remoteSearchCities,
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  // 处理城市选择
                });
              },
              tips: '搜索城市信息（城市名、省份等）',
            ),
            _buildResultText('使用真实的getCityList接口进行远程搜索，支持按城市名、省份等条件搜索城市'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildResultText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ),
    );
  }
}
