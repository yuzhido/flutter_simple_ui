/// 应用配置类
class Config {
  /// 基础 URL
  /// 如果当前URL无法访问，可以尝试以下备选地址：
  /// - 'http://localhost:3000' (本地开发)
  /// - 'http://127.0.0.1:3000' (本地回环)
  /// - 'https://jsonplaceholder.typicode.com' (测试API)
  // static const String baseUrl = 'http://192.168.1.19:3000';
  // static const String baseUrl = 'http://192.168.8.188:3000';
  // static const String baseUrl = 'http://192.168.8.147:3000';
  static const String baseUrl = 'http://192.168.8.28:3000';

  /// 请求超时时间（毫秒）
  static const int timeout = 15000; // 增加到15秒

  /// 请求头
  static const Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'User-Agent': 'Flutter-App/1.0'};

  /// 是否启用调试模式
  static const bool debugMode = true;

  /// 重试次数
  static const int retryCount = 3;
}
