import 'models/area_location.dart';
import 'http_client.dart';

/// 区域位置 API 封装
class AreaLocationApi {
  static final HttpClient _httpClient = HttpClient();

  /// 获取区域位置列表
  ///
  /// [page] 页码，默认 1
  /// [limit] 每页数量，默认 100
  /// [parentId] 父级 ID，获取子级区域
  /// [level] 层级筛选
  /// [label] 标签搜索（模糊匹配）
  static Future<Map<String, dynamic>> getAreaLocationList({int page = 1, int limit = 100, String? parentId, int? level, String? label}) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};

    if (parentId != null && parentId.isNotEmpty) {
      queryParams['parentId'] = parentId;
    }
    if (level != null) {
      queryParams['level'] = level;
    }
    if (label != null && label.isNotEmpty) {
      queryParams['label'] = label;
    }

    return await _httpClient.get('/api/area-locations', queryParameters: queryParams);
  }

  /// 获取单个区域位置
  ///
  /// [id] 区域位置 ID
  static Future<Map<String, dynamic>> getAreaLocation(String id) async {
    if (id.trim().isEmpty) {
      throw ApiException('区域位置 ID 不能为空');
    }

    return await _httpClient.get('/api/area-locations/$id');
  }

  /// 创建区域位置
  ///
  /// [areaLocation] 区域位置数据
  static Future<Map<String, dynamic>> createAreaLocation(AreaLocation areaLocation) async {
    // 验证必填字段
    if (areaLocation.id == null || areaLocation.id!.trim().isEmpty) {
      throw ApiException('区域位置 ID 不能为空');
    }
    if (areaLocation.label == null || areaLocation.label!.trim().isEmpty) {
      throw ApiException('区域位置名称不能为空');
    }

    // 构造请求体，确保所有必填字段都有值
    final body = <String, dynamic>{'id': areaLocation.id!.trim(), 'label': areaLocation.label!.trim()};

    // 添加可选字段
    if (areaLocation.parentId != null && areaLocation.parentId!.trim().isNotEmpty) {
      body['parentId'] = areaLocation.parentId!.trim();
    }
    if (areaLocation.level != null) {
      body['level'] = areaLocation.level!;
    }
    if (areaLocation.sort != null) {
      body['sort'] = areaLocation.sort!;
    }
    if (areaLocation.isActive != null) {
      body['isActive'] = areaLocation.isActive!;
    }

    // 添加调试信息
    print('创建区域位置请求体: $body');

    return await _httpClient.post('/api/area-locations', body: body);
  }

  /// 更新区域位置
  ///
  /// [id] 区域位置 ID
  /// [areaLocation] 更新的区域位置数据（只更新提供的字段）
  static Future<Map<String, dynamic>> updateAreaLocation(String id, AreaLocation areaLocation) async {
    if (id.trim().isEmpty) {
      throw ApiException('区域位置 ID 不能为空');
    }

    final body = <String, dynamic>{};

    // 只添加非空字段到请求体
    if (areaLocation.label != null && areaLocation.label!.trim().isNotEmpty) {
      body['label'] = areaLocation.label!.trim();
    }
    if (areaLocation.parentId != null) {
      body['parentId'] = areaLocation.parentId!.trim();
    }
    if (areaLocation.level != null) {
      body['level'] = areaLocation.level!;
    }
    if (areaLocation.sort != null) {
      body['sort'] = areaLocation.sort!;
    }
    if (areaLocation.isActive != null) {
      body['isActive'] = areaLocation.isActive!;
    }

    // 添加调试信息
    print('更新区域位置请求体: $body');

    return await _httpClient.put('/api/area-locations/$id', body: body);
  }

  /// 删除区域位置（软删除）
  ///
  /// [id] 区域位置 ID
  ///
  /// 特殊功能：
  /// - 软删除：将 isActive 设为 false，不物理删除数据
  /// - 自动更新父级：删除后自动更新父级区域的 hasChildren 字段
  /// - 级联处理：删除父级时会同时软删除所有子级区域
  static Future<Map<String, dynamic>> deleteAreaLocation(String id) async {
    if (id.trim().isEmpty) {
      throw ApiException('区域位置 ID 不能为空');
    }

    return await _httpClient.delete('/api/area-locations/$id');
  }

  /// 批量删除区域位置
  ///
  /// [ids] 区域位置 ID 列表
  static Future<Map<String, dynamic>> batchDeleteAreaLocations(List<String> ids) async {
    if (ids.isEmpty) {
      throw ApiException('区域位置 ID 列表不能为空');
    }

    // 过滤空字符串
    final validIds = ids.where((id) => id.trim().isNotEmpty).toList();
    if (validIds.isEmpty) {
      throw ApiException('没有有效的区域位置 ID');
    }

    final body = {'ids': validIds};
    return await _httpClient.delete('/api/area-locations', body: body);
  }

  /// 获取指定区域的所有子级区域（递归获取）
  ///
  /// [parentId] 父级区域 ID
  /// [includeInactive] 是否包含已停用的区域，默认 false
  static Future<List<AreaLocation>> getChildrenRecursively(String parentId, {bool includeInactive = false}) async {
    final List<AreaLocation> allChildren = [];

    try {
      // 获取直接子级
      final response = await getAreaLocationList(parentId: parentId, limit: 1000);

      if (response['success'] == true && response['data'] != null && response['data']['list'] != null) {
        final List<dynamic> list = response['data']['list'];

        for (final item in list) {
          final areaLocation = AreaLocation.fromJson(item);

          // 根据 includeInactive 参数决定是否包含已停用的区域
          if (includeInactive || (areaLocation.isActive == true)) {
            allChildren.add(areaLocation);

            // 如果有子级，递归获取
            if (areaLocation.hasChildren == true && areaLocation.id != null) {
              final grandChildren = await getChildrenRecursively(areaLocation.id!, includeInactive: includeInactive);
              allChildren.addAll(grandChildren);
            }
          }
        }
      }
    } catch (e) {
      print('获取子级区域失败: $e');
      // 不抛出异常，返回已获取的部分数据
    }

    return allChildren;
  }

  /// 获取区域的完整路径（从根到当前区域）
  ///
  /// [id] 区域位置 ID
  static Future<List<AreaLocation>> getAreaPath(String id) async {
    final List<AreaLocation> path = [];

    try {
      String? currentId = id;

      while (currentId != null && currentId.isNotEmpty) {
        final response = await getAreaLocation(currentId);

        if (response['success'] == true && response['data'] != null) {
          final areaLocation = AreaLocation.fromJson(response['data']);
          path.insert(0, areaLocation); // 插入到开头，保持从根到叶的顺序

          currentId = areaLocation.parentId;
        } else {
          break;
        }
      }
    } catch (e) {
      print('获取区域路径失败: $e');
      // 不抛出异常，返回已获取的部分路径
    }

    return path;
  }

  /// 搜索区域位置（支持模糊搜索）
  ///
  /// [keyword] 搜索关键词
  /// [level] 限制搜索的层级
  /// [parentId] 限制搜索的父级区域
  /// [page] 页码，默认 1
  /// [limit] 每页数量，默认 50
  static Future<Map<String, dynamic>> searchAreaLocations({required String keyword, int? level, String? parentId, int page = 1, int limit = 50}) async {
    return await getAreaLocationList(page: page, limit: limit, parentId: parentId, level: level, label: keyword.trim());
  }

  /// 获取顶级区域列表（level = 1）
  ///
  /// [page] 页码，默认 1
  /// [limit] 每页数量，默认 100
  static Future<Map<String, dynamic>> getTopLevelAreas({int page = 1, int limit = 100}) async {
    return await getAreaLocationList(page: page, limit: limit, level: 1);
  }

  /// 检查区域 ID 是否已存在
  ///
  /// [id] 要检查的区域 ID
  static Future<bool> checkAreaIdExists(String id) async {
    if (id.trim().isEmpty) {
      return false;
    }

    try {
      final response = await getAreaLocation(id);
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
