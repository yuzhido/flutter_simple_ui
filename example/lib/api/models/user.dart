/// 用户数据模型（符合 API 文档）
class User {
  final String? id;
  final String? name;
  final int? age;
  final String? address;
  final String? school;
  final String? birthday;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({this.id, this.name, this.age, this.address, this.school, this.birthday, this.createdAt, this.updatedAt});

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      // 安全地处理每个字段
      String? id;
      String? name;
      int? age;
      String? address;
      String? school;
      String? birthday;
      DateTime? createdAt;
      DateTime? updatedAt;

      // 处理 id 字段
      if (json['_id'] != null) {
        id = json['_id'].toString();
      }

      // 处理 name 字段
      if (json['name'] != null) {
        name = json['name'].toString();
      }

      // 处理 age 字段
      if (json['age'] != null) {
        if (json['age'] is int) {
          age = json['age'];
        } else if (json['age'] is String) {
          age = int.tryParse(json['age']);
        } else if (json['age'] is double) {
          age = json['age'].toInt();
        }
      }

      // 处理其他字符串字段
      // 处理address字段，同时兼容可能的拼写错误
      if (json['address'] != null) {
        address = json['address'].toString();
      } else if (json['addres'] != null) {
        // 兼容API返回数据中可能的拼写错误
        address = json['addres'].toString();
      }

      if (json['school'] != null) {
        school = json['school'].toString();
      }

      if (json['birthday'] != null) {
        birthday = json['birthday'].toString();
      }

      // 处理日期字段
      if (json['createdAt'] != null) {
        createdAt = DateTime.tryParse(json['createdAt'].toString());
      }

      if (json['updatedAt'] != null) {
        updatedAt = DateTime.tryParse(json['updatedAt'].toString());
      }

      final user = User(id: id, name: name, age: age, address: address, school: school, birthday: birthday, createdAt: createdAt, updatedAt: updatedAt);

      return user;
    } catch (e) {
      // 返回一个默认的用户对象
      return User(id: 'error', name: '解析失败', age: 0, address: '', school: '', birthday: '');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (age != null) data['age'] = age;
    if (address != null) data['address'] = address;
    if (school != null) data['school'] = school;
    if (birthday != null) data['birthday'] = birthday;
    return data;
  }
}
