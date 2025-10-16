import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

/// TreeSelect 实际使用场景示例
///
/// 展示在真实业务场景中如何使用TreeSelect组件：
/// 1. 组织架构选择
/// 2. 商品分类选择
/// 3. 地区选择器
/// 4. 权限管理
/// 5. 文件目录选择
class TreeSelectUseCasesExample extends StatefulWidget {
  const TreeSelectUseCasesExample({super.key});

  @override
  State<TreeSelectUseCasesExample> createState() => _TreeSelectUseCasesExampleState();
}

class _TreeSelectUseCasesExampleState extends State<TreeSelectUseCasesExample> {
  // 各种场景的选中结果
  SelectData<String>? selectedOrganization;
  SelectData<String>? selectedCategory;
  SelectData<String>? selectedRegion;
  List<SelectData<String>> selectedPermissions = [];
  SelectData<String>? selectedDirectory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TreeSelect 使用场景示例'), backgroundColor: Colors.indigo.shade600, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面介绍
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.indigo.shade50, Colors.blue.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business_center, color: Colors.indigo.shade600),
                      const SizedBox(width: 8),
                      Text(
                        '实际业务场景',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '本示例展示了TreeSelect组件在实际业务中的常见应用场景，'
                    '包括组织架构、商品分类、地区选择、权限管理等。每个场景都配置了'
                    '相应的数据结构和交互逻辑。',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 1. 组织架构选择
            _buildUseCaseSection(
              title: '组织架构选择',
              icon: Icons.account_tree,
              color: Colors.blue,
              description: '用于员工管理、权限分配等场景，支持按部门层级选择人员',
              child: TreeSelect<String>(
                title: '选择部门/员工',
                options: OrganizationData.getDepartments(),
                lazyLoad: true,
                lazyLoadFetch: OrganizationData.loadDepartmentMembers,
                onSingleChanged: (value, selectedItem, data) {},
              ),
              result: selectedOrganization,
            ),

            const SizedBox(height: 24),

            // 2. 商品分类选择
            _buildUseCaseSection(
              title: '商品分类选择',
              icon: Icons.category,
              color: Colors.orange,
              description: '电商平台商品分类管理，支持多级分类和搜索',
              child: TreeSelect<String>(
                title: '选择商品分类',
                options: ProductCategoryData.getMainCategories(),
                lazyLoad: true,
                lazyLoadFetch: ProductCategoryData.loadSubCategories,
                remote: true,
                remoteFetch: ProductCategoryData.searchCategories,
                hintText: '搜索分类名称',
                onSingleChanged: (value, selectedItem, data) {},
              ),
              result: selectedCategory,
            ),

            const SizedBox(height: 24),

            // 3. 地区选择器
            _buildUseCaseSection(
              title: '地区选择器',
              icon: Icons.location_on,
              color: Colors.green,
              description: '物流配送、用户注册等场景的地区选择',
              child: TreeSelect<String>(
                title: '选择收货地址',
                options: RegionData.getProvinces(),
                lazyLoad: true,
                lazyLoadFetch: RegionData.loadCities,
                onSingleChanged: (value, selectedItem, data) {},
              ),
              result: selectedRegion,
            ),

            const SizedBox(height: 24),

            // 4. 权限管理
            _buildUseCaseSection(
              title: '权限管理',
              icon: Icons.security,
              color: Colors.red,
              description: '角色权限分配，支持多选和层级权限继承',
              child: TreeSelect<String>(
                title: '分配权限',
                options: PermissionData.getPermissionGroups(),
                multiple: true,
                lazyLoad: true,
                lazyLoadFetch: PermissionData.loadPermissionItems,
                onSingleChanged: (value, selectedItem, data) {},
              ),
              result: null,
              multiResult: selectedPermissions,
            ),

            const SizedBox(height: 24),

            // 5. 文件目录选择
            _buildUseCaseSection(
              title: '文件目录选择',
              icon: Icons.folder,
              color: Colors.purple,
              description: '文件管理系统中的目录选择，支持懒加载文件夹结构',
              child: TreeSelect<String>(
                title: '选择保存目录',
                options: DirectoryData.getRootDirectories(),
                lazyLoad: true,
                lazyLoadFetch: DirectoryData.loadSubDirectories,
                onSingleChanged: (value, selectedItem, data) {},
              ),
              result: selectedDirectory,
            ),

            const SizedBox(height: 32),

            // 操作按钮区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _clearAllSelections,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('清空所有选择'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _exportSelections,
                          icon: const Icon(Icons.download),
                          label: const Text('导出选择结果'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showSelectionSummary,
                      icon: const Icon(Icons.summarize),
                      label: const Text('查看选择汇总'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUseCaseSection({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required Widget child,
    SelectData<String>? result,
    List<SelectData<String>>? multiResult,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区域
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                      ),
                      const SizedBox(height: 4),
                      Text(description, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 组件区域
          Padding(padding: const EdgeInsets.all(16), child: child),

          // 结果显示区域
          if (result != null || (multiResult != null && multiResult.isNotEmpty))
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '当前选择',
                        style: TextStyle(fontWeight: FontWeight.bold, color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (result != null) Text('${result.label} (${result.value})') else if (multiResult != null) ...multiResult.map((item) => Text('• ${item.label} (${item.value})')),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _clearAllSelections() {
    setState(() {
      selectedOrganization = null;
      selectedCategory = null;
      selectedRegion = null;
      selectedPermissions.clear();
      selectedDirectory = null;
    });
    _showSnackBar('已清空所有选择');
  }

  void _exportSelections() {
    final selections = {
      '组织架构': selectedOrganization?.label ?? '未选择',
      '商品分类': selectedCategory?.label ?? '未选择',
      '地区': selectedRegion?.label ?? '未选择',
      '权限': selectedPermissions.isEmpty ? '未选择' : selectedPermissions.map((e) => e.label).join(', '),
      '目录': selectedDirectory?.label ?? '未选择',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download, color: Colors.blue),
            SizedBox(width: 8),
            Text('导出结果'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selections.entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text: '${entry.key}: ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: entry.value),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('导出功能演示完成');
            },
            child: const Text('确认导出'),
          ),
        ],
      ),
    );
  }

  void _showSelectionSummary() {
    final hasSelections = selectedOrganization != null || selectedCategory != null || selectedRegion != null || selectedPermissions.isNotEmpty || selectedDirectory != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.summarize, color: Colors.indigo),
            SizedBox(width: 8),
            Text('选择汇总'),
          ],
        ),
        content: SingleChildScrollView(
          child: hasSelections
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedOrganization != null) _buildSummaryItem('组织架构', selectedOrganization!.label, Icons.account_tree),
                    if (selectedCategory != null) _buildSummaryItem('商品分类', selectedCategory!.label, Icons.category),
                    if (selectedRegion != null) _buildSummaryItem('地区', selectedRegion!.label, Icons.location_on),
                    if (selectedPermissions.isNotEmpty) _buildSummaryItem('权限', '${selectedPermissions.length} 项', Icons.security),
                    if (selectedDirectory != null) _buildSummaryItem('目录', selectedDirectory!.label, Icons.folder),
                  ],
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('暂无选择内容', style: TextStyle(color: Colors.grey)),
                  ],
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定'))],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating));
  }
}

// 组织架构数据
class OrganizationData {
  static List<SelectData<String>> getDepartments() {
    return [
      SelectData(label: '技术部', value: 'tech', data: 'tech', hasChildren: true),
      SelectData(label: '产品部', value: 'product', data: 'product', hasChildren: true),
      SelectData(label: '运营部', value: 'operation', data: 'operation', hasChildren: true),
      SelectData(label: '人事部', value: 'hr', data: 'hr', hasChildren: true),
      SelectData(label: '财务部', value: 'finance', data: 'finance', hasChildren: true),
    ];
  }

  static Future<List<SelectData<String>>> loadDepartmentMembers(SelectData<String> dept) async {
    await Future.delayed(const Duration(milliseconds: 800));

    switch (dept.value) {
      case 'tech':
        return [
          SelectData(label: '前端组', value: 'frontend_team', data: 'frontend_team', hasChildren: true),
          SelectData(label: '后端组', value: 'backend_team', data: 'backend_team', hasChildren: true),
          SelectData(label: '移动端组', value: 'mobile_team', data: 'mobile_team', hasChildren: true),
          SelectData(label: '测试组', value: 'qa_team', data: 'qa_team', hasChildren: true),
        ];
      case 'product':
        return [
          SelectData(label: '产品经理 - 张三', value: 'pm_zhangsan', data: 'pm_zhangsan'),
          SelectData(label: '产品经理 - 李四', value: 'pm_lisi', data: 'pm_lisi'),
          SelectData(label: 'UI设计师 - 王五', value: 'ui_wangwu', data: 'ui_wangwu'),
          SelectData(label: 'UX设计师 - 赵六', value: 'ux_zhaoliu', data: 'ux_zhaoliu'),
        ];
      case 'operation':
        return [
          SelectData(label: '运营专员 - 钱七', value: 'op_qianqi', data: 'op_qianqi'),
          SelectData(label: '市场推广 - 孙八', value: 'market_sunba', data: 'market_sunba'),
          SelectData(label: '数据分析师 - 周九', value: 'analyst_zhoujiu', data: 'analyst_zhoujiu'),
        ];
      case 'hr':
        return [SelectData(label: 'HR经理 - 吴十', value: 'hr_wushi', data: 'hr_wushi'), SelectData(label: '招聘专员 - 郑十一', value: 'recruiter_zhengshiyi', data: 'recruiter_zhengshiyi')];
      case 'finance':
        return [
          SelectData(label: '财务经理 - 王十二', value: 'finance_wangshier', data: 'finance_wangshier'),
          SelectData(label: '会计 - 李十三', value: 'accountant_lishisan', data: 'accountant_lishisan'),
        ];
      default:
        return [];
    }
  }
}

// 商品分类数据
class ProductCategoryData {
  static List<SelectData<String>> getMainCategories() {
    return [
      SelectData(label: '电子数码', value: 'electronics', data: 'electronics', hasChildren: true),
      SelectData(label: '服装鞋帽', value: 'clothing', data: 'clothing', hasChildren: true),
      SelectData(label: '家居生活', value: 'home', data: 'home', hasChildren: true),
      SelectData(label: '运动户外', value: 'sports', data: 'sports', hasChildren: true),
      SelectData(label: '图书音像', value: 'books', data: 'books', hasChildren: true),
    ];
  }

  static Future<List<SelectData<String>>> loadSubCategories(SelectData<String> category) async {
    await Future.delayed(const Duration(milliseconds: 600));

    switch (category.value) {
      case 'electronics':
        return [
          SelectData(label: '手机通讯', value: 'mobile', data: 'mobile', hasChildren: true),
          SelectData(label: '电脑办公', value: 'computer', data: 'computer', hasChildren: true),
          SelectData(label: '数码配件', value: 'accessories', data: 'accessories'),
        ];
      case 'clothing':
        return [
          SelectData(label: '男装', value: 'mens', data: 'mens', hasChildren: true),
          SelectData(label: '女装', value: 'womens', data: 'womens', hasChildren: true),
          SelectData(label: '童装', value: 'kids', data: 'kids'),
        ];
      case 'home':
        return [
          SelectData(label: '家具', value: 'furniture', data: 'furniture'),
          SelectData(label: '家电', value: 'appliances', data: 'appliances', hasChildren: true),
          SelectData(label: '厨具', value: 'kitchen', data: 'kitchen'),
        ];
      default:
        return [];
    }
  }

  static Future<List<SelectData<String>>> searchCategories(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final allCategories = [
      SelectData(label: '手机', value: 'phone', data: 'phone'),
      SelectData(label: '笔记本电脑', value: 'laptop', data: 'laptop'),
      SelectData(label: '平板电脑', value: 'tablet', data: 'tablet'),
      SelectData(label: '男士T恤', value: 'mens_tshirt', data: 'mens_tshirt'),
      SelectData(label: '女士连衣裙', value: 'womens_dress', data: 'womens_dress'),
      SelectData(label: '运动鞋', value: 'sneakers', data: 'sneakers'),
      SelectData(label: '沙发', value: 'sofa', data: 'sofa'),
      SelectData(label: '冰箱', value: 'refrigerator', data: 'refrigerator'),
    ];

    return allCategories.where((cat) => cat.label.contains(keyword)).toList();
  }
}

// 地区数据
class RegionData {
  static List<SelectData<String>> getProvinces() {
    return [
      SelectData(label: '北京市', value: 'beijing', data: 'beijing', hasChildren: true),
      SelectData(label: '上海市', value: 'shanghai', data: 'shanghai', hasChildren: true),
      SelectData(label: '广东省', value: 'guangdong', data: 'guangdong', hasChildren: true),
      SelectData(label: '浙江省', value: 'zhejiang', data: 'zhejiang', hasChildren: true),
      SelectData(label: '江苏省', value: 'jiangsu', data: 'jiangsu', hasChildren: true),
    ];
  }

  static Future<List<SelectData<String>>> loadCities(SelectData<String> province) async {
    await Future.delayed(const Duration(milliseconds: 700));

    switch (province.value) {
      case 'beijing':
        return [
          SelectData(label: '朝阳区', value: 'chaoyang', data: 'chaoyang'),
          SelectData(label: '海淀区', value: 'haidian', data: 'haidian'),
          SelectData(label: '西城区', value: 'xicheng', data: 'xicheng'),
          SelectData(label: '东城区', value: 'dongcheng', data: 'dongcheng'),
        ];
      case 'guangdong':
        return [
          SelectData(label: '广州市', value: 'guangzhou', data: 'guangzhou'),
          SelectData(label: '深圳市', value: 'shenzhen', data: 'shenzhen'),
          SelectData(label: '珠海市', value: 'zhuhai', data: 'zhuhai'),
          SelectData(label: '佛山市', value: 'foshan', data: 'foshan'),
        ];
      default:
        return [];
    }
  }
}

// 权限数据
class PermissionData {
  static List<SelectData<String>> getPermissionGroups() {
    return [
      SelectData(label: '用户管理', value: 'user_mgmt', data: 'user_mgmt', hasChildren: true),
      SelectData(label: '内容管理', value: 'content_mgmt', data: 'content_mgmt', hasChildren: true),
      SelectData(label: '系统设置', value: 'system_settings', data: 'system_settings', hasChildren: true),
      SelectData(label: '数据统计', value: 'analytics', data: 'analytics', hasChildren: true),
    ];
  }

  static Future<List<SelectData<String>>> loadPermissionItems(SelectData<String> group) async {
    await Future.delayed(const Duration(milliseconds: 500));

    switch (group.value) {
      case 'user_mgmt':
        return [
          SelectData(label: '查看用户', value: 'user_view', data: 'user_view'),
          SelectData(label: '创建用户', value: 'user_create', data: 'user_create'),
          SelectData(label: '编辑用户', value: 'user_edit', data: 'user_edit'),
          SelectData(label: '删除用户', value: 'user_delete', data: 'user_delete'),
        ];
      case 'content_mgmt':
        return [
          SelectData(label: '查看内容', value: 'content_view', data: 'content_view'),
          SelectData(label: '发布内容', value: 'content_publish', data: 'content_publish'),
          SelectData(label: '编辑内容', value: 'content_edit', data: 'content_edit'),
          SelectData(label: '删除内容', value: 'content_delete', data: 'content_delete'),
        ];
      case 'system_settings':
        return [
          SelectData(label: '系统配置', value: 'system_config', data: 'system_config'),
          SelectData(label: '备份恢复', value: 'backup_restore', data: 'backup_restore'),
          SelectData(label: '日志查看', value: 'log_view', data: 'log_view'),
        ];
      case 'analytics':
        return [
          SelectData(label: '用户统计', value: 'user_analytics', data: 'user_analytics'),
          SelectData(label: '内容统计', value: 'content_analytics', data: 'content_analytics'),
          SelectData(label: '系统统计', value: 'system_analytics', data: 'system_analytics'),
        ];
      default:
        return [];
    }
  }
}

// 目录数据
class DirectoryData {
  static List<SelectData<String>> getRootDirectories() {
    return [
      SelectData(label: '我的文档', value: 'documents', data: 'documents', hasChildren: true),
      SelectData(label: '项目文件', value: 'projects', data: 'projects', hasChildren: true),
      SelectData(label: '图片资源', value: 'images', data: 'images', hasChildren: true),
      SelectData(label: '视频文件', value: 'videos', data: 'videos', hasChildren: true),
    ];
  }

  static Future<List<SelectData<String>>> loadSubDirectories(SelectData<String> directory) async {
    await Future.delayed(const Duration(milliseconds: 600));

    switch (directory.value) {
      case 'documents':
        return [
          SelectData(label: '工作文档', value: 'work_docs', data: 'work_docs', hasChildren: true),
          SelectData(label: '个人文档', value: 'personal_docs', data: 'personal_docs'),
          SelectData(label: '临时文件', value: 'temp_files', data: 'temp_files'),
        ];
      case 'projects':
        return [
          SelectData(label: 'Flutter项目', value: 'flutter_projects', data: 'flutter_projects'),
          SelectData(label: 'Web项目', value: 'web_projects', data: 'web_projects'),
          SelectData(label: '移动端项目', value: 'mobile_projects', data: 'mobile_projects'),
        ];
      case 'images':
        return [
          SelectData(label: '产品图片', value: 'product_images', data: 'product_images'),
          SelectData(label: '用户头像', value: 'avatars', data: 'avatars'),
          SelectData(label: '背景图片', value: 'backgrounds', data: 'backgrounds'),
        ];
      default:
        return [];
    }
  }
}
