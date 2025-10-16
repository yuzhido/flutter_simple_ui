import 'http_client.dart';

/// 爱好数据模型
class Hobby {
  final String? id;
  final String? name;

  Hobby({this.id, this.name});

  factory Hobby.fromJson(Map<String, dynamic> json) {
    return Hobby(
      id: json['_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    return data;
  }
}

/// 爱好 API 封装
class HobbyApi {
  static final HttpClient _httpClient = HttpClient();

  /// 获取爱好列表
  ///
  /// [page] 页码，默认 1
  /// [limit] 每页数量，默认 10
  /// [keyword] 关键字（模糊匹配 name，包含即返回）
  static Future<Map<String, dynamic>> getHobbyList({int page = 1, int limit = 10, String? keyword}) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};

    if (keyword != null && keyword.isNotEmpty) {
      queryParams['keyword'] = keyword;
    }

    return await _httpClient.get('/hobbies', queryParameters: queryParams);
  }

  /// 获取单个爱好
  ///
  /// [id] 爱好 ID
  static Future<Map<String, dynamic>> getHobby(String id) async {
    return await _httpClient.get('/hobbies/$id');
  }

  /// 创建爱好
  ///
  /// [hobby] 爱好数据，仅包含 name
  static Future<Map<String, dynamic>> createHobby(Hobby hobby) async {
    if (hobby.name == null || hobby.name!.trim().isEmpty) {
      throw ApiException('爱好名称不能为空');
    }

    final body = <String, dynamic>{
      'name': hobby.name!.trim(),
    };

    // 调试输出
    print('创建爱好请求体: $body');

    return await _httpClient.post('/hobbies', body: body);
  }

  /// 更新爱好
  ///
  /// [id] 爱好 ID
  /// [hobby] 更新数据，只支持 name
  static Future<Map<String, dynamic>> updateHobby(String id, Hobby hobby) async {
    final body = <String, dynamic>{};
    if (hobby.name != null) body['name'] = hobby.name;
    return await _httpClient.put('/hobbies/$id', body: body);
  }

  /// 删除爱好
  ///
  /// [id] 爱好 ID
  static Future<Map<String, dynamic>> deleteHobby(String id) async {
    return await _httpClient.delete('/hobbies/$id');
  }
}