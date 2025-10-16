import 'http_client.dart';

/// 学校数据模型
class School {
  final String? id;
  final String? name;
  final String? desc;
  final String? type;
  final String? level;
  final String? location;
  final int? establishedYear;
  final int? studentCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  School({this.id, this.name, this.desc, this.type, this.level, this.location, this.establishedYear, this.studentCount, this.createdAt, this.updatedAt});

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['_id'],
      name: json['name'],
      desc: json['desc'],
      type: json['type'],
      level: json['level'],
      location: json['location'],
      establishedYear: json['establishedYear'],
      studentCount: json['studentCount'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (desc != null) data['desc'] = desc;
    if (type != null) data['type'] = type;
    if (level != null) data['level'] = level;
    if (location != null) data['location'] = location;
    if (establishedYear != null) data['establishedYear'] = establishedYear;
    if (studentCount != null) data['studentCount'] = studentCount;
    return data;
  }
}

/// 学校 API 封装
class SchoolApi {
  static final HttpClient _httpClient = HttpClient();

  /// 获取学校列表
  ///
  /// [page] 页码，默认 1
  /// [limit] 每页数量，默认 10
  /// [name] 学校名称搜索（模糊匹配）
  /// [type] 学校类型筛选
  /// [level] 学校层次筛选
  /// [location] 位置搜索（模糊匹配）
  static Future<Map<String, dynamic>> getSchoolList({int page = 1, int limit = 10, String? name, String? type, String? level, String? location}) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};

    if (name != null && name.isNotEmpty) {
      queryParams['name'] = name;
    }
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }
    if (level != null && level.isNotEmpty) {
      queryParams['level'] = level;
    }
    if (location != null && location.isNotEmpty) {
      queryParams['location'] = location;
    }

    return await _httpClient.get('/schools', queryParameters: queryParams);
  }

  /// 获取单个学校
  ///
  /// [id] 学校 ID
  static Future<Map<String, dynamic>> getSchool(String id) async {
    return await _httpClient.get('/schools/$id');
  }

  /// 创建学校
  ///
  /// [school] 学校数据
  static Future<Map<String, dynamic>> createSchool(School school) async {
    return await _httpClient.post('/schools', body: school.toJson());
  }

  /// 更新学校
  ///
  /// [id] 学校 ID
  /// [school] 更新的学校数据（只更新提供的字段）
  static Future<Map<String, dynamic>> updateSchool(String id, School school) async {
    return await _httpClient.put('/schools/$id', body: school.toJson());
  }

  /// 删除学校
  ///
  /// [id] 学校 ID
  static Future<Map<String, dynamic>> deleteSchool(String id) async {
    return await _httpClient.delete('/schools/$id');
  }

  /// 批量删除学校
  ///
  /// [ids] 学校 ID 列表
  static Future<Map<String, dynamic>> batchDeleteSchools(List<String> ids) async {
    final body = {'ids': ids};
    return await _httpClient.delete('/schools', body: body);
  }

  /// 学校类型枚举
  static const List<String> schoolTypes = ['综合', '理工', '师范', '财经', '医学', '艺术', '体育', '军事'];

  /// 学校层次枚举
  static const List<String> schoolLevels = ['985', '211', '双一流', '普通本科', '专科'];
}
