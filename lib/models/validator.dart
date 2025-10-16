/// 自定义验证器函数类型
/// 参数：对应字段的值
/// 返回：null 表示验证通过，String 表示错误信息
typedef FormValidator = String? Function(dynamic value);
