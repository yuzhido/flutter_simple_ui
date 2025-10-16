import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';
import 'package:example/api/index.dart';

class AddressDemoPage extends StatefulWidget {
  const AddressDemoPage({super.key});
  @override
  State<AddressDemoPage> createState() => _AddressDemoPageState();
}

class _AddressDemoPageState extends State<AddressDemoPage> {
  // 选中结果
  SelectData<String>? singleSelectedAddress;
  List<SelectData<String>> multipleSelectedAddresses = [];
  SelectData<String>? lazyLoadSelectedAddress;
  SelectData<String>? remoteSearchSelectedAddress;

  // 模拟静态地址数据
  final List<SelectData<String>> staticAddressData = [
    SelectData(
      label: '北京市',
      value: '110000',
      data: '110000',
      hasChildren: true,
      children: [
        SelectData(
          label: '朝阳区',
          value: '110105',
          data: '110105',
          hasChildren: true,
          children: [
            SelectData(label: '三里屯街道', value: '110105001', data: '110105001'),
            SelectData(label: '建外街道', value: '110105002', data: '110105002'),
            SelectData(label: '呼家楼街道', value: '110105003', data: '110105003'),
          ],
        ),
        SelectData(
          label: '海淀区',
          value: '110108',
          data: '110108',
          hasChildren: true,
          children: [
            SelectData(label: '中关村街道', value: '110108001', data: '110108001'),
            SelectData(label: '学院路街道', value: '110108002', data: '110108002'),
            SelectData(label: '清华园街道', value: '110108003', data: '110108003'),
          ],
        ),
        SelectData(
          label: '西城区',
          value: '110102',
          data: '110102',
          hasChildren: true,
          children: [
            SelectData(label: '西长安街街道', value: '110102001', data: '110102001'),
            SelectData(label: '新街口街道', value: '110102002', data: '110102002'),
            SelectData(label: '月坛街道', value: '110102003', data: '110102003'),
          ],
        ),
      ],
    ),
    SelectData(
      label: '上海市',
      value: '310000',
      data: '310000',
      hasChildren: true,
      children: [
        SelectData(
          label: '浦东新区',
          value: '310115',
          data: '310115',
          hasChildren: true,
          children: [
            SelectData(label: '陆家嘴街道', value: '310115001', data: '310115001'),
            SelectData(label: '周家渡街道', value: '310115002', data: '310115002'),
            SelectData(label: '塘桥街道', value: '310115003', data: '310115003'),
          ],
        ),
        SelectData(
          label: '黄浦区',
          value: '310101',
          data: '310101',
          hasChildren: true,
          children: [
            SelectData(label: '南京东路街道', value: '310101001', data: '310101001'),
            SelectData(label: '外滩街道', value: '310101002', data: '310101002'),
            SelectData(label: '半淞园路街道', value: '310101003', data: '310101003'),
          ],
        ),
      ],
    ),
    SelectData(
      label: '广东省',
      value: '440000',
      data: '440000',
      hasChildren: true,
      children: [
        SelectData(
          label: '广州市',
          value: '440100',
          data: '440100',
          hasChildren: true,
          children: [
            SelectData(label: '天河区', value: '440106', data: '440106'),
            SelectData(label: '越秀区', value: '440104', data: '440104'),
            SelectData(label: '海珠区', value: '440105', data: '440105'),
          ],
        ),
        SelectData(
          label: '深圳市',
          value: '440300',
          data: '440300',
          hasChildren: true,
          children: [
            SelectData(label: '南山区', value: '440305', data: '440305'),
            SelectData(label: '福田区', value: '440304', data: '440304'),
            SelectData(label: '罗湖区', value: '440303', data: '440303'),
          ],
        ),
      ],
    ),
  ];

  // 懒加载数据（只有顶级节点）
  final List<SelectData<String>> lazyLoadAddressData = [
    SelectData(label: '北京市', value: '110000', data: '110000', hasChildren: true),
    SelectData(label: '上海市', value: '310000', data: '310000', hasChildren: true),
    SelectData(label: '广东省', value: '440000', data: '440000', hasChildren: true),
    SelectData(label: '浙江省', value: '330000', data: '330000', hasChildren: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TreeSelect 地址选择示例'), backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 6. 真实API示例（使用AddressApi）
            _buildSectionTitle('6. 真实API示例', Icons.api, Colors.red),
            const SizedBox(height: 8),
            _buildDescription('使用真实的地址API进行数据获取和搜索。'),
            const SizedBox(height: 12),
            TreeSelect<String>(
              title: '选择地址（真实API）',
              options: [],
              remote: true,
              isCacheData: true,
              remoteFetch: _realApiSearchAddress,
              lazyLoad: true,
              lazyLoadFetch: _realApiLazyLoadAddress,
              hintText: '输入关键字搜索真实地址数据',
              onSingleChanged: (value, data, selectData) {
                _showSnackBar('真实API选中：${selectData.label}');
              },
            ),

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
                        'TreeSelect 地址选择组件示例',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('• 基础单选：选择单个地址'),
                  const Text('• 多选模式：可选择多个地址'),
                  const Text('• 懒加载：动态加载子级地址数据'),
                  const Text('• 远程搜索：实时搜索地址数据'),
                  const Text('• 本地过滤：在现有数据中过滤'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 1. 基础单选示例
            _buildSectionTitle('1. 基础单选模式', Icons.location_on, Colors.green),
            const SizedBox(height: 8),
            _buildDescription('选择单个地址，支持多级展开选择。'),
            const SizedBox(height: 12),
            TreeSelect<String>(
              title: '选择地址（单选）',
              options: staticAddressData,
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  singleSelectedAddress = selectData;
                });
                _showSnackBar('选中地址：${selectData.label}');
              },
            ),
            const SizedBox(height: 12),
            _buildResultCard('单选结果', singleSelectedAddress, Colors.green),

            const SizedBox(height: 32),

            // 2. 多选模式示例
            _buildSectionTitle('2. 多选模式', Icons.checklist, Colors.orange),
            const SizedBox(height: 8),
            _buildDescription('可以选择多个地址，支持跨层级选择。'),
            const SizedBox(height: 12),
            TreeSelect<String>(
              title: '选择地址（多选）',
              options: staticAddressData,
              multiple: true,
              onMultipleChanged: (values, datas, selectDatas) {
                setState(() {
                  multipleSelectedAddresses = selectDatas;
                });
                _showSnackBar('选中 ${selectDatas.length} 个地址');
              },
            ),
            const SizedBox(height: 12),
            _buildMultiResultCard('多选结果', multipleSelectedAddresses, Colors.orange),

            const SizedBox(height: 32),

            // 3. 本地过滤示例
            _buildSectionTitle('3. 本地过滤模式', Icons.filter_list, Colors.purple),
            const SizedBox(height: 8),
            _buildDescription('在现有数据中进行关键字过滤搜索。'),
            const SizedBox(height: 12),
            TreeSelect<String>(
              title: '选择地址（本地过滤）',
              options: staticAddressData,
              filterable: true,
              hintText: '输入地址关键字搜索',
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  singleSelectedAddress = selectData;
                });
                _showSnackBar('过滤选中：${selectData.label}');
              },
            ),

            const SizedBox(height: 32),

            // 4. 懒加载示例
            _buildSectionTitle('4. 懒加载模式', Icons.expand_more, Colors.teal),
            const SizedBox(height: 8),
            _buildDescription('点击展开时动态加载子级数据，适用于大型地址树。'),
            const SizedBox(height: 12),
            TreeSelect<String>(
              title: '选择地址（懒加载）',
              options: lazyLoadAddressData,
              lazyLoad: true,
              lazyLoadFetch: _mockLazyLoadAddress,
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  lazyLoadSelectedAddress = selectData;
                });
                _showSnackBar('懒加载选中：${selectData.label}');
              },
            ),
            const SizedBox(height: 12),
            _buildResultCard('懒加载结果', lazyLoadSelectedAddress, Colors.teal),

            const SizedBox(height: 32),

            // 5. 远程搜索示例
            _buildSectionTitle('5. 远程搜索模式', Icons.search, Colors.indigo),
            const SizedBox(height: 8),
            _buildDescription('实时搜索远程地址数据，支持缓存优化。'),
            const SizedBox(height: 12),
            TreeSelect<String>(
              title: '选择地址（远程搜索）',
              options: [], // 初始为空
              remote: true,
              isCacheData: true,
              remoteFetch: _mockRemoteSearchAddress,
              hintText: '输入关键字搜索地址',
              onSingleChanged: (value, data, selectData) {
                setState(() {
                  remoteSearchSelectedAddress = selectData;
                });
                _showSnackBar('远程搜索选中：${selectData.label}');
              },
            ),
            const SizedBox(height: 12),
            _buildResultCard('远程搜索结果', remoteSearchSelectedAddress, Colors.indigo),

            const SizedBox(height: 32),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // 构建章节标题
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  // 构建描述文本
  Widget _buildDescription(String description) {
    return Text(description, style: TextStyle(fontSize: 14, color: Colors.grey.shade600));
  }

  // 构建单选结果卡片
  Widget _buildResultCard(String title, SelectData<String>? result, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(result != null ? '${result.label} (${result.value})' : '未选择', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // 构建多选结果卡片
  Widget _buildMultiResultCard(String title, List<SelectData<String>> results, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
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

  // 显示提示消息
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2), backgroundColor: Colors.blue.shade600));
  }

  // 模拟懒加载地址数据
  Future<List<SelectData<String>>> _mockLazyLoadAddress(SelectData<String> parentNode) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    switch (parentNode.value) {
      case '110000': // 北京市
        return [
          SelectData(label: '朝阳区', value: '110105', data: '110105', hasChildren: true),
          SelectData(label: '海淀区', value: '110108', data: '110108', hasChildren: true),
          SelectData(label: '西城区', value: '110102', data: '110102', hasChildren: true),
          SelectData(label: '东城区', value: '110101', data: '110101', hasChildren: true),
        ];
      case '310000': // 上海市
        return [
          SelectData(label: '浦东新区', value: '310115', data: '310115', hasChildren: true),
          SelectData(label: '黄浦区', value: '310101', data: '310101', hasChildren: true),
          SelectData(label: '徐汇区', value: '310104', data: '310104', hasChildren: true),
        ];
      case '440000': // 广东省
        return [
          SelectData(label: '广州市', value: '440100', data: '440100', hasChildren: true),
          SelectData(label: '深圳市', value: '440300', data: '440300', hasChildren: true),
          SelectData(label: '珠海市', value: '440400', data: '440400', hasChildren: true),
        ];
      case '330000': // 浙江省
        return [
          SelectData(label: '杭州市', value: '330100', data: '330100', hasChildren: true),
          SelectData(label: '宁波市', value: '330200', data: '330200', hasChildren: true),
          SelectData(label: '温州市', value: '330300', data: '330300', hasChildren: true),
        ];
      case '110105': // 朝阳区
        return [
          SelectData(label: '三里屯街道', value: '110105001', data: '110105001'),
          SelectData(label: '建外街道', value: '110105002', data: '110105002'),
          SelectData(label: '呼家楼街道', value: '110105003', data: '110105003'),
        ];
      case '110108': // 海淀区
        return [
          SelectData(label: '中关村街道', value: '110108001', data: '110108001'),
          SelectData(label: '学院路街道', value: '110108002', data: '110108002'),
          SelectData(label: '清华园街道', value: '110108003', data: '110108003'),
        ];
      default:
        return [];
    }
  }

  // 模拟远程搜索地址数据
  Future<List<SelectData<String>>> _mockRemoteSearchAddress(String keyword) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 600));

    if (keyword.isEmpty) {
      // 返回初始数据
      return lazyLoadAddressData;
    }

    // 模拟搜索结果
    final List<SelectData<String>> searchResults = [];

    if (keyword.contains('北京') || keyword.contains('朝阳') || keyword.contains('海淀')) {
      searchResults.addAll([
        SelectData(label: '北京市朝阳区', value: '110105', data: '110105'),
        SelectData(label: '北京市海淀区', value: '110108', data: '110108'),
        SelectData(label: '北京市西城区', value: '110102', data: '110102'),
      ]);
    }

    if (keyword.contains('上海') || keyword.contains('浦东') || keyword.contains('黄浦')) {
      searchResults.addAll([
        SelectData(label: '上海市浦东新区', value: '310115', data: '310115'),
        SelectData(label: '上海市黄浦区', value: '310101', data: '310101'),
        SelectData(label: '上海市徐汇区', value: '310104', data: '310104'),
      ]);
    }

    if (keyword.contains('广州') || keyword.contains('深圳') || keyword.contains('广东')) {
      searchResults.addAll([
        SelectData(label: '广东省广州市', value: '440100', data: '440100'),
        SelectData(label: '广东省深圳市', value: '440300', data: '440300'),
        SelectData(label: '广东省珠海市', value: '440400', data: '440400'),
      ]);
    }

    return searchResults;
  }

  // 使用真实API搜索地址数据
  Future<List<SelectData<String>>> _realApiSearchAddress(String keyword) async {
    try {
      final addressApi = AddressApi();

      if (keyword.isEmpty) {
        // 获取省级数据
        final response = await addressApi.queryAddresses();

        return response.map((address) => SelectData<String>(label: address.name, value: address.id ?? '', data: address.id ?? '', hasChildren: address.hasChildren)).toList();
      } else {
        // 搜索地址
        final searchResponse = await addressApi.searchAddresses(keyword: keyword);

        return searchResponse.list
            .map((address) => SelectData<String>(label: address.name, value: address.id ?? '', data: address.id ?? '', hasChildren: address.hasChildren))
            .toList();
      }
    } catch (e) {
      debugPrint('真实API搜索失败: $e');
      // 失败时返回模拟数据
      return _mockRemoteSearchAddress(keyword);
    }
  }

  // 使用真实API懒加载地址数据
  Future<List<SelectData<String>>> _realApiLazyLoadAddress(SelectData<String> parentNode) async {
    await Future.delayed(Duration(seconds: 3));
    try {
      final addressApi = AddressApi();
      final parentId = parentNode.value;

      final response = await addressApi.queryAddresses(parentId: parentId);

      return response.map((address) => SelectData<String>(label: address.name, value: address.id ?? '', data: address.id ?? '', hasChildren: address.hasChildren)).toList();
    } catch (e) {
      debugPrint('真实API懒加载失败: $e');
      // 失败时返回模拟数据
      return _mockLazyLoadAddress(parentNode);
    }
  }
}
