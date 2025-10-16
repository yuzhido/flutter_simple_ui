import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/select_data.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';
import '../../api/user_api.dart';
import '../../api/models/user.dart';
import '../../api/hobby_api.dart';
import '../../utils/add_data/add_hobby.dart';

class RemoteSearchDemoPage extends StatefulWidget {
  const RemoteSearchDemoPage({super.key});
  @override
  State<RemoteSearchDemoPage> createState() => _RemoteSearchDemoPageState();
}

class _RemoteSearchDemoPageState extends State<RemoteSearchDemoPage> {
  // 选中的值
  SelectData<User>? selectedRealUser; // 真实API用户
  SelectData<User>? selectedAlwaysRefreshUser; // 总是刷新的用户
  SelectData<Hobby>? selectedHobby; // 真实API爱好

  // 真实API用户搜索
  Future<List<SelectData<User>>> _searchRealUsers(String keyword) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      print('开始搜索用户，关键字: $keyword');

      // 调用真实API
      final response = await UserApi.getUserList(
        page: 1,
        limit: 20, // 限制返回数量
        name: keyword.isNotEmpty ? keyword : null,
      );

      print('API响应: $response');

      // 更安全的解析API响应
      final bool success = response['success'] == true;
      final dynamic data = response['data'];

      if (success && data is List) {
        // data 直接是用户数组
        final List<SelectData<User>> result = [];

        for (int i = 0; i < data.length; i++) {
          try {
            final dynamic userJson = data[i];
            if (userJson is Map<String, dynamic>) {
              final user = User.fromJson(userJson);

              // 确保用户数据有效
              if (user.name != null && user.name!.isNotEmpty) {
                result.add(SelectData<User>(label: '${user.name} - ${user.school ?? '未知学校'} (${user.age ?? 0}岁)', value: user.id ?? 'user_$i', data: user));
              }
            }
          } catch (e) {
            print('解析用户数据失败 (索引 $i): $e');
            continue; // 跳过这个用户，继续处理下一个
          }
        }

        print('成功解析 ${result.length} 个用户');
        return result;
      } else if (success && data is Map<String, dynamic>) {
        // data 是对象，包含 list 字段
        final dynamic listData = data['list'];

        if (listData is List) {
          final List<SelectData<User>> result = [];

          for (int i = 0; i < listData.length; i++) {
            try {
              final dynamic userJson = listData[i];
              if (userJson is Map<String, dynamic>) {
                final user = User.fromJson(userJson);

                // 确保用户数据有效
                if (user.name != null && user.name!.isNotEmpty) {
                  result.add(SelectData<User>(label: '${user.name} - ${user.school ?? '未知学校'} (${user.age ?? 0}岁)', value: user.id ?? 'user_$i', data: user));
                }
              }
            } catch (e) {
              print('解析用户数据失败 (索引 $i): $e');
              continue; // 跳过这个用户，继续处理下一个
            }
          }

          print('成功解析 ${result.length} 个用户');
          return result;
        } else {
          print('API返回的list字段不是数组类型: ${listData.runtimeType}');
          return [];
        }
      } else {
        print('API返回失败或data字段格式不正确: success=$success, data=${data.runtimeType}');
        return [];
      }
    } catch (e, stackTrace) {
      // 网络错误或其他异常，返回空列表
      print('搜索用户失败: $e');
      print('堆栈跟踪: $stackTrace');
      return [];
    }
  }

  // 真实API爱好搜索
  Future<List<SelectData<Hobby>>> _searchHobbies(String keyword) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      print('开始搜索爱好，关键字: $keyword');

      // 调用真实API
      final response = await HobbyApi.getHobbyList(
        page: 1,
        limit: 20, // 限制返回数量
        keyword: keyword.isNotEmpty ? keyword : null,
      );

      print('爱好API响应: $response');

      // 更安全的解析API响应
      final bool success = response['success'] == true;
      final dynamic data = response['data'];

      if (success && data is List) {
        // data 直接是爱好数组
        final List<SelectData<Hobby>> result = [];

        for (int i = 0; i < data.length; i++) {
          try {
            final dynamic hobbyJson = data[i];
            if (hobbyJson is Map<String, dynamic>) {
              final hobby = Hobby.fromJson(hobbyJson);

              // 确保爱好数据有效
              if (hobby.name != null && hobby.name!.isNotEmpty) {
                result.add(SelectData<Hobby>(label: hobby.name!, value: hobby.id ?? 'hobby_$i', data: hobby));
              }
            }
          } catch (e) {
            print('解析爱好数据失败 (索引 $i): $e');
            continue; // 跳过这个爱好，继续处理下一个
          }
        }

        print('成功解析 ${result.length} 个爱好');
        return result;
      } else if (success && data is Map<String, dynamic>) {
        // data 是对象，包含 list 字段
        final dynamic listData = data['list'];

        if (listData is List) {
          final List<SelectData<Hobby>> result = [];

          for (int i = 0; i < listData.length; i++) {
            try {
              final dynamic hobbyJson = listData[i];
              if (hobbyJson is Map<String, dynamic>) {
                final hobby = Hobby.fromJson(hobbyJson);

                // 确保爱好数据有效
                if (hobby.name != null && hobby.name!.isNotEmpty) {
                  result.add(SelectData<Hobby>(label: hobby.name!, value: hobby.id ?? 'hobby_$i', data: hobby));
                }
              }
            } catch (e) {
              print('解析爱好数据失败 (索引 $i): $e');
              continue; // 跳过这个爱好，继续处理下一个
            }
          }

          print('成功解析 ${result.length} 个爱好');
          return result;
        } else {
          print('API返回的list字段不是数组类型: ${listData.runtimeType}');
          return [];
        }
      } else {
        print('API返回失败或data字段格式不正确: success=$success, data=${data.runtimeType}');
        return [];
      }
    } catch (e, stackTrace) {
      // 网络错误或其他异常，返回空列表
      print('搜索爱好失败: $e');
      print('堆栈跟踪: $stackTrace');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DropdownChoose 真实API远程搜索演示'), backgroundColor: Colors.blue[600], foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面说明
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        '真实API远程搜索功能说明',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• 使用真实的UserApi.getUserList接口进行远程搜索\n'
                    '• 支持按用户姓名进行模糊搜索\n'
                    '• 点击弹窗时才加载数据，避免不必要的请求\n'
                    '• 自动缓存搜索结果，提升用户体验\n'
                    '• 支持alwaysRefresh配置，可选择每次都获取最新数据\n'
                    '• 完善的错误处理和异常容错机制',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 真实API示例
            _buildSectionTitle('真实API远程搜索', Icons.cloud),
            const SizedBox(height: 8),
            _buildDescription('使用真实的UserApi.getUserList接口搜索用户数据'),
            const SizedBox(height: 12),
            DropdownChoose<User>(
              remote: true,
              remoteSearch: _searchRealUsers,
              defaultValue: selectedRealUser,
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  selectedRealUser = selectData;
                });
              },
              tips: '请输入用户姓名搜索',
            ),
            _buildResultCard(
              '选中的用户',
              selectedRealUser != null ? '${selectedRealUser!.data.name} - ${selectedRealUser!.data.school} - ${selectedRealUser!.data.age}岁' : '未选择',
              Colors.teal,
            ),

            const SizedBox(height: 24),

            // 爱好远程搜索示例
            _buildSectionTitle('爱好远程搜索', Icons.favorite),
            const SizedBox(height: 8),
            _buildDescription('使用真实的HobbyApi.getHobbyList接口搜索爱好数据'),
            const SizedBox(height: 12),
            DropdownChoose<Hobby>(
              remote: true,
              showAdd: true,
              onAdd: (val) => showAddHobbyDialog(context, initialName: val),
              remoteSearch: _searchHobbies,
              defaultValue: selectedHobby,
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  selectedHobby = selectData;
                });
              },
              tips: '请输入爱好关键字搜索',
            ),
            _buildResultCard('选中的爱好', selectedHobby != null ? selectedHobby!.data.name ?? '未命名' : '未选择', Colors.purple),

            // alwaysRefresh 示例
            _buildSectionTitle('总是刷新数据示例', Icons.refresh),
            const SizedBox(height: 8),
            _buildDescription('设置alwaysRefresh=true，每次打开弹窗都会重新获取最新数据'),
            const SizedBox(height: 12),
            DropdownChoose<User>(
              remote: true,
              alwaysRefresh: true, // 总是刷新数据
              remoteSearch: _searchRealUsers,
              defaultValue: selectedAlwaysRefreshUser,
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  selectedAlwaysRefreshUser = selectData;
                });
              },
              tips: '每次打开都会刷新数据',
            ),
            _buildResultCard(
              '选中的用户（总是刷新）',
              selectedAlwaysRefreshUser != null
                  ? '${selectedAlwaysRefreshUser!.data.name} - ${selectedAlwaysRefreshUser!.data.school} - ${selectedAlwaysRefreshUser!.data.age}岁'
                  : '未选择',
              Colors.orange,
            ),

            const SizedBox(height: 24),

            // 技术特性说明
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      Text(
                        '技术特性',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• 懒加载：点击弹窗时才发起API请求，避免页面初始化时的无用请求\n'
                    '• 缓存机制：首次搜索结果会被缓存，再次打开弹窗时直接使用缓存数据\n'
                    '• 总是刷新：设置alwaysRefresh=true时，每次打开弹窗都重新获取最新数据\n'
                    '• 防抖处理：避免频繁的网络请求\n'
                    '• 智能加载：空关键字时加载默认数据，有关键字时进行搜索\n'
                    '• 错误处理：网络异常时优雅降级，不影响用户体验\n'
                    '• 数据转换：自动处理API响应数据的类型转换和安全解析\n'
                    '• 异常容错：API调用失败时返回空列表，保证组件稳定性',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[600], size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600]));
  }

  Widget _buildResultCard(String title, String content, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
