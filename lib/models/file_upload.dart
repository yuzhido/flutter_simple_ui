import 'dart:math';

/// 文件列表类型
enum FileListType {
  textInfo, // 默认样式
  card, // 卡片样式 - 小巧紧凑的卡片
  custom, // 自定义样式
}

/// 上传状态
enum UploadStatus {
  pending, // 等待上传
  uploading, // 上传中
  success, // 上传成功
  failed, // 上传失败
}

/// 文件来源
enum FileSource {
  all, // 允许所有类型：文件、图片、拍照
  file, // 只允许选择文件
  image, // 只允许选择图片
  camera, // 只允许拍照
  imageOrCamera, // 只允许选择图片或拍照
  network, // 网络文件
}

// 文件上传实体类
class FileInfo {
  final dynamic id;
  final String fileName;
  final String requestPath;
  FileInfo({required this.id, required this.fileName, required this.requestPath});

  /// 从Map创建FileInfo实例
  factory FileInfo.fromMap(Map<String, dynamic> map) {
    return FileInfo(id: map['id'], fileName: map['fileName'] ?? '', requestPath: map['requestPath'] ?? '');
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'fileName': fileName, 'requestPath': requestPath};
  }

  /// 创建FileInfo的副本，可选择性地更新某些字段
  FileInfo copyWith({dynamic id, String? fileName, String? requestPath}) {
    return FileInfo(id: id ?? this.id, fileName: fileName ?? this.fileName, requestPath: requestPath ?? this.requestPath);
  }
}

// 上传配置类
class UploadConfig {
  /// 请求头信息
  final Map<String, String>? headers;

  /// 上传接口路径
  final String? uploadUrl;

  /// 请求方法，默认为POST
  final String method;

  /// 请求超时时间（秒），默认30秒
  final int timeout;

  /// 文件字段名，默认为'file'
  final String fileFieldName;

  /// 额外的表单数据
  final Map<String, dynamic>? extraData;

  UploadConfig({this.headers, this.uploadUrl, this.method = 'POST', this.timeout = 30, this.fileFieldName = 'file', this.extraData});

  /// 验证配置是否有效
  /// 有效条件：提供了uploadUrl
  bool get isValid => uploadUrl != null && uploadUrl!.isNotEmpty;

  /// 从Map创建UploadConfig实例
  /// 注意：customUpload函数无法从Map反序列化，需要单独设置
  factory UploadConfig.fromMap(Map<String, dynamic> map) {
    return UploadConfig(
      headers: map['headers'] != null ? Map<String, String>.from(map['headers']) : null,
      uploadUrl: map['uploadUrl'],
      method: map['method'] ?? 'POST',
      timeout: map['timeout'] ?? 30,
      fileFieldName: map['fileFieldName'] ?? 'file',
      extraData: map['extraData'],
      // customUpload函数无法序列化，需要单独设置
    );
  }

  /// 转换为Map
  /// 注意：customUpload函数无法序列化，不包含在Map中
  Map<String, dynamic> toMap() {
    return {
      'headers': headers,
      'uploadUrl': uploadUrl,
      'method': method,
      'timeout': timeout,
      'fileFieldName': fileFieldName,
      'extraData': extraData,
      // customUpload函数无法序列化
    };
  }

  /// 复制并修改配置
  UploadConfig copyWith({Map<String, String>? headers, String? uploadUrl, String? method, int? timeout, String? fileFieldName, Map<String, dynamic>? extraData}) {
    return UploadConfig(
      headers: headers ?? this.headers,
      uploadUrl: uploadUrl ?? this.uploadUrl,
      method: method ?? this.method,
      timeout: timeout ?? this.timeout,
      fileFieldName: fileFieldName ?? this.fileFieldName,
      extraData: extraData ?? this.extraData,
    );
  }
}

/// 文件上传模型类
class FileUploadModel {
  /// 唯一标识ID（随机生成，用于前端操作如删除等，与后端ID不冲突，永远不为空）
  final String id;

  /// 文件信息（可为空，因为保存的是最后提交的数据信息，一开始可能没有）
  final FileInfo? fileInfo;

  /// 文件名称
  final String name;

  /// 文件本地路径
  final String path;

  /// 文件来源（文件选择、图片选择、拍照等）
  final FileSource source;

  /// 上传状态（等待、上传中、成功、失败）
  UploadStatus? status;

  /// 上传进度（0.0 - 1.0）
  final double progress;

  /// 文件大小（字节）
  final int? fileSize;

  /// 格式化后的文件大小信息（如：1.2MB、500KB等）
  final String? fileSizeInfo;

  /// 文件上传后的访问URL地址
  final String? url;

  /// 文件创建时间
  final DateTime? createTime;

  /// 文件最后更新时间
  final DateTime? updateTime;

  FileUploadModel({
    String? id,
    this.fileInfo,
    required this.name,
    required this.path,
    this.source = FileSource.network,
    this.fileSize,
    this.fileSizeInfo,
    this.status,
    this.progress = 0,
    this.url,
    this.createTime,
    this.updateTime,
  }) : id = id ?? _generateUniqueId();

  /// 生成唯一ID
  static String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return '${timestamp}_$random';
  }

  /// 创建一个带有自动生成ID的FileUploadModel实例
  factory FileUploadModel.withAutoId({
    FileInfo? fileInfo,
    required String name,
    required String path,
    FileSource source = FileSource.network,
    int? fileSize,
    String? fileSizeInfo,
    UploadStatus? status,
    double progress = 0,
    String? url,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return FileUploadModel(
      id: _generateUniqueId(),
      fileInfo: fileInfo,
      name: name,
      path: path,
      source: source,
      fileSize: fileSize,
      fileSizeInfo: fileSizeInfo,
      status: status,
      progress: progress,
      url: url,
      createTime: createTime,
      updateTime: updateTime,
    );
  }

  /// 复制并修改模型
  FileUploadModel copyWith({
    String? id,
    FileInfo? fileInfo,
    String? name,
    String? path,
    FileSource? source,
    UploadStatus? status,
    double? progress,
    int? fileSize,
    String? fileSizeInfo,
    String? url,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return FileUploadModel(
      id: id ?? this.id,
      fileInfo: fileInfo ?? this.fileInfo,
      name: name ?? this.name,
      path: path ?? this.path,
      source: source ?? this.source,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      fileSize: fileSize ?? this.fileSize,
      fileSizeInfo: fileSizeInfo ?? this.fileSizeInfo,
      url: url ?? this.url,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  /// 从Map创建FileUploadModel实例
  factory FileUploadModel.fromMap(Map<String, dynamic> map) {
    return FileUploadModel(
      id: map['id'] ?? _generateUniqueId(),
      fileInfo: map['fileInfo'] != null ? FileInfo.fromMap(map['fileInfo']) : null,
      name: map['name'],
      path: map['path'],
      source: FileSource.values[map['source']],
      status: map['status'] != null ? UploadStatus.values[map['status']] : null,
      progress: map['progress']?.toDouble() ?? 0,
      fileSize: map['fileSize'],
      fileSizeInfo: map['fileSizeInfo'],
      url: map['url'],
      createTime: map['createTime'] != null ? DateTime.parse(map['createTime']) : null,
      updateTime: map['updateTime'] != null ? DateTime.parse(map['updateTime']) : null,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileInfo': fileInfo?.toMap(),
      'name': name,
      'path': path,
      'source': source.index,
      'status': status?.index,
      'progress': progress,
      'fileSize': fileSize,
      'fileSizeInfo': fileSizeInfo,
      'url': url,
      'createTime': createTime?.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
    };
  }
}
