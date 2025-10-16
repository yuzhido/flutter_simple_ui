/// API 使用示例
///
/// 这个文件展示了如何使用封装好的 API 进行网络请求

import 'index.dart';

class ApiUsageExample {
  /// 用户 API 使用示例
  static Future<void> userApiExample() async {
    try {
      // 1. 获取用户列表
      print('=== 获取用户列表 ===');
      final userListResponse = await UserApi.getUserList(
        page: 1,
        limit: 10,
        name: '张三', // 可选：按姓名搜索
        age: 25, // 可选：按年龄筛选
      );
      print('用户列表: ${userListResponse['data']}');
      print('分页信息: ${userListResponse['pagination']}');

      // 2. 获取单个用户
      print('\n=== 获取单个用户 ===');
      final userId = '64f8a1b2c3d4e5f6a7b8c9d0';
      final userResponse = await UserApi.getUser(userId);
      print('用户详情: ${userResponse['data']}');

      // 3. 创建用户
      print('\n=== 创建用户 ===');
      final newUser = User(name: '李四', age: 22, address: '上海市浦东新区陆家嘴456号', school: '复旦大学', birthday: '2001-03-20');
      final createResponse = await UserApi.createUser(newUser);
      print('创建结果: ${createResponse['data']}');

      // 4. 更新用户
      print('\n=== 更新用户 ===');
      final updatedUser = User(name: '李四更新', age: 23);
      final updateResponse = await UserApi.updateUser(userId, updatedUser);
      print('更新结果: ${updateResponse['data']}');

      // 5. 删除用户
      print('\n=== 删除用户 ===');
      final deleteResponse = await UserApi.deleteUser(userId);
      print('删除结果: ${deleteResponse['message']}');

      // 6. 批量删除用户
      print('\n=== 批量删除用户 ===');
      final batchDeleteResponse = await UserApi.batchDeleteUsers(['64f8a1b2c3d4e5f6a7b8c9d0', '64f8a1b2c3d4e5f6a7b8c9d1']);
      print('批量删除结果: ${batchDeleteResponse['message']}');
    } catch (e) {
      print('用户 API 错误: $e');
    }
  }

  /// 学校 API 使用示例
  static Future<void> schoolApiExample() async {
    try {
      // 1. 获取学校列表
      print('=== 获取学校列表 ===');
      final schoolListResponse = await SchoolApi.getSchoolList(
        page: 1,
        limit: 5,
        type: '理工', // 可选：按类型筛选
        level: '985', // 可选：按层次筛选
        location: '北京', // 可选：按位置搜索
      );
      print('学校列表: ${schoolListResponse['data']}');

      // 2. 创建学校
      print('\n=== 创建学校 ===');
      final newSchool = School(name: '北京大学', desc: '综合性大学，学科门类齐全，教学科研实力雄厚', location: '北京市', type: '综合', level: '985', establishedYear: 1898, studentCount: 40000);
      final createResponse = await SchoolApi.createSchool(newSchool);
      print('创建结果: ${createResponse['data']}');

      // 3. 获取学校类型和层次枚举
      print('\n=== 学校类型和层次 ===');
      print('学校类型: ${SchoolApi.schoolTypes}');
      print('学校层次: ${SchoolApi.schoolLevels}');
    } catch (e) {
      print('学校 API 错误: $e');
    }
  }

  /// 城市 API 使用示例
  static Future<void> cityApiExample() async {
    try {
      // 1. 获取城市列表
      print('=== 获取城市列表 ===');
      final cityListResponse = await CityApi.getCityList(
        page: 1,
        limit: 5,
        province: '广东省', // 可选：按省份搜索
        level: '省会城市', // 可选：按级别筛选
      );
      print('城市列表: ${cityListResponse['data']}');

      // 2. 创建城市
      print('\n=== 创建城市 ===');
      final newCity = City(name: '深圳市', desc: '科技创新活跃的高新技术城市，人才聚集', province: '广东省', level: '地级市', population: 17560000, area: 1997.0, gdp: 30000.0, climate: '亚热带');
      final createResponse = await CityApi.createCity(newCity);
      print('创建结果: ${createResponse['data']}');

      // 3. 获取城市级别和气候类型枚举
      print('\n=== 城市级别和气候类型 ===');
      print('城市级别: ${CityApi.cityLevels}');
      print('气候类型: ${CityApi.climateTypes}');
    } catch (e) {
      print('城市 API 错误: $e');
    }
  }

  /// 运行所有示例
  static Future<void> runAllExamples() async {
    print('🚀 开始运行 API 使用示例...\n');

    await userApiExample();
    print('\n' + '=' * 50 + '\n');

    await schoolApiExample();
    print('\n' + '=' * 50 + '\n');

    await cityApiExample();

    print('\n✅ 所有示例运行完成！');
  }
}
