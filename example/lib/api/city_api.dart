import 'http_client.dart';

/// 城市数据模型
class City {
  final String? id;
  final String? name;
  final String? desc;
  final String? province;
  final String? level;
  final int? population;
  final double? area;
  final double? gdp;
  final String? climate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  City({this.id, this.name, this.desc, this.province, this.level, this.population, this.area, this.gdp, this.climate, this.createdAt, this.updatedAt});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'],
      name: json['name'],
      desc: json['desc'],
      province: json['province'],
      level: json['level'],
      population: json['population'],
      area: json['area']?.toDouble(),
      gdp: json['gdp']?.toDouble(),
      climate: json['climate'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (desc != null) data['desc'] = desc;
    if (province != null) data['province'] = province;
    if (level != null) data['level'] = level;
    if (population != null) data['population'] = population;
    if (area != null) data['area'] = area;
    if (gdp != null) data['gdp'] = gdp;
    if (climate != null) data['climate'] = climate;
    return data;
  }
}

/// 城市 API 封装
class CityApi {
  static final HttpClient _httpClient = HttpClient();

  /// 获取城市列表
  ///
  /// [page] 页码，默认 1
  /// [limit] 每页数量，默认 10
  /// [name] 城市名称搜索（模糊匹配）
  /// [province] 省份搜索（模糊匹配）
  /// [level] 城市级别筛选
  static Future<Map<String, dynamic>> getCityList({int page = 1, int limit = 10, String? name, String? province, String? level}) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};

    if (name != null && name.isNotEmpty) {
      queryParams['name'] = name;
    }
    if (province != null && province.isNotEmpty) {
      queryParams['province'] = province;
    }
    if (level != null && level.isNotEmpty) {
      queryParams['level'] = level;
    }

    return await _httpClient.get('/cities', queryParameters: queryParams);
  }

  /// 获取单个城市
  ///
  /// [id] 城市 ID
  static Future<Map<String, dynamic>> getCity(String id) async {
    return await _httpClient.get('/cities/$id');
  }

  /// 创建城市
  ///
  /// [city] 城市数据
  static Future<Map<String, dynamic>> createCity(City city) async {
    return await _httpClient.post('/cities', body: city.toJson());
  }

  /// 更新城市
  ///
  /// [id] 城市 ID
  /// [city] 更新的城市数据（只更新提供的字段）
  static Future<Map<String, dynamic>> updateCity(String id, City city) async {
    return await _httpClient.put('/cities/$id', body: city.toJson());
  }

  /// 删除城市
  ///
  /// [id] 城市 ID
  static Future<Map<String, dynamic>> deleteCity(String id) async {
    return await _httpClient.delete('/cities/$id');
  }

  /// 批量删除城市
  ///
  /// [ids] 城市 ID 列表
  static Future<Map<String, dynamic>> batchDeleteCities(List<String> ids) async {
    final body = {'ids': ids};
    return await _httpClient.delete('/cities', body: body);
  }

  /// 城市级别枚举
  static const List<String> cityLevels = ['直辖市', '省会城市', '地级市', '县级市', '县'];

  /// 气候类型枚举
  static const List<String> climateTypes = ['热带', '亚热带', '温带', '寒带', '高原气候'];
}
