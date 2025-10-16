import 'http_client.dart';
import 'models/address.dart';

/// 地址 API 封装类
class AddressApi {
  static final AddressApi _instance = AddressApi._internal();
  factory AddressApi() => _instance;
  AddressApi._internal();

  final HttpClient _httpClient = HttpClient();

  /// 1. 查询地址（简化版 POST 查询）
  ///
  /// 支持按父级 ID 查询子级地址，支持关键字模糊搜索
  /// 当两个参数都为空时，默认查询一级数据（省份级别）
  /// 不返回 children 字段，只返回符合条件的地址列表
  Future<List<Address>> queryAddresses({String? parentId, String? keyword}) async {
    try {
      final request = AddressQueryRequest(parentId: parentId, kw: keyword);

      final response = await _httpClient.post('/api/addresses/query', body: request.toJson());

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((item) => Address.fromJson(item)).toList();
      } else {
        throw Exception(response['message'] ?? '查询地址失败');
      }
    } catch (e) {
      throw Exception('查询地址失败: $e');
    }
  }

  /// 2. 获取地址树形结构
  ///
  /// 获取完整的树形结构，包含 children 字段
  Future<List<Address>> getAddressTree({String? parentId, String? keyword}) async {
    try {
      final request = AddressTreeRequest(parentId: parentId, keyword: keyword);

      final response = await _httpClient.post('/api/addresses/tree', body: request.toJson());

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((item) => Address.fromJson(item)).toList();
      } else {
        throw Exception(response['message'] ?? '获取地址树失败');
      }
    } catch (e) {
      throw Exception('获取地址树失败: $e');
    }
  }

  /// 3. 搜索地址（支持分页）
  ///
  /// 支持关键字搜索、分页、多条件筛选
  Future<AddressSearchResponse> searchAddresses({String? keyword, int page = 1, int limit = 20, String? parentId, int? level, int? status}) async {
    try {
      final request = AddressSearchRequest(keyword: keyword, page: page, limit: limit, parentId: parentId, level: level, status: status);

      final response = await _httpClient.post('/api/addresses/search', body: request.toJson());

      if (response['success'] == true) {
        final Map<String, dynamic> data = response['data'] ?? {};
        return AddressSearchResponse.fromJson(data);
      } else {
        throw Exception(response['message'] ?? '搜索地址失败');
      }
    } catch (e) {
      throw Exception('搜索地址失败: $e');
    }
  }

  /// 4. 获取地址详情
  ///
  /// 根据地址 ID 获取详细信息
  Future<Address> getAddressDetail(String id) async {
    try {
      final response = await _httpClient.get('/api/addresses/$id');

      if (response['success'] == true) {
        final Map<String, dynamic> data = response['data'] ?? {};
        return Address.fromJson(data);
      } else {
        throw Exception(response['message'] ?? '获取地址详情失败');
      }
    } catch (e) {
      throw Exception('获取地址详情失败: $e');
    }
  }

  /// 5. 创建地址
  ///
  /// 创建新的地址记录
  Future<Address> createAddress({required String name, String? parentId, String? description, int sort = 0}) async {
    try {
      final request = AddressCreateRequest(name: name, parentId: parentId, description: description, sort: sort);

      final response = await _httpClient.post('/api/addresses', body: request.toJson());

      if (response['success'] == true) {
        final Map<String, dynamic> data = response['data'] ?? {};
        return Address.fromJson(data);
      } else {
        throw Exception(response['message'] ?? '创建地址失败');
      }
    } catch (e) {
      throw Exception('创建地址失败: $e');
    }
  }

  /// 6. 更新地址
  ///
  /// 更新现有地址信息
  Future<Address> updateAddress(String id, {String? name, String? parentId, String? description, int? sort, int? status}) async {
    try {
      final request = AddressUpdateRequest(name: name, parentId: parentId, description: description, sort: sort, status: status);

      final response = await _httpClient.put('/api/addresses/$id', body: request.toJson());

      if (response['success'] == true) {
        final Map<String, dynamic> data = response['data'] ?? {};
        return Address.fromJson(data);
      } else {
        throw Exception(response['message'] ?? '更新地址失败');
      }
    } catch (e) {
      throw Exception('更新地址失败: $e');
    }
  }

  /// 7. 删除地址
  ///
  /// 删除指定地址，支持强制删除（包含子级）
  Future<bool> deleteAddress(String id, {bool force = false}) async {
    try {
      final request = AddressDeleteRequest(force: force);

      final response = await _httpClient.delete('/api/addresses/$id', body: request.toJson());

      if (response['success'] == true) {
        return true;
      } else {
        throw Exception(response['message'] ?? '删除地址失败');
      }
    } catch (e) {
      throw Exception('删除地址失败: $e');
    }
  }

  /// 8. 获取地址完整路径
  ///
  /// 获取从根级到指定地址的完整路径
  Future<List<Address>> getAddressPath(String id) async {
    try {
      final response = await _httpClient.get('/api/addresses/$id/path');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((item) => Address.fromJson(item)).toList();
      } else {
        throw Exception(response['message'] ?? '获取地址路径失败');
      }
    } catch (e) {
      throw Exception('获取地址路径失败: $e');
    }
  }

  /// 便捷方法：获取省份列表
  ///
  /// 获取所有一级地址（省份）
  Future<List<Address>> getProvinces() async {
    return await queryAddresses();
  }

  /// 便捷方法：获取城市列表
  ///
  /// 根据省份 ID 获取城市列表
  Future<List<Address>> getCities(String provinceId) async {
    return await queryAddresses(parentId: provinceId);
  }

  /// 便捷方法：获取区县列表
  ///
  /// 根据城市 ID 获取区县列表
  Future<List<Address>> getDistricts(String cityId) async {
    return await queryAddresses(parentId: cityId);
  }

  /// 便捷方法：搜索地址（简化版）
  ///
  /// 简化的搜索接口，只需要关键字
  Future<List<Address>> searchAddressesByKeyword(String keyword) async {
    final result = await searchAddresses(keyword: keyword);
    return result.list;
  }

  /// 便捷方法：获取子级地址
  ///
  /// 根据父级 ID 获取直接子级地址
  Future<List<Address>> getChildrenAddresses(String parentId) async {
    return await queryAddresses(parentId: parentId);
  }

  /// 便捷方法：检查地址是否存在
  ///
  /// 检查指定 ID 的地址是否存在
  Future<bool> addressExists(String id) async {
    try {
      await getAddressDetail(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 便捷方法：获取地址层级结构
  ///
  /// 获取指定地址的完整层级信息（包含父级路径）
  Future<Map<String, dynamic>> getAddressHierarchy(String id) async {
    try {
      final address = await getAddressDetail(id);
      final path = await getAddressPath(id);
      final children = await getChildrenAddresses(id);

      return {'address': address, 'path': path, 'children': children, 'level': address.level, 'hasChildren': address.hasChildren};
    } catch (e) {
      throw Exception('获取地址层级结构失败: $e');
    }
  }
}
