import 'package:flutter/material.dart';
import '../../api/user_api.dart';
import '../../api/models/user.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});
  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<User> users = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await UserApi.getUserList(page: 1, limit: 20);

      // 更灵活的数据解析逻辑
      List<dynamic> userList = [];

      // 尝试多种可能的数据结构
      if (response['success'] == true) {
        // 根据实际API响应，数据直接在response.data中（是数组）
        if (response['data'] != null && response['data'] is List) {
          userList = response['data'] as List<dynamic>;
        }
        // 备选格式：response.data.list
        else if (response['data'] != null && response['data'] is Map && response['data']['list'] != null && response['data']['list'] is List) {
          userList = response['data']['list'] as List<dynamic>;
        }
        // 备选格式：response.list
        else if (response['list'] != null && response['list'] is List) {
          userList = response['list'] as List<dynamic>;
        }
        // 备选格式：response直接是数组
        else if (response is List) {
          userList = response as List<dynamic>;
        }

        if (userList.isEmpty) {
          setState(() {
            users = [];
            isLoading = false;
          });
        } else {
          // 解析用户数据
          final List<User> parsedUsers = [];
          for (int i = 0; i < userList.length; i++) {
            try {
              final user = User.fromJson(userList[i]);
              parsedUsers.add(user);
            } catch (e) {
              // 静默处理解析错误，继续处理下一个用户
            }
          }

          setState(() {
            users = parsedUsers;
            isLoading = false;
          });
        }
      } else {
        // API返回失败
        final errorMsg = response['message'] ?? response['error'] ?? '获取用户列表失败';
        setState(() {
          errorMessage = errorMsg;
          isLoading = false;
        });
      }
    } catch (e) {
      String errorMsg = '加载用户数据失败';

      // 根据不同的错误类型提供更具体的错误信息
      if (e.toString().contains('SocketException') || e.toString().contains('网络连接失败')) {
        errorMsg = '网络连接失败，请检查网络设置';
      } else if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
        errorMsg = '请求超时，请稍后重试';
      } else if (e.toString().contains('FormatException')) {
        errorMsg = '数据格式错误';
      }

      setState(() {
        errorMessage = '$errorMsg: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户管理页面'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers, tooltip: '刷新')],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.blue[50]!, Colors.white]),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('正在加载用户数据...')]),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 16, color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('重新加载'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无用户数据', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: UserInfo(user: users[index]),
          );
        },
      ),
    );
  }
}

class UserInfo extends StatelessWidget {
  final User user;

  const UserInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 头像区域
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Colors.blue[400]!, Colors.purple[400]!]),
                boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Center(
                child: Text(
                  (user.name?.isNotEmpty == true) ? user.name![0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 用户信息区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 姓名
                  Text(
                    user.name ?? '未知',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  // 年龄
                  if (user.age != null)
                    Row(
                      children: [_buildInfoChip(icon: Icons.cake, label: '${user.age}岁', color: Colors.orange)],
                    ),
                  if (user.age != null) const SizedBox(height: 8),
                  // 城市（从地址中提取）
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(_extractCityFromAddress(user.address) ?? '未知', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                  // 学校
                  if (user.school != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.school, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(user.school!, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // 更多信息按钮
            IconButton(
              onPressed: () {
                _showUserDetails(context);
              },
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            // 用户详细信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 用户头像和基本信息
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [Colors.blue[400]!, Colors.purple[400]!]),
                            ),
                            child: Center(
                              child: Text(
                                (user.name?.isNotEmpty == true) ? user.name![0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(user.name ?? '未知', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(user.age != null ? '${user.age}岁' : '年龄未知', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 详细信息
                    _buildDetailItem('城市', _extractCityFromAddress(user.address) ?? '未知', Icons.location_on),
                    if (user.school != null) _buildDetailItem('学校', user.school!, Icons.school),
                    if (user.address != null) _buildDetailItem('地址', user.address!, Icons.home),
                    if (user.birthday != null) _buildDetailItem('生日', user.birthday!, Icons.cake),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 从地址中提取城市名称
  String? _extractCityFromAddress(String? address) {
    if (address == null || address.isEmpty) return null;
    // 地址格式通常是 "城市名市,镇市,区市,县市,市市...路...号"
    // 提取第一个"市"之前的部分作为城市名
    final parts = address.split(',');
    if (parts.isNotEmpty) {
      String cityPart = parts[0];
      // 移除末尾的"市"字
      if (cityPart.endsWith('市')) {
        return cityPart.substring(0, cityPart.length - 1);
      }
      return cityPart;
    }
    return null;
  }
}
