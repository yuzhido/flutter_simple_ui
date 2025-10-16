import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequestPage extends StatefulWidget {
  const PermissionRequestPage({super.key});

  @override
  State<PermissionRequestPage> createState() => _PermissionRequestPageState();
}

class _PermissionRequestPageState extends State<PermissionRequestPage> {
  Map<Permission, PermissionStatus> _permissionStatuses = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permissions = [Permission.storage, Permission.manageExternalStorage];

    final statuses = <Permission, PermissionStatus>{};
    for (final permission in permissions) {
      statuses[permission] = await permission.status;
    }

    setState(() {
      _permissionStatuses = statuses;
      _isLoading = false;
    });
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      _permissionStatuses[permission] = status;
    });
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('权限请求'), backgroundColor: const Color(0xFF007AFF), foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('数据库功能需要以下权限：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // 存储权限
                  _buildPermissionCard('存储权限', '用于保存数据库文件', Permission.storage, Icons.storage),

                  const SizedBox(height: 16),

                  // 管理外部存储权限
                  _buildPermissionCard('管理外部存储权限', '用于访问应用专属目录', Permission.manageExternalStorage, Icons.folder_open),

                  const SizedBox(height: 24),

                  // 说明文字
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '说明：',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        SizedBox(height: 8),
                        Text('• 存储权限用于保存数据库文件到设备'),
                        Text('• 如果权限被拒绝，应用将使用内存数据库'),
                        Text('• 内存数据库在应用重启后会清空数据'),
                        Text('• 建议授予权限以获得更好的用户体验'),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 底部按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _openAppSettings,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('打开应用设置'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPermissionCard(String title, String description, Permission permission, IconData icon) {
    final status = _permissionStatuses[permission];
    final isGranted = status?.isGranted == true;
    final isDenied = status?.isDenied == true;
    final isPermanentlyDenied = status?.isPermanentlyDenied == true;

    Color statusColor;
    String statusText;
    Widget actionButton;

    if (isGranted) {
      statusColor = Colors.green;
      statusText = '已授予';
      actionButton = const Icon(Icons.check_circle, color: Colors.green, size: 24);
    } else if (isPermanentlyDenied) {
      statusColor = Colors.red;
      statusText = '永久拒绝';
      actionButton = ElevatedButton(
        onPressed: () => _openAppSettings(),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
        child: const Text('去设置'),
      );
    } else if (isDenied) {
      statusColor = Colors.orange;
      statusText = '已拒绝';
      actionButton = ElevatedButton(
        onPressed: () => _requestPermission(permission),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
        child: const Text('重新请求'),
      );
    } else {
      statusColor = Colors.grey;
      statusText = '未知';
      actionButton = ElevatedButton(onPressed: () => _requestPermission(permission), child: const Text('请求权限'));
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: statusColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            actionButton,
          ],
        ),
      ),
    );
  }
}
