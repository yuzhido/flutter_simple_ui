# API 封装使用说明

这个文件夹包含了基于 HTTP 请求的 API 封装，用于与后端服务进行数据交互。

## 📁 文件结构

```
api/
├── config.dart              # API 配置
├── http_client.dart         # HTTP 客户端封装
├── models/
│   └── user.dart           # 用户数据模型
├── user_api.dart           # 用户管理 API
├── school_api.dart         # 学校管理 API
├── city_api.dart           # 城市管理 API
├── example_usage.dart      # 使用示例
├── index.dart              # 统一导出
└── README.md               # 说明文档
```

## 🚀 快速开始

### 1. 导入 API 模块

```dart
import 'package:your_package/api/index.dart';
```

### 2. 使用用户 API

```dart
// 获取用户列表
final response = await UserApi.getUserList(
  page: 1,
  limit: 10,
  name: '张三',  // 可选：按姓名搜索
  age: 25,      // 可选：按年龄筛选
);

// 创建用户
final newUser = User(
  name: '李四',
  age: 22,
  address: '上海市浦东新区陆家嘴456号',
  school: '复旦大学',
  birthday: '2001-03-20',
);
final createResponse = await UserApi.createUser(newUser);
```

### 3. 使用学校 API

```dart
// 获取学校列表
final response = await SchoolApi.getSchoolList(
  page: 1,
  limit: 10,
  type: '理工',    // 可选：按类型筛选
  level: '985',    // 可选：按层次筛选
);

// 创建学校
final newSchool = School(
  name: '北京大学',
  desc: '综合性大学，学科门类齐全',
  location: '北京市',
  type: '综合',
  level: '985',
  establishedYear: 1898,
  studentCount: 40000,
);
final createResponse = await SchoolApi.createSchool(newSchool);
```

### 4. 使用城市 API

```dart
// 获取城市列表
final response = await CityApi.getCityList(
  page: 1,
  limit: 10,
  province: '广东省',  // 可选：按省份搜索
  level: '省会城市',   // 可选：按级别筛选
);

// 创建城市
final newCity = City(
  name: '深圳市',
  desc: '科技创新活跃的高新技术城市',
  province: '广东省',
  level: '地级市',
  population: 17560000,
  area: 1997.0,
  gdp: 30000.0,
  climate: '亚热带',
);
final createResponse = await CityApi.createCity(newCity);
```

## 📋 API 功能列表

### 用户管理 (UserApi)

- `getUserList()` - 获取用户列表（支持分页和筛选）
- `getUser(id)` - 获取单个用户
- `createUser(user)` - 创建用户
- `updateUser(id, user)` - 更新用户
- `deleteUser(id)` - 删除用户
- `batchDeleteUsers(ids)` - 批量删除用户

### 学校管理 (SchoolApi)

- `getSchoolList()` - 获取学校列表（支持分页和筛选）
- `getSchool(id)` - 获取单个学校
- `createSchool(school)` - 创建学校
- `updateSchool(id, school)` - 更新学校
- `deleteSchool(id)` - 删除学校
- `batchDeleteSchools(ids)` - 批量删除学校

### 城市管理 (CityApi)

- `getCityList()` - 获取城市列表（支持分页和筛选）
- `getCity(id)` - 获取单个城市
- `createCity(city)` - 创建城市
- `updateCity(id, city)` - 更新城市
- `deleteCity(id)` - 删除城市
- `batchDeleteCities(ids)` - 批量删除城市

## 🔧 配置

### 修改基础 URL

在 `config.dart` 文件中修改 `baseUrl`：

```dart
class Config {
  static const String baseUrl = 'http://your-api-server.com';
  // 其他配置...
}
```

### 修改请求超时时间

```dart
class Config {
  static const int timeout = 15000; // 15秒
  // 其他配置...
}
```

## 📊 响应格式

所有 API 都返回统一的响应格式：

### 成功响应

```json
{
  "success": true,
  "data": {}, // 或 []
  "message": "操作成功",
  "pagination": {
    // 仅列表接口
    "current": 1,
    "pages": 5,
    "total": 50
  }
}
```

### 错误响应

```json
{
  "success": false,
  "message": "错误描述",
  "error": "详细错误信息"
}
```

## 🚨 错误处理

所有 API 调用都应该使用 try-catch 进行错误处理：

```dart
try {
  final response = await UserApi.getUserList();
  // 处理成功响应
} catch (e) {
  if (e is ApiException) {
    print('API 错误: ${e.message}');
    if (e.statusCode != null) {
      print('状态码: ${e.statusCode}');
    }
  } else {
    print('其他错误: $e');
  }
}
```

## 📝 注意事项

1. **网络权限**: 确保应用有网络访问权限
2. **异步操作**: 所有 API 调用都是异步的，需要使用 `await`
3. **错误处理**: 建议对所有 API 调用进行错误处理
4. **数据验证**: 创建和更新数据时，确保必填字段不为空
5. **分页查询**: 列表接口支持分页，建议合理设置 `page` 和 `limit` 参数

## 🔍 调试

如果遇到问题，可以：

1. 检查网络连接
2. 确认 API 服务器是否正常运行
3. 查看控制台输出的错误信息
4. 检查请求参数是否正确
5. 确认 API 接口地址是否正确

## 📞 支持

如有问题或建议，请查看 `example_usage.dart` 文件中的使用示例，或联系开发团队。
