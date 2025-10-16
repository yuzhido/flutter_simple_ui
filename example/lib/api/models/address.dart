/// 地址数据模型（基于 MongoDB Address Schema）
class Address {
  final String? id; // MongoDB _id
  final String name; // 地址名称
  final String? parentId; // 父级地址 ID
  final int level; // 层级
  final bool hasChildren; // 是否有子级
  final int sort; // 排序
  final int status; // 状态（1-启用，0-禁用）
  final String? description; // 描述
  final String path; // 路径
  final DateTime? createdAt; // 创建时间
  final DateTime? updatedAt; // 更新时间
  final List<Address>? children; // 子级地址（用于树形结构）

  Address({
    this.id,
    required this.name,
    this.parentId,
    this.level = 1,
    this.hasChildren = false,
    this.sort = 0,
    this.status = 1,
    this.description,
    this.path = '',
    this.createdAt,
    this.updatedAt,
    this.children,
  });

  /// 从 JSON 创建 Address 对象
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id']?.toString(),
      name: json['name']?.toString() ?? '',
      parentId: json['parentId']?.toString(),
      level: json['level'] ?? 1,
      hasChildren: json['hasChildren'] ?? false,
      sort: json['sort'] ?? 0,
      status: json['status'] ?? 1,
      description: json['description']?.toString(),
      path: json['path']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      children: json['children'] != null ? (json['children'] as List).map((child) => Address.fromJson(child)).toList() : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'name': name, 'level': level, 'hasChildren': hasChildren, 'sort': sort, 'status': status, 'path': path};

    if (id != null) data['_id'] = id;
    if (parentId != null) data['parentId'] = parentId;
    if (description != null) data['description'] = description;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    if (children != null) {
      data['children'] = children!.map((child) => child.toJson()).toList();
    }

    return data;
  }

  /// 创建副本
  Address copyWith({
    String? id,
    String? name,
    String? parentId,
    int? level,
    bool? hasChildren,
    int? sort,
    int? status,
    String? description,
    String? path,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Address>? children,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      hasChildren: hasChildren ?? this.hasChildren,
      sort: sort ?? this.sort,
      status: status ?? this.status,
      description: description ?? this.description,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      children: children ?? this.children,
    );
  }

  @override
  String toString() {
    return 'Address{id: $id, name: $name, parentId: $parentId, level: $level, hasChildren: $hasChildren}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

/// 地址查询请求参数
class AddressQueryRequest {
  final String? parentId; // 父级 ID
  final String? kw; // 关键字搜索

  AddressQueryRequest({this.parentId, this.kw});

  Map<String, dynamic> toJson() {
    return {'parentId': parentId ?? '', 'kw': kw ?? ''};
  }
}

/// 地址树形查询请求参数
class AddressTreeRequest {
  final String? parentId; // 父级 ID
  final String? keyword; // 搜索关键字

  AddressTreeRequest({this.parentId, this.keyword});

  Map<String, dynamic> toJson() {
    return {'parentId': parentId, 'keyword': keyword ?? ''};
  }
}

/// 地址搜索请求参数
class AddressSearchRequest {
  final String? keyword; // 搜索关键字
  final int page; // 页码
  final int limit; // 每页数量
  final String? parentId; // 父级 ID 筛选
  final int? level; // 层级筛选
  final int? status; // 状态筛选

  AddressSearchRequest({this.keyword, this.page = 1, this.limit = 20, this.parentId, this.level, this.status});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'page': page, 'limit': limit};

    if (keyword != null && keyword!.isNotEmpty) data['keyword'] = keyword;
    if (parentId != null) data['parentId'] = parentId;
    if (level != null) data['level'] = level;
    if (status != null) data['status'] = status;

    return data;
  }
}

/// 地址创建请求参数
class AddressCreateRequest {
  final String name; // 地址名称
  final String? parentId; // 父级地址 ID
  final String? description; // 描述
  final int sort; // 排序

  AddressCreateRequest({required this.name, this.parentId, this.description, this.sort = 0});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'name': name, 'sort': sort};

    if (parentId != null) data['parentId'] = parentId;
    if (description != null) data['description'] = description;

    return data;
  }
}

/// 地址更新请求参数
class AddressUpdateRequest {
  final String? name; // 地址名称
  final String? parentId; // 父级地址 ID
  final String? description; // 描述
  final int? sort; // 排序
  final int? status; // 状态

  AddressUpdateRequest({this.name, this.parentId, this.description, this.sort, this.status});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (parentId != null) data['parentId'] = parentId;
    if (description != null) data['description'] = description;
    if (sort != null) data['sort'] = sort;
    if (status != null) data['status'] = status;

    return data;
  }
}

/// 地址删除请求参数
class AddressDeleteRequest {
  final bool force; // 是否强制删除（包含子级）

  AddressDeleteRequest({this.force = false});

  Map<String, dynamic> toJson() {
    return {'force': force};
  }
}

/// 分页信息
class Pagination {
  final int total; // 总数
  final int page; // 当前页
  final int limit; // 每页数量
  final int pages; // 总页数

  Pagination({required this.total, required this.page, required this.limit, required this.pages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(total: json['total'] ?? 0, page: json['page'] ?? 1, limit: json['limit'] ?? 20, pages: json['pages'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'page': page, 'limit': limit, 'pages': pages};
  }
}

/// 地址搜索响应
class AddressSearchResponse {
  final List<Address> list; // 地址列表
  final Pagination pagination; // 分页信息

  AddressSearchResponse({required this.list, required this.pagination});

  factory AddressSearchResponse.fromJson(Map<String, dynamic> json) {
    return AddressSearchResponse(list: (json['list'] as List? ?? []).map((item) => Address.fromJson(item)).toList(), pagination: Pagination.fromJson(json['pagination'] ?? {}));
  }

  Map<String, dynamic> toJson() {
    return {'list': list.map((address) => address.toJson()).toList(), 'pagination': pagination.toJson()};
  }
}