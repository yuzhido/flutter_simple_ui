import 'area_location_api.dart';
import 'models/area_location.dart';

/// 区域位置 API 使用示例
class AreaLocationExample {
  
  /// 示例1：获取顶级区域列表
  static Future<void> exampleGetTopLevelAreas() async {
    try {
      print('=== 获取顶级区域列表 ===');
      final response = await AreaLocationApi.getTopLevelAreas();
      
      if (response['success'] == true) {
        final List<dynamic> list = response['data']['list'];
        print('获取到 ${list.length} 个顶级区域:');
        
        for (final item in list) {
          final area = AreaLocation.fromJson(item);
          print('- ${area.label} (${area.id}) - Level: ${area.level}');
        }
      }
    } catch (e) {
      print('获取顶级区域失败: $e');
    }
  }

  /// 示例2：根据父级ID获取子区域
  static Future<void> exampleGetChildAreas(String parentId) async {
    try {
      print('=== 获取子区域列表 (父级: $parentId) ===');
      final response = await AreaLocationApi.getAreaLocationList(parentId: parentId);
      
      if (response['success'] == true) {
        final List<dynamic> list = response['data']['list'];
        print('获取到 ${list.length} 个子区域:');
        
        for (final item in list) {
          final area = AreaLocation.fromJson(item);
          print('- ${area.label} (${area.id}) - Level: ${area.level}, HasChildren: ${area.hasChildren}');
        }
      }
    } catch (e) {
      print('获取子区域失败: $e');
    }
  }

  /// 示例3：创建新的区域位置
  static Future<void> exampleCreateAreaLocation() async {
    try {
      print('=== 创建新区域位置 ===');
      
      final newArea = AreaLocation(
        id: 'example_district',
        label: '示例区',
        parentId: 'beijing',
        sort: 1,
        isActive: true,
      );
      
      final response = await AreaLocationApi.createAreaLocation(newArea);
      
      if (response['success'] == true) {
        final createdArea = AreaLocation.fromJson(response['data']);
        print('创建成功: ${createdArea.label} (${createdArea.id})');
        print('路径: ${createdArea.path}');
        print('层级: ${createdArea.level}');
      }
    } catch (e) {
      print('创建区域位置失败: $e');
    }
  }

  /// 示例4：更新区域位置
  static Future<void> exampleUpdateAreaLocation(String id) async {
    try {
      print('=== 更新区域位置 ===');
      
      final updateData = AreaLocation(
        label: '更新后的区域名称',
        sort: 10,
        isActive: true,
      );
      
      final response = await AreaLocationApi.updateAreaLocation(id, updateData);
      
      if (response['success'] == true) {
        final updatedArea = AreaLocation.fromJson(response['data']);
        print('更新成功: ${updatedArea.label} (${updatedArea.id})');
      }
    } catch (e) {
      print('更新区域位置失败: $e');
    }
  }

  /// 示例5：搜索区域位置
  static Future<void> exampleSearchAreas(String keyword) async {
    try {
      print('=== 搜索区域位置: "$keyword" ===');
      final response = await AreaLocationApi.searchAreaLocations(keyword: keyword);
      
      if (response['success'] == true) {
        final List<dynamic> list = response['data']['list'];
        print('搜索到 ${list.length} 个结果:');
        
        for (final item in list) {
          final area = AreaLocation.fromJson(item);
          print('- ${area.label} (${area.id}) - 路径: ${area.path}');
        }
      }
    } catch (e) {
      print('搜索区域位置失败: $e');
    }
  }

  /// 示例6：获取区域的完整路径
  static Future<void> exampleGetAreaPath(String id) async {
    try {
      print('=== 获取区域完整路径: $id ===');
      final path = await AreaLocationApi.getAreaPath(id);
      
      if (path.isNotEmpty) {
        print('完整路径:');
        for (int i = 0; i < path.length; i++) {
          final area = path[i];
          final indent = '  ' * i;
          print('$indent${area.label} (${area.id}) - Level: ${area.level}');
        }
      } else {
        print('未找到路径信息');
      }
    } catch (e) {
      print('获取区域路径失败: $e');
    }
  }

  /// 示例7：递归获取所有子区域
  static Future<void> exampleGetChildrenRecursively(String parentId) async {
    try {
      print('=== 递归获取所有子区域: $parentId ===');
      final children = await AreaLocationApi.getChildrenRecursively(parentId);
      
      if (children.isNotEmpty) {
        print('获取到 ${children.length} 个子区域:');
        
        // 按层级分组显示
        final Map<int, List<AreaLocation>> levelGroups = {};
        for (final child in children) {
          final level = child.level ?? 0;
          levelGroups[level] ??= [];
          levelGroups[level]!.add(child);
        }
        
        final sortedLevels = levelGroups.keys.toList()..sort();
        for (final level in sortedLevels) {
          print('  Level $level:');
          for (final area in levelGroups[level]!) {
            print('    - ${area.label} (${area.id})');
          }
        }
      } else {
        print('没有找到子区域');
      }
    } catch (e) {
      print('递归获取子区域失败: $e');
    }
  }

  /// 示例8：检查区域ID是否存在
  static Future<void> exampleCheckAreaExists(String id) async {
    try {
      print('=== 检查区域ID是否存在: $id ===');
      final exists = await AreaLocationApi.checkAreaIdExists(id);
      print('区域 $id ${exists ? '存在' : '不存在'}');
    } catch (e) {
      print('检查区域ID失败: $e');
    }
  }

  /// 示例9：删除区域位置
  static Future<void> exampleDeleteAreaLocation(String id) async {
    try {
      print('=== 删除区域位置: $id ===');
      final response = await AreaLocationApi.deleteAreaLocation(id);
      
      if (response['success'] == true) {
        print('删除成功');
      }
    } catch (e) {
      print('删除区域位置失败: $e');
    }
  }

  /// 示例10：批量删除区域位置
  static Future<void> exampleBatchDeleteAreas(List<String> ids) async {
    try {
      print('=== 批量删除区域位置: ${ids.join(', ')} ===');
      final response = await AreaLocationApi.batchDeleteAreaLocations(ids);
      
      if (response['success'] == true) {
        print('批量删除成功');
      }
    } catch (e) {
      print('批量删除区域位置失败: $e');
    }
  }

  /// 运行所有示例
  static Future<void> runAllExamples() async {
    print('🗺️ 区域位置 API 使用示例\n');
    
    // 1. 获取顶级区域
    await exampleGetTopLevelAreas();
    print('');
    
    // 2. 获取北京的子区域
    await exampleGetChildAreas('beijing');
    print('');
    
    // 3. 创建新区域
    await exampleCreateAreaLocation();
    print('');
    
    // 4. 搜索区域
    await exampleSearchAreas('朝阳');
    print('');
    
    // 5. 获取区域路径
    await exampleGetAreaPath('chaoyang_district');
    print('');
    
    // 6. 递归获取子区域
    await exampleGetChildrenRecursively('beijing');
    print('');
    
    // 7. 检查区域是否存在
    await exampleCheckAreaExists('beijing');
    await exampleCheckAreaExists('nonexistent_area');
    print('');
    
    // 8. 更新区域
    await exampleUpdateAreaLocation('example_district');
    print('');
    
    // 9. 删除区域
    await exampleDeleteAreaLocation('example_district');
    print('');
    
    print('✅ 所有示例运行完成');
  }
}

/// 在 main 函数中调用示例
void main() async {
  await AreaLocationExample.runAllExamples();
}