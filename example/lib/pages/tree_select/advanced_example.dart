import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

/// TreeSelect 懒加载和远程搜索综合示例
///
/// 本示例展示了以下功能：
/// 1. 懒加载模式 - 按需加载子节点数据
/// 2. 远程搜索模式 - 实时搜索远程数据
/// 3. 混合模式 - 懒加载 + 远程搜索
/// 4. 多种数据结构示例
class TreeSelectAdvancedExample extends StatefulWidget {
  const TreeSelectAdvancedExample({super.key});

  @override
  State<TreeSelectAdvancedExample> createState() => _TreeSelectAdvancedExampleState();
}

class _TreeSelectAdvancedExampleState extends State<TreeSelectAdvancedExample> {
  // 选中结果
  SelectData<String>? lazyLoadResult;
  SelectData<String>? remoteSearchResult;
  SelectData<String>? hybridResult;
  List<SelectData<String>> multiSelectResult = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TreeSelect 高级示例'), backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white),
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Text(
                        '功能说明',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('• 懒加载：点击展开时动态加载子节点数据'),
                  const Text('• 远程搜索：实时搜索远程API数据'),
                  const Text('• 混合模式：同时支持懒加载和远程搜索'),
                  const Text('• 加载状态：显示加载动画和状态提示'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 1. 纯懒加载示例
            _buildSectionTitle('1. 纯懒加载模式', Icons.expand_more, Colors.green),
            const SizedBox(height: 8),
            _buildDescription('点击城市展开时，动态加载区县数据。适用于大型树形结构，减少初始加载时间。'),
            const SizedBox(height: 12),
            TreeSelect<String>(
              title: '选择地区（懒加载）',
              options: MockDataService.getLazyLoadCities(),
              lazyLoad: true,
              lazyLoadFetch: MockDataService.loadCityDistricts,
              onSingleChanged: (value, item, data) {},
            ),
            const SizedBox(height: 12),
            _buildResultCard('懒加载结果', lazyLoadResult, Colors.green),

            const SizedBox(height: 32),

            // 2. 纯远程搜索示例
            _buildSectionTitle('2. 远程搜索模式', Icons.search, Colors.orange),
            const SizedBox(height: 8),
            _buildDescription('输入关键字实时搜索远程数据。适用于数据量大、需要实时搜索的场景。'),
            const SizedBox(height: 12),
            TreeSelect<String>(
              title: '纯远程搜索（启用缓存）',
              options: [], // 初始为空，通过搜索获取数据
              remote: true,
              isCacheData: true, // 启用缓存
              remoteFetch: MockDataService.searchEmployees,
              onSingleChanged: (value, item, data) {
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            const Text('缓存功能对比', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // 禁用缓存的远程搜索
            TreeSelect<String>(
              title: '远程搜索（禁用缓存）',
              options: [], // 初始为空，通过搜索获取数据
              remote: true,
              isCacheData: false, // 禁用缓存
              remoteFetch: MockDataService.searchEmployees,
              onSingleChanged: (value, item, data) {},
            ),
            const SizedBox(height: 12),
            _buildResultCard('远程搜索结果', remoteSearchResult, Colors.orange),

            const SizedBox(height: 32),

            // 3. 混合模式示例
            _buildSectionTitle('3. 混合模式（懒加载 + 远程搜索）', Icons.hub, Colors.purple),
            const SizedBox(height: 8),
            _buildDescription('既支持懒加载展开，又支持远程搜索。提供最灵活的使用体验。'),
            const SizedBox(height: 12),
            TreeSelect<String>(
              title: '选择产品（混合模式）',
              options: MockDataService.getProductCategories(),
              lazyLoad: true,
              lazyLoadFetch: MockDataService.loadCategoryProducts,
              remote: true,
              isCacheData: true, // 启用缓存
              remoteFetch: MockDataService.searchProducts,
              filterable: true, // 同时支持本地过滤
              hintText: '搜索产品或分类',
              onSingleChanged: (value, item, data) {},
            ),
            const SizedBox(height: 12),
            _buildResultCard('混合模式结果', hybridResult, Colors.purple),

            const SizedBox(height: 32),

            // 4. 多选懒加载示例
            _buildSectionTitle('4. 多选懒加载模式', Icons.checklist, Colors.teal),
            const SizedBox(height: 8),
            _buildDescription('支持多选的懒加载模式，可以选择多个不同层级的节点。'),
            const SizedBox(height: 12),
            TreeSelect<String>(
              title: '选择技能（多选懒加载）',
              options: MockDataService.getSkillCategories(),
              multiple: true,
              lazyLoad: true,
              lazyLoadFetch: MockDataService.loadSkillItems,
              onMultipleChanged: (values, items, a) {
                _showSnackBar('多选选中 ${items.length} 项');
              },
            ),
            const SizedBox(height: 12),
            _buildMultiResultCard('多选结果', multiSelectResult, Colors.teal),

            const SizedBox(height: 32),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearAllResults,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('清空所有结果'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAllResults,
                    icon: const Icon(Icons.visibility),
                    label: const Text('查看所有结果'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(description, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4)),
    );
  }

  Widget _buildResultCard(String title, SelectData<String>? result, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(result != null ? '${result.label} (${result.value})' : '未选择', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMultiResultCard(String title, List<SelectData<String>> results, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
              const Spacer(),
              if (results.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${results.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (results.isEmpty)
            const Text('未选择', style: TextStyle(fontSize: 14))
          else
            ...results.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('• ${item.label} (${item.value})', style: const TextStyle(fontSize: 14)),
              ),
            ),
        ],
      ),
    );
  }

  void _clearAllResults() {
    setState(() {
      lazyLoadResult = null;
      remoteSearchResult = null;
      hybridResult = null;
      multiSelectResult.clear();
    });
    _showSnackBar('已清空所有选择结果');
  }

  void _showAllResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.summarize, color: Colors.blue),
            SizedBox(width: 8),
            Text('所有选择结果'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogResultItem('懒加载', lazyLoadResult?.label),
              _buildDialogResultItem('远程搜索', remoteSearchResult?.label),
              _buildDialogResultItem('混合模式', hybridResult?.label),
              const Text('多选结果:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              if (multiSelectResult.isEmpty) const Text('  未选择', style: TextStyle(color: Colors.grey)) else ...multiSelectResult.map((item) => Text('  • ${item.label}')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('确定'))],
      ),
    );
  }

  Widget _buildDialogResultItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value ?? '未选择',
              style: TextStyle(color: value != null ? Colors.black87 : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating));
  }
}

/// 模拟数据服务类
/// 提供各种场景下的模拟数据和API调用
class MockDataService {
  // 模拟网络延迟
  static Future<void> _simulateNetworkDelay([int milliseconds = 800]) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  // 获取懒加载城市数据（只有第一级）
  static List<SelectData<String>> getLazyLoadCities() {
    return [
      SelectData(label: '北京市', value: 'beijing', data: 'beijing', hasChildren: true),
      SelectData(label: '上海市', value: 'shanghai', data: 'shanghai', hasChildren: true),
      SelectData(label: '广东省', value: 'guangdong', data: 'guangdong', hasChildren: true),
      SelectData(label: '浙江省', value: 'zhejiang', data: 'zhejiang', hasChildren: true),
      SelectData(label: '江苏省', value: 'jiangsu', data: 'jiangsu', hasChildren: true),
    ];
  }

  // 懒加载城市的区县数据
  static Future<List<SelectData<String>>> loadCityDistricts(SelectData<String> city) async {
    await _simulateNetworkDelay(1000);

    switch (city.value) {
      case 'beijing':
        return [
          SelectData(label: '朝阳区', value: 'chaoyang', data: 'chaoyang'),
          SelectData(label: '海淀区', value: 'haidian', data: 'haidian'),
          SelectData(label: '西城区', value: 'xicheng', data: 'xicheng'),
          SelectData(label: '东城区', value: 'dongcheng', data: 'dongcheng'),
          SelectData(label: '丰台区', value: 'fengtai', data: 'fengtai'),
        ];
      case 'shanghai':
        return [
          SelectData(label: '浦东新区', value: 'pudong', data: 'pudong'),
          SelectData(label: '黄浦区', value: 'huangpu', data: 'huangpu'),
          SelectData(label: '徐汇区', value: 'xuhui', data: 'xuhui'),
          SelectData(label: '长宁区', value: 'changning', data: 'changning'),
          SelectData(label: '静安区', value: 'jingan', data: 'jingan'),
        ];
      case 'guangdong':
        return [
          SelectData(label: '广州市', value: 'guangzhou', data: 'guangzhou'),
          SelectData(label: '深圳市', value: 'shenzhen', data: 'shenzhen'),
          SelectData(label: '珠海市', value: 'zhuhai', data: 'zhuhai'),
          SelectData(label: '佛山市', value: 'foshan', data: 'foshan'),
          SelectData(label: '东莞市', value: 'dongguan', data: 'dongguan'),
        ];
      case 'zhejiang':
        return [
          SelectData(label: '杭州市', value: 'hangzhou', data: 'hangzhou'),
          SelectData(label: '宁波市', value: 'ningbo', data: 'ningbo'),
          SelectData(label: '温州市', value: 'wenzhou', data: 'wenzhou'),
          SelectData(label: '嘉兴市', value: 'jiaxing', data: 'jiaxing'),
          SelectData(label: '湖州市', value: 'huzhou', data: 'huzhou'),
        ];
      case 'jiangsu':
        return [
          SelectData(label: '南京市', value: 'nanjing', data: 'nanjing'),
          SelectData(label: '苏州市', value: 'suzhou', data: 'suzhou'),
          SelectData(label: '无锡市', value: 'wuxi', data: 'wuxi'),
          SelectData(label: '常州市', value: 'changzhou', data: 'changzhou'),
          SelectData(label: '南通市', value: 'nantong', data: 'nantong'),
        ];
      default:
        return [];
    }
  }

  // 远程搜索员工数据
  static Future<List<SelectData<String>>> searchEmployees(String keyword) async {
    await _simulateNetworkDelay(600);

    final allEmployees = [
      // 技术部
      SelectData(
        label: '技术部',
        value: 'tech_dept',
        data: 'tech_dept',
        hasChildren: true,
        children: [
          SelectData(label: '张三 - 前端工程师', value: 'zhangsan', data: 'zhangsan'),
          SelectData(label: '李四 - 后端工程师', value: 'lisi', data: 'lisi'),
          SelectData(label: '王五 - 全栈工程师', value: 'wangwu', data: 'wangwu'),
          SelectData(label: '赵六 - 架构师', value: 'zhaoliu', data: 'zhaoliu'),
        ],
      ),
      // 产品部
      SelectData(
        label: '产品部',
        value: 'product_dept',
        data: 'product_dept',
        hasChildren: true,
        children: [
          SelectData(label: '钱七 - 产品经理', value: 'qianqi', data: 'qianqi'),
          SelectData(label: '孙八 - UI设计师', value: 'sunba', data: 'sunba'),
          SelectData(label: '周九 - UX设计师', value: 'zhoujiu', data: 'zhoujiu'),
        ],
      ),
      // 运营部
      SelectData(
        label: '运营部',
        value: 'operation_dept',
        data: 'operation_dept',
        hasChildren: true,
        children: [
          SelectData(label: '吴十 - 运营专员', value: 'wushi', data: 'wushi'),
          SelectData(label: '郑十一 - 市场推广', value: 'zhengshiyi', data: 'zhengshiyi'),
          SelectData(label: '王十二 - 数据分析师', value: 'wangshier', data: 'wangshier'),
        ],
      ),
    ];

    if (keyword.isEmpty) {
      return allEmployees;
    }

    // 搜索逻辑
    List<SelectData<String>> results = [];
    for (final dept in allEmployees) {
      if (dept.label.toLowerCase().contains(keyword.toLowerCase())) {
        results.add(dept);
      } else if (dept.children != null) {
        List<SelectData<String>> matchedEmployees = [];
        for (final employee in dept.children!) {
          if (employee.label.toLowerCase().contains(keyword.toLowerCase())) {
            matchedEmployees.add(employee);
          }
        }
        if (matchedEmployees.isNotEmpty) {
          results.add(SelectData(label: dept.label, value: dept.value, data: dept.data, hasChildren: dept.hasChildren, children: matchedEmployees));
        }
      }
    }

    return results;
  }

  // 获取产品分类（用于混合模式）
  static List<SelectData<String>> getProductCategories() {
    return [
      SelectData(label: '电子产品', value: 'electronics', data: 'electronics', hasChildren: true),
      SelectData(label: '服装鞋帽', value: 'clothing', data: 'clothing', hasChildren: true),
      SelectData(label: '家居用品', value: 'home', data: 'home', hasChildren: true),
      SelectData(label: '图书音像', value: 'books', data: 'books', hasChildren: true),
    ];
  }

  // 懒加载分类下的产品
  static Future<List<SelectData<String>>> loadCategoryProducts(SelectData<String> category) async {
    await _simulateNetworkDelay(900);

    switch (category.value) {
      case 'electronics':
        return [
          SelectData(label: 'iPhone 15 Pro', value: 'iphone15pro', data: 'iphone15pro'),
          SelectData(label: 'MacBook Air M2', value: 'macbookair', data: 'macbookair'),
          SelectData(label: 'iPad Pro', value: 'ipadpro', data: 'ipadpro'),
          SelectData(label: '小米14', value: 'xiaomi14', data: 'xiaomi14'),
          SelectData(label: '华为Mate60', value: 'mate60', data: 'mate60'),
        ];
      case 'clothing':
        return [
          SelectData(label: 'Nike Air Max', value: 'nikeairmax', data: 'nikeairmax'),
          SelectData(label: 'Adidas Ultra Boost', value: 'ultraboost', data: 'ultraboost'),
          SelectData(label: 'Uniqlo 羽绒服', value: 'uniqlo_down', data: 'uniqlo_down'),
          SelectData(label: 'Zara 连衣裙', value: 'zara_dress', data: 'zara_dress'),
        ];
      case 'home':
        return [
          SelectData(label: '宜家沙发', value: 'ikea_sofa', data: 'ikea_sofa'),
          SelectData(label: '小米扫地机器人', value: 'mi_robot', data: 'mi_robot'),
          SelectData(label: '戴森吸尘器', value: 'dyson_vacuum', data: 'dyson_vacuum'),
          SelectData(label: '美的空调', value: 'midea_ac', data: 'midea_ac'),
        ];
      case 'books':
        return [
          SelectData(label: '《Flutter实战》', value: 'flutter_book', data: 'flutter_book'),
          SelectData(label: '《设计模式》', value: 'design_patterns', data: 'design_patterns'),
          SelectData(label: '《算法导论》', value: 'algorithms', data: 'algorithms'),
          SelectData(label: '《深入理解计算机系统》', value: 'csapp', data: 'csapp'),
        ];
      default:
        return [];
    }
  }

  // 远程搜索产品
  static Future<List<SelectData<String>>> searchProducts(String keyword) async {
    await _simulateNetworkDelay(500);

    final allProducts = [
      // 电子产品
      SelectData(label: 'iPhone 15 Pro', value: 'iphone15pro', data: 'iphone15pro'),
      SelectData(label: 'MacBook Air M2', value: 'macbookair', data: 'macbookair'),
      SelectData(label: 'iPad Pro', value: 'ipadpro', data: 'ipadpro'),
      SelectData(label: '小米14', value: 'xiaomi14', data: 'xiaomi14'),
      SelectData(label: '华为Mate60', value: 'mate60', data: 'mate60'),
      // 服装
      SelectData(label: 'Nike Air Max', value: 'nikeairmax', data: 'nikeairmax'),
      SelectData(label: 'Adidas Ultra Boost', value: 'ultraboost', data: 'ultraboost'),
      SelectData(label: 'Uniqlo 羽绒服', value: 'uniqlo_down', data: 'uniqlo_down'),
      // 家居
      SelectData(label: '宜家沙发', value: 'ikea_sofa', data: 'ikea_sofa'),
      SelectData(label: '小米扫地机器人', value: 'mi_robot', data: 'mi_robot'),
      SelectData(label: '戴森吸尘器', value: 'dyson_vacuum', data: 'dyson_vacuum'),
      // 图书
      SelectData(label: '《Flutter实战》', value: 'flutter_book', data: 'flutter_book'),
      SelectData(label: '《设计模式》', value: 'design_patterns', data: 'design_patterns'),
    ];

    if (keyword.isEmpty) {
      return getProductCategories();
    }

    return allProducts.where((product) => product.label.toLowerCase().contains(keyword.toLowerCase())).toList();
  }

  // 获取技能分类（用于多选懒加载）
  static List<SelectData<String>> getSkillCategories() {
    return [
      SelectData(label: '前端技术', value: 'frontend', data: 'frontend', hasChildren: true),
      SelectData(label: '后端技术', value: 'backend', data: 'backend', hasChildren: true),
      SelectData(label: '移动开发', value: 'mobile', data: 'mobile', hasChildren: true),
      SelectData(label: '数据库', value: 'database', data: 'database', hasChildren: true),
      SelectData(label: '云计算', value: 'cloud', data: 'cloud', hasChildren: true),
    ];
  }

  // 懒加载技能项目
  static Future<List<SelectData<String>>> loadSkillItems(SelectData<String> category) async {
    await _simulateNetworkDelay(700);

    switch (category.value) {
      case 'frontend':
        return [
          SelectData(label: 'Vue.js', value: 'vuejs', data: 'vuejs'),
          SelectData(label: 'React', value: 'react', data: 'react'),
          SelectData(label: 'Angular', value: 'angular', data: 'angular'),
          SelectData(label: 'TypeScript', value: 'typescript', data: 'typescript'),
          SelectData(label: 'Webpack', value: 'webpack', data: 'webpack'),
          SelectData(label: 'Vite', value: 'vite', data: 'vite'),
        ];
      case 'backend':
        return [
          SelectData(label: 'Node.js', value: 'nodejs', data: 'nodejs'),
          SelectData(label: 'Python', value: 'python', data: 'python'),
          SelectData(label: 'Java', value: 'java', data: 'java'),
          SelectData(label: 'Go', value: 'golang', data: 'golang'),
          SelectData(label: 'Rust', value: 'rust', data: 'rust'),
          SelectData(label: 'C#', value: 'csharp', data: 'csharp'),
        ];
      case 'mobile':
        return [
          SelectData(label: 'Flutter', value: 'flutter', data: 'flutter'),
          SelectData(label: 'React Native', value: 'reactnative', data: 'reactnative'),
          SelectData(label: 'iOS (Swift)', value: 'ios_swift', data: 'ios_swift'),
          SelectData(label: 'Android (Kotlin)', value: 'android_kotlin', data: 'android_kotlin'),
          SelectData(label: 'Xamarin', value: 'xamarin', data: 'xamarin'),
        ];
      case 'database':
        return [
          SelectData(label: 'MySQL', value: 'mysql', data: 'mysql'),
          SelectData(label: 'PostgreSQL', value: 'postgresql', data: 'postgresql'),
          SelectData(label: 'MongoDB', value: 'mongodb', data: 'mongodb'),
          SelectData(label: 'Redis', value: 'redis', data: 'redis'),
          SelectData(label: 'Elasticsearch', value: 'elasticsearch', data: 'elasticsearch'),
        ];
      case 'cloud':
        return [
          SelectData(label: 'AWS', value: 'aws', data: 'aws'),
          SelectData(label: 'Azure', value: 'azure', data: 'azure'),
          SelectData(label: '阿里云', value: 'aliyun', data: 'aliyun'),
          SelectData(label: '腾讯云', value: 'tencentcloud', data: 'tencentcloud'),
          SelectData(label: 'Docker', value: 'docker', data: 'docker'),
          SelectData(label: 'Kubernetes', value: 'k8s', data: 'k8s'),
        ];
      default:
        return [];
    }
  }
}
