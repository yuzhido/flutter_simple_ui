import 'package:flutter/material.dart';
import 'address_api.dart';
import 'models/address.dart';

/// 地址 API 使用示例
class AddressApiExample {
  static final AddressApi _addressApi = AddressApi();

  /// 示例1: 查询省份列表
  static Future<void> exampleQueryProvinces() async {
    try {
      print('=== 查询省份列表 ===');
      final provinces = await _addressApi.getProvinces();

      print('省份数量: ${provinces.length}');
      for (final province in provinces) {
        print('省份: ${province.name} (ID: ${province.id}, 有子级: ${province.hasChildren})');
      }
    } catch (e) {
      print('查询省份失败: $e');
    }
  }

  /// 示例2: 查询指定省份的城市列表
  static Future<void> exampleQueryCities(String provinceId) async {
    try {
      print('=== 查询城市列表 (省份ID: $provinceId) ===');
      final cities = await _addressApi.getCities(provinceId);

      print('城市数量: ${cities.length}');
      for (final city in cities) {
        print('城市: ${city.name} (ID: ${city.id}, 层级: ${city.level})');
      }
    } catch (e) {
      print('查询城市失败: $e');
    }
  }

  /// 示例3: 获取完整的地址树形结构
  static Future<void> exampleGetAddressTree() async {
    try {
      print('=== 获取地址树形结构 ===');
      final tree = await _addressApi.getAddressTree();

      print('根级地址数量: ${tree.length}');
      for (final address in tree) {
        _printAddressTree(address, 0);
      }
    } catch (e) {
      print('获取地址树失败: $e');
    }
  }

  /// 递归打印地址树
  static void _printAddressTree(Address address, int level) {
    final indent = '  ' * level;
    print('$indent${address.name} (ID: ${address.id}, 层级: ${address.level})');

    if (address.children != null) {
      for (final child in address.children!) {
        _printAddressTree(child, level + 1);
      }
    }
  }

  /// 示例4: 搜索地址
  static Future<void> exampleSearchAddresses(String keyword) async {
    try {
      print('=== 搜索地址 (关键字: $keyword) ===');
      final result = await _addressApi.searchAddresses(keyword: keyword, page: 1, limit: 10);

      print('搜索结果: ${result.list.length} 条，总计: ${result.pagination.total} 条');
      for (final address in result.list) {
        print('地址: ${address.name} (ID: ${address.id}, 层级: ${address.level})');
      }

      print('分页信息: 第 ${result.pagination.page} 页，共 ${result.pagination.pages} 页');
    } catch (e) {
      print('搜索地址失败: $e');
    }
  }

  /// 示例5: 获取地址详情
  static Future<void> exampleGetAddressDetail(String addressId) async {
    try {
      print('=== 获取地址详情 (ID: $addressId) ===');
      final address = await _addressApi.getAddressDetail(addressId);

      print('地址名称: ${address.name}');
      print('父级ID: ${address.parentId ?? '无'}');
      print('层级: ${address.level}');
      print('是否有子级: ${address.hasChildren}');
      print('状态: ${address.status == 1 ? '启用' : '禁用'}');
      print('描述: ${address.description ?? '无'}');
      print('创建时间: ${address.createdAt?.toString() ?? '未知'}');
    } catch (e) {
      print('获取地址详情失败: $e');
    }
  }

  /// 示例6: 获取地址完整路径
  static Future<void> exampleGetAddressPath(String addressId) async {
    try {
      print('=== 获取地址路径 (ID: $addressId) ===');
      final path = await _addressApi.getAddressPath(addressId);

      print('路径层级: ${path.length} 级');
      final pathNames = path.map((addr) => addr.name).join(' > ');
      print('完整路径: $pathNames');

      for (int i = 0; i < path.length; i++) {
        final address = path[i];
        print('第 ${i + 1} 级: ${address.name} (ID: ${address.id})');
      }
    } catch (e) {
      print('获取地址路径失败: $e');
    }
  }

  /// 示例7: 创建新地址
  static Future<void> exampleCreateAddress() async {
    try {
      print('=== 创建新地址 ===');
      final newAddress = await _addressApi.createAddress(name: '测试地址', description: '这是一个测试地址', sort: 999);

      print('创建成功!');
      print('新地址ID: ${newAddress.id}');
      print('地址名称: ${newAddress.name}');
      print('层级: ${newAddress.level}');
      print('创建时间: ${newAddress.createdAt?.toString() ?? '未知'}');
    } catch (e) {
      print('创建地址失败: $e');
    }
  }

  /// 示例8: 更新地址
  static Future<void> exampleUpdateAddress(String addressId) async {
    try {
      print('=== 更新地址 (ID: $addressId) ===');
      final updatedAddress = await _addressApi.updateAddress(addressId, name: '更新后的地址名称', description: '更新后的描述信息', sort: 100);

      print('更新成功!');
      print('地址名称: ${updatedAddress.name}');
      print('描述: ${updatedAddress.description}');
      print('排序: ${updatedAddress.sort}');
      print('更新时间: ${updatedAddress.updatedAt?.toString() ?? '未知'}');
    } catch (e) {
      print('更新地址失败: $e');
    }
  }

  /// 示例9: 删除地址
  static Future<void> exampleDeleteAddress(String addressId, {bool force = false}) async {
    try {
      print('=== 删除地址 (ID: $addressId, 强制删除: $force) ===');
      final success = await _addressApi.deleteAddress(addressId, force: force);

      if (success) {
        print('删除成功!');
      } else {
        print('删除失败!');
      }
    } catch (e) {
      print('删除地址失败: $e');
    }
  }

  /// 示例10: 获取地址层级结构
  static Future<void> exampleGetAddressHierarchy(String addressId) async {
    try {
      print('=== 获取地址层级结构 (ID: $addressId) ===');
      final hierarchy = await _addressApi.getAddressHierarchy(addressId);

      final address = hierarchy['address'] as Address;
      final path = hierarchy['path'] as List<Address>;
      final children = hierarchy['children'] as List<Address>;

      print('当前地址: ${address.name} (层级: ${hierarchy['level']})');
      print('路径: ${path.map((a) => a.name).join(' > ')}');
      print('子级数量: ${children.length}');
      print('是否有子级: ${hierarchy['hasChildren']}');

      if (children.isNotEmpty) {
        print('子级列表:');
        for (final child in children) {
          print('  - ${child.name} (ID: ${child.id})');
        }
      }
    } catch (e) {
      print('获取地址层级结构失败: $e');
    }
  }

  /// 综合示例: 完整的地址操作流程
  static Future<void> exampleCompleteWorkflow() async {
    try {
      print('=== 完整的地址操作流程 ===');

      // 1. 获取省份列表
      print('\n1. 获取省份列表');
      final provinces = await _addressApi.getProvinces();
      if (provinces.isNotEmpty) {
        final firstProvince = provinces.first;
        print('选择省份: ${firstProvince.name}');

        // 2. 获取该省份的城市列表
        print('\n2. 获取城市列表');
        final cities = await _addressApi.getCities(firstProvince.id!);
        if (cities.isNotEmpty) {
          final firstCity = cities.first;
          print('选择城市: ${firstCity.name}');

          // 3. 获取该城市的区县列表
          print('\n3. 获取区县列表');
          final districts = await _addressApi.getDistricts(firstCity.id!);
          print('区县数量: ${districts.length}');

          // 4. 获取完整路径
          if (districts.isNotEmpty) {
            print('\n4. 获取完整路径');
            final path = await _addressApi.getAddressPath(districts.first.id!);
            print('完整路径: ${path.map((a) => a.name).join(' > ')}');
          }
        }
      }

      // 5. 搜索功能
      print('\n5. 搜索功能测试');
      final searchResults = await _addressApi.searchAddressesByKeyword('北京');
      print('搜索"北京"的结果数量: ${searchResults.length}');
    } catch (e) {
      print('完整流程执行失败: $e');
    }
  }
}

/// Flutter Widget 示例：地址选择器
class AddressSelectorExample extends StatefulWidget {
  const AddressSelectorExample({Key? key}) : super(key: key);

  @override
  State<AddressSelectorExample> createState() => _AddressSelectorExampleState();
}

class _AddressSelectorExampleState extends State<AddressSelectorExample> {
  final AddressApi _addressApi = AddressApi();

  List<Address> _provinces = [];
  List<Address> _cities = [];
  List<Address> _districts = [];

  Address? _selectedProvince;
  Address? _selectedCity;
  Address? _selectedDistrict;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  /// 加载省份列表
  Future<void> _loadProvinces() async {
    setState(() => _loading = true);
    try {
      final provinces = await _addressApi.getProvinces();
      setState(() {
        _provinces = provinces;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('加载省份失败: $e')));
    }
  }

  /// 加载城市列表
  Future<void> _loadCities(String provinceId) async {
    setState(() => _loading = true);
    try {
      final cities = await _addressApi.getCities(provinceId);
      setState(() {
        _cities = cities;
        _districts = [];
        _selectedCity = null;
        _selectedDistrict = null;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('加载城市失败: $e')));
    }
  }

  /// 加载区县列表
  Future<void> _loadDistricts(String cityId) async {
    setState(() => _loading = true);
    try {
      final districts = await _addressApi.getDistricts(cityId);
      setState(() {
        _districts = districts;
        _selectedDistrict = null;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('加载区县失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('地址选择器示例')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 省份选择
            const Text('选择省份:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<Address>(
              value: _selectedProvince,
              hint: const Text('请选择省份'),
              isExpanded: true,
              items: _provinces.map((province) {
                return DropdownMenuItem<Address>(value: province, child: Text(province.name));
              }).toList(),
              onChanged: (Address? province) {
                if (province != null) {
                  setState(() => _selectedProvince = province);
                  _loadCities(province.id!);
                }
              },
            ),

            const SizedBox(height: 16),

            // 城市选择
            const Text('选择城市:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<Address>(
              value: _selectedCity,
              hint: const Text('请选择城市'),
              isExpanded: true,
              items: _cities.map((city) {
                return DropdownMenuItem<Address>(value: city, child: Text(city.name));
              }).toList(),
              onChanged: (Address? city) {
                if (city != null) {
                  setState(() => _selectedCity = city);
                  _loadDistricts(city.id!);
                }
              },
            ),

            const SizedBox(height: 16),

            // 区县选择
            const Text('选择区县:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<Address>(
              value: _selectedDistrict,
              hint: const Text('请选择区县'),
              isExpanded: true,
              items: _districts.map((district) {
                return DropdownMenuItem<Address>(value: district, child: Text(district.name));
              }).toList(),
              onChanged: (Address? district) {
                setState(() => _selectedDistrict = district);
              },
            ),

            const SizedBox(height: 32),

            // 选择结果显示
            if (_selectedProvince != null || _selectedCity != null || _selectedDistrict != null) ...[
              const Text('选择结果:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  [_selectedProvince?.name, _selectedCity?.name, _selectedDistrict?.name].where((name) => name != null).join(' > '),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],

            // 加载状态
            if (_loading) ...[const SizedBox(height: 16), const Center(child: CircularProgressIndicator())],
          ],
        ),
      ),
    );
  }
}
