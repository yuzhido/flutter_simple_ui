import 'models/user.dart';
import 'http_client.dart';

/// 用户 API 封装
class UserApi {
  static final HttpClient _httpClient = HttpClient();

  /// 获取用户列表
  ///
  /// [page] 页码，默认 1
  /// [limit] 每页数量，默认 10
  /// [name] 姓名搜索（模糊匹配）
  /// [age] 年龄筛选
  /// [school] 学校搜索（模糊匹配）
  static Future<Map<String, dynamic>> getUserList({int page = 1, int limit = 10, String? name, int? age, String? school}) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};

    if (name != null && name.isNotEmpty) {
      queryParams['name'] = name;
    }
    if (age != null) {
      queryParams['age'] = age;
    }
    if (school != null && school.isNotEmpty) {
      queryParams['school'] = school;
    }

    return await _httpClient.get('/users', queryParameters: queryParams);
  }

  /// 获取单个用户
  ///
  /// [id] 用户 ID
  static Future<Map<String, dynamic>> getUser(String id) async {
    return await _httpClient.get('/users/$id');
  }

  /// 创建用户
  ///
  /// [user] 用户数据
  static Future<Map<String, dynamic>> createUser(User user) async {
    // 验证必填字段
    if (user.name == null || user.name!.trim().isEmpty) {
      throw ApiException('姓名不能为空');
    }
    if (user.age == null || user.age! <= 0) {
      throw ApiException('年龄必须大于0');
    }

    // 构造请求体，确保所有必填字段都有值
    final body = <String, dynamic>{
      'name': user.name!.trim(),
      'age': user.age!,
      'address': user.address?.trim() ?? '',
      'school': user.school?.trim() ?? '',
      'birthday': user.birthday?.trim() ?? '',
    };

    // 添加调试信息
    print('创建用户请求体: $body');

    return await _httpClient.post('/users', body: body);
  }

  /// 更新用户
  ///
  /// [id] 用户 ID
  /// [user] 更新的用户数据（只更新提供的字段）
  static Future<Map<String, dynamic>> updateUser(String id, User user) async {
    final body = <String, dynamic>{};

    if (user.name != null) body['name'] = user.name;
    if (user.age != null) body['age'] = user.age;
    if (user.address != null) body['address'] = user.address;
    if (user.school != null) body['school'] = user.school;
    if (user.birthday != null) body['birthday'] = user.birthday;

    return await _httpClient.put('/users/$id', body: body);
  }

  /// 删除用户
  ///
  /// [id] 用户 ID
  static Future<Map<String, dynamic>> deleteUser(String id) async {
    return await _httpClient.delete('/users/$id');
  }

  /// 批量删除用户
  ///
  /// [ids] 用户 ID 列表
  static Future<Map<String, dynamic>> batchDeleteUsers(List<String> ids) async {
    final body = {'ids': ids};
    return await _httpClient.delete('/users', body: body);
  }
}
