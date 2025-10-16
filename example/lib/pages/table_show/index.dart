import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/src/table_show/index.dart';

class TableShowPage extends StatefulWidget {
  const TableShowPage({super.key});
  @override
  State<TableShowPage> createState() => _TableShowPageState();
}

class _TableShowPageState extends State<TableShowPage> {
  // 基础表格数据
  final List<Map<String, dynamic>> basicColumns = const [
    {'label': '姓名', 'prop': 'name', 'width': 120},
    {'label': '年龄', 'prop': 'age', 'width': 80},
    {'label': '城市', 'prop': 'city', 'width': 100},
    {'label': '职业', 'prop': 'job', 'width': 120},
    {'label': '薪资', 'prop': 'salary', 'width': 100},
  ];

  final List<Map<String, dynamic>> basicData = const [
    {'name': '张三', 'age': 25, 'city': '北京', 'job': '前端工程师', 'salary': '15K'},
    {'name': '李四', 'age': 30, 'city': '上海', 'job': '后端工程师', 'salary': '18K'},
    {'name': '王五', 'age': 28, 'city': '深圳', 'job': '产品经理', 'salary': '20K'},
    {'name': '赵六', 'age': 35, 'city': '广州', 'job': '架构师', 'salary': '25K'},
    {'name': '钱七', 'age': 26, 'city': '杭州', 'job': 'UI设计师', 'salary': '12K'},
  ];

  // 固定列表格数据
  final List<Map<String, dynamic>> fixedColumns = const [
    {'label': 'ID', 'prop': 'id', 'width': 80, 'fixed': true},
    {'label': '姓名', 'prop': 'name', 'width': 120, 'fixed': true},
    {'label': '部门', 'prop': 'department', 'width': 100},
    {'label': '职位', 'prop': 'position', 'width': 120},
    {'label': '入职时间', 'prop': 'joinDate', 'width': 120},
    {'label': '邮箱', 'prop': 'email', 'width': 200},
    {'label': '电话', 'prop': 'phone', 'width': 150},
    {'label': '地址', 'prop': 'address', 'width': 250},
  ];

  final List<Map<String, dynamic>> fixedData = const [
    {
      'id': 1,
      'name': '张三',
      'department': '技术部',
      'position': '高级工程师',
      'joinDate': '2020-03-15',
      'email': 'zhangsan@company.com',
      'phone': '13800138001',
      'address': '北京市朝阳区建国门外大街1号国贸大厦A座1001室',
    },
    {
      'id': 2,
      'name': '李四',
      'department': '产品部',
      'position': '产品经理',
      'joinDate': '2019-06-20',
      'email': 'lisi@company.com',
      'phone': '13800138002',
      'address': '上海市浦东新区陆家嘴环路1000号恒生银行大厦B座2002室',
    },
    {
      'id': 3,
      'name': '王五',
      'department': '设计部',
      'position': 'UI设计师',
      'joinDate': '2021-01-10',
      'email': 'wangwu@company.com',
      'phone': '13800138003',
      'address': '深圳市南山区科技园南区深南大道10000号腾讯大厦C座3003室',
    },
    {
      'id': 4,
      'name': '赵六',
      'department': '运营部',
      'position': '运营专员',
      'joinDate': '2020-09-05',
      'email': 'zhaoliu@company.com',
      'phone': '13800138004',
      'address': '广州市天河区珠江新城花城大道85号高德置地广场D座4004室',
    },
    {
      'id': 5,
      'name': '钱七',
      'department': '人事部',
      'position': 'HR经理',
      'joinDate': '2018-12-01',
      'email': 'qianqi@company.com',
      'phone': '13800138005',
      'address': '杭州市西湖区文三路259号昌地火炬大厦E座5005室',
    },
  ];

  // 自定义样式表格数据
  final List<Map<String, dynamic>> customStyleColumns = const [
    {'label': '产品名称', 'prop': 'name', 'width': 150},
    {'label': '价格', 'prop': 'price', 'width': 100},
    {'label': '库存', 'prop': 'stock', 'width': 80},
    {'label': '状态', 'prop': 'status', 'width': 100},
    {'label': '描述', 'prop': 'description', 'width': 200},
  ];

  final List<Map<String, dynamic>> customStyleData = const [
    {'name': 'iPhone 15 Pro', 'price': '¥8999', 'stock': 50, 'status': '有库存', 'description': '苹果最新旗舰手机，搭载A17 Pro芯片'},
    {'name': 'MacBook Pro', 'price': '¥12999', 'stock': 25, 'status': '有库存', 'description': '专业级笔记本电脑，适合开发者和设计师'},
    {'name': 'iPad Air', 'price': '¥4399', 'stock': 0, 'status': '缺货', 'description': '轻薄便携的平板电脑，支持Apple Pencil'},
    {'name': 'AirPods Pro', 'price': '¥1899', 'stock': 100, 'status': '有库存', 'description': '主动降噪无线耳机，音质出色'},
    {'name': 'Apple Watch', 'price': '¥2999', 'stock': 30, 'status': '有库存', 'description': '智能手表，健康监测功能丰富'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('表格组件示例'), backgroundColor: const Color(0xFF007AFF), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TableShow 组件使用示例', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // 基础表格示例
            _buildSectionTitle('1. 基础表格'),
            const SizedBox(height: 8),
            const Text('最简单的表格使用方式，包含基本的列定义和数据展示。', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
            const SizedBox(height: 12),
            TableShow(columns: basicColumns, data: basicData),
            const SizedBox(height: 24),

            // 固定列表格示例
            _buildSectionTitle('2. 固定列表格'),
            const SizedBox(height: 8),
            const Text('左侧固定ID和姓名列，其他列可以水平滚动。适用于数据较多需要固定关键信息的场景。', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
            const SizedBox(height: 12),
            TableShow(columns: fixedColumns, data: fixedData, rowHeight: 50, headerHeight: 50),
            const SizedBox(height: 24),

            // 自定义样式表格示例
            _buildSectionTitle('3. 自定义样式表格'),
            const SizedBox(height: 8),
            const Text('自定义表头和数据单元格的样式，以及行高。', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
            const SizedBox(height: 12),
            TableShow(
              columns: customStyleColumns,
              data: customStyleData,
              rowHeight: 60,
              headerHeight: 50,
              headerTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1976D2)),
              cellTextStyle: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
              borderColor: const Color(0xFF2196F3),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            const SizedBox(height: 24),

            // 动态行高表格示例
            _buildSectionTitle('4. 动态行高表格'),
            const SizedBox(height: 8),
            const Text('根据数据内容动态调整行高，适合内容长度不一的场景。', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
            const SizedBox(height: 12),
            TableShow(
              columns: const [
                {'label': '标题', 'prop': 'title', 'width': 150},
                {'label': '内容', 'prop': 'content', 'width': 300},
                {'label': '标签', 'prop': 'tags', 'width': 200},
              ],
              data: const [
                {'title': '短标题', 'content': '这是一段短内容', 'tags': '标签1, 标签2'},
                {'title': '这是一个比较长的标题，可能会占用更多空间', 'content': '这是一段比较长的内容，包含了很多详细信息，需要更多的空间来展示，可能会影响行高', 'tags': '标签1, 标签2, 标签3, 标签4, 标签5'},
                {'title': '中等长度标题', 'content': '中等长度的内容描述', 'tags': '标签1, 标签2, 标签3'},
              ],
              rowHeightBuilder: (rowIndex, row) {
                // 根据内容长度动态计算行高
                final content = row['content']?.toString() ?? '';
                final tags = row['tags']?.toString() ?? '';
                final baseHeight = 44.0;
                final contentLines = (content.length / 30).ceil();
                final tagsLines = (tags.length / 20).ceil();
                return baseHeight + (contentLines + tagsLines - 2) * 20.0;
              },
              headerTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF2E7D32)),
              cellTextStyle: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
              borderColor: const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 24),

            // 使用说明
            _buildSectionTitle('使用说明'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2196F3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '组件特性：',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                  ),
                  SizedBox(height: 8),
                  Text('• columns: 列定义数组，支持 label、prop、width、fixed 属性'),
                  Text('• data: 数据数组，每行数据对应一个 Map'),
                  Text('• rowHeight: 默认行高，可被 rowHeightBuilder 覆盖'),
                  Text('• headerHeight: 表头高度'),
                  Text('• defaultColumnWidth: 默认列宽'),
                  Text('• borderColor: 边框颜色'),
                  Text('• borderRadius: 圆角设置'),
                  Text('• headerTextStyle: 表头文字样式'),
                  Text('• cellTextStyle: 单元格文字样式'),
                  Text('• rowHeightBuilder: 动态行高计算函数'),
                  SizedBox(height: 8),
                  Text(
                    '列定义说明：',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                  ),
                  Text('• label: 列标题'),
                  Text('• prop: 数据属性名'),
                  Text('• width: 列宽度（可选）'),
                  Text('• fixed: 是否固定列（可选，true为固定）'),
                  SizedBox(height: 8),
                  Text(
                    '注意事项：',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                  ),
                  Text('• 固定列会显示在左侧，可滚动列显示在右侧'),
                  Text('• 如果所有列都固定，则不会显示滚动区域'),
                  Text('• 数据为空时会显示空表格'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
    );
  }
}
