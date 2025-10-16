/// API 模块统一导出
///
/// 使用方式：
/// ```dart
/// import 'package:your_package/api/index.dart';
///
/// // 用户 API
/// final userList = await UserApi.getUserList(page: 1, limit: 10);
///
/// // 学校 API
/// final schoolList = await SchoolApi.getSchoolList(type: '理工');
///
/// // 城市 API
/// final cityList = await CityApi.getCityList(province: '广东省');
/// ```

// 导出配置
export 'http_client.dart';

// 导出数据模型
export 'models/user.dart';
export 'models/area_location.dart';
export 'models/address.dart';

// 导出各模块 API
export 'user_api.dart';
export 'school_api.dart';
export 'city_api.dart';
export 'area_location_api.dart';
export 'address_api.dart';
export 'hobby_api.dart';

// 导出使用示例
export 'example_usage.dart';
