/// 区域位置数据模型（符合 API 文档）
class AreaLocation {
  final String? mongoId; // MongoDB 的 _id
  final String? id; // 区域位置 ID，唯一标识
  final String? label; // 区域位置名称
  final String? parentId; // 父级区域 ID，顶级区域可为 null
  final int? level; // 层级，自动计算
  final String? path; // 层级路径，自动生成
  final int? sort; // 排序，默认 0
  final bool? isActive; // 是否激活，默认 true
  final bool? hasChildren; // 是否有子级区域，自动维护
  final DateTime? createdAt; // 创建时间
  final DateTime? updatedAt; // 更新时间

  AreaLocation({
    this.mongoId,
    this.id,
    this.label,
    this.parentId,
    this.level,
    this.path,
    this.sort,
    this.isActive,
    this.hasChildren,
    this.createdAt,
    this.updatedAt,
  });

  factory AreaLocation.fromJson(Map<String, dynamic> json) {
    try {
      // 安全地处理每个字段
      String? mongoId;
      String? id;
      String? label;
      String? parentId;
      int? level;
      String? path;
      int? sort;
      bool? isActive;
      bool? hasChildren;
      DateTime? createdAt;
      DateTime? updatedAt;

      // 处理 MongoDB _id 字段
      if (json['_id'] != null) {
        mongoId = json['_id'].toString();
      }

      // 处理 id 字段
      if (json['id'] != null) {
        id = json['id'].toString();
      }

      // 处理 label 字段
      if (json['label'] != null) {
        label = json['label'].toString();
      }

      // 处理 parentId 字段
      if (json['parentId'] != null) {
        parentId = json['parentId'].toString();
      }

      // 处理 level 字段
      if (json['level'] != null) {
        if (json['level'] is int) {
          level = json['level'];
        } else if (json['level'] is String) {
          level = int.tryParse(json['level']);
        } else if (json['level'] is double) {
          level = json['level'].toInt();
        }
      }

      // 处理 path 字段
      if (json['path'] != null) {
        path = json['path'].toString();
      }

      // 处理 sort 字段
      if (json['sort'] != null) {
        if (json['sort'] is int) {
          sort = json['sort'];
        } else if (json['sort'] is String) {
          sort = int.tryParse(json['sort']);
        } else if (json['sort'] is double) {
          sort = json['sort'].toInt();
        }
      }

      // 处理 isActive 字段
      if (json['isActive'] != null) {
        if (json['isActive'] is bool) {
          isActive = json['isActive'];
        } else if (json['isActive'] is String) {
          isActive = json['isActive'].toLowerCase() == 'true';
        } else if (json['isActive'] is int) {
          isActive = json['isActive'] == 1;
        }
      }

      // 处理 hasChildren 字段
      if (json['hasChildren'] != null) {
        if (json['hasChildren'] is bool) {
          hasChildren = json['hasChildren'];
        } else if (json['hasChildren'] is String) {
          hasChildren = json['hasChildren'].toLowerCase() == 'true';
        } else if (json['hasChildren'] is int) {
          hasChildren = json['hasChildren'] == 1;
        }
      }

      // 处理日期字段
      if (json['createdAt'] != null) {
        createdAt = DateTime.tryParse(json['createdAt'].toString());
      }

      if (json['updatedAt'] != null) {
        updatedAt = DateTime.tryParse(json['updatedAt'].toString());
      }

      return AreaLocation(
        mongoId: mongoId,
        id: id,
        label: label,
        parentId: parentId,
        level: level,
        path: path,
        sort: sort,
        isActive: isActive,
        hasChildren: hasChildren,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      // 返回一个默认的区域位置对象
      return AreaLocation(
        id: 'error',
        label: '解析失败',
        level: 0,
        sort: 0,
        isActive: false,
        hasChildren: false,
      );
    }
  }

  /// 转换为 JSON（用于创建和更新请求）
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (id != null) data['id'] = id;
    if (label != null) data['label'] = label;
    if (parentId != null) data['parentId'] = parentId;
    if (level != null) data['level'] = level;
    if (sort != null) data['sort'] = sort;
    if (isActive != null) data['isActive'] = isActive;
    
    return data;
  }

  /// 创建副本，用于更新操作
  AreaLocation copyWith({
    String? mongoId,
    String? id,
    String? label,
    String? parentId,
    int? level,
    String? path,
    int? sort,
    bool? isActive,
    bool? hasChildren,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AreaLocation(
      mongoId: mongoId ?? this.mongoId,
      id: id ?? this.id,
      label: label ?? this.label,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      path: path ?? this.path,
      sort: sort ?? this.sort,
      isActive: isActive ?? this.isActive,
      hasChildren: hasChildren ?? this.hasChildren,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AreaLocation{id: $id, label: $label, parentId: $parentId, level: $level, path: $path, sort: $sort, isActive: $isActive, hasChildren: $hasChildren}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AreaLocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}