# TreeSelect 组件

TreeSelect 是一个功能强大的树形结构数据选择组件，支持单选、多选、远程搜索、懒加载、本地过滤等多种特性，适用于组织架构、地区选择、商品分类等各种树形数据选择场景。

## 示例展示

<img src="Snipaste_2025-10-15_14-34-10.png" width="300" alt="树形选择基本界面" />
<img src="Snipaste_2025-10-15_14-34-25.png" width="300" alt="树形选择展开状态" />
<img src="Snipaste_2025-10-15_14-34-40.png" width="300" alt="树形选择多选模式" />

## 功能特性

- **单选/多选模式** - 支持单选和多选两种选择模式
- **树形结构展示** - 支持多层级树形数据的展开和收起
- **远程搜索** - 支持远程数据搜索和动态加载
- **懒加载** - 支持按需加载子节点数据，提升性能
- **本地过滤** - 支持在本地数据中进行关键字过滤
- **数据缓存** - 支持数据缓存，避免重复请求
- **默认值设置** - 支持设置默认选中值
- **自动展开** - 自动展开到选中值的路径
- **加载状态** - 提供加载状态指示器

## 基础用法

### 简单单选

```dart
import 'package:flutter_simple_ui/src/tree_select/index.dart';

TreeSelect<String>(
  title: '选择城市',
  options: [
    SelectData(
      label: '北京市',
      value: 'beijing',
      data: 'beijing',
      hasChildren: true,
      children: [
        SelectData(label: '朝阳区', value: 'chaoyang', data: 'chaoyang'),
        SelectData(label: '海淀区', value: 'haidian', data: 'haidian'),
      ],
    ),
    SelectData(
      label: '上海市',
      value: 'shanghai',
      data: 'shanghai',
      hasChildren: true,
      children: [
        SelectData(label: '浦东新区', value: 'pudong', data: 'pudong'),
        SelectData(label: '黄浦区', value: 'huangpu', data: 'huangpu'),
      ],
    ),
  ],
  onSingleChanged: (value, data, selectedItem) {
    print('选中: ${selectedItem.label}');
  },
)
```

### 多选模式

```dart
TreeSelect<String>(
  title: '选择多个城市',
  multiple: true,
  options: cityData,
  defaultValue: [
    SelectData(label: '北京市', value: 'beijing', data: 'beijing'),
  ],
  onMultipleChanged: (values, dataList, selectedItems) {
    print('选中的城市: ${selectedItems.map((e) => e.label).join(', ')}');
  },
)
```

### 本地过滤

```dart
TreeSelect<String>(
  title: '选择城市（支持搜索）',
  filterable: true,
  hintText: '请输入城市名称搜索',
  options: cityData,
  onSingleChanged: (value, data, selectedItem) {
    print('选中: ${selectedItem.label}');
  },
)
```

### 远程搜索

```dart
// 远程搜索函数
Future<List<SelectData<String>>> remoteSearch(String keyword) async {
  final response = await http.get(
    Uri.parse('https://api.example.com/search?keyword=$keyword'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => SelectData<String>(
      label: item['name'],
      value: item['id'],
      data: item['id'],
      hasChildren: item['hasChildren'] ?? false,
      children: item['children']?.map<SelectData<String>>((child) =>
        SelectData<String>(
          label: child['name'],
          value: child['id'],
          data: child['id'],
        )
      ).toList(),
    )).toList();
  }

  throw Exception('搜索失败');
}

TreeSelect<String>(
  title: '远程搜索城市',
  remote: true,
  remoteFetch: remoteSearch,
  hintText: '请输入关键字搜索',
  onSingleChanged: (value, data, selectedItem) {
    print('选中: ${selectedItem.label}');
  },
)
```

### 懒加载

```dart
// 懒加载函数
Future<List<SelectData<String>>> lazyLoadChildren(SelectData<String> parent) async {
  // 模拟网络请求
  await Future.delayed(const Duration(milliseconds: 1000));

  switch (parent.value) {
    case 'beijing':
      return [
        SelectData(label: '朝阳区', value: 'chaoyang', data: 'chaoyang'),
        SelectData(label: '海淀区', value: 'haidian', data: 'haidian'),
        SelectData(label: '西城区', value: 'xicheng', data: 'xicheng'),
      ];
    case 'shanghai':
      return [
        SelectData(label: '浦东新区', value: 'pudong', data: 'pudong'),
        SelectData(label: '黄浦区', value: 'huangpu', data: 'huangpu'),
      ];
    default:
      return [];
  }
}

TreeSelect<String>(
  title: '懒加载城市选择',
  lazyLoad: true,
  lazyLoadFetch: lazyLoadChildren,
  options: [
    // 只提供第一级数据，不包含 children
    SelectData(
      label: '北京市',
      value: 'beijing',
      data: 'beijing',
      hasChildren: true, // 标记有子节点
    ),
    SelectData(
      label: '上海市',
      value: 'shanghai',
      data: 'shanghai',
      hasChildren: true,
    ),
  ],
  onSingleChanged: (value, data, selectedItem) {
    print('选中: ${selectedItem.label}');
  },
)
```

## 高级用法

### 完整配置示例

```dart
class CitySelectWidget extends StatefulWidget {
  @override
  _CitySelectWidgetState createState() => _CitySelectWidgetState();
}

class _CitySelectWidgetState extends State<CitySelectWidget> {
  List<SelectData<CityModel>> selectedCities = [];

  @override
  Widget build(BuildContext context) {
    return TreeSelect<CityModel>(
      title: '选择城市',
      tips: '请选择您要查看的城市',
      hintText: '输入城市名称进行搜索',
      multiple: true,
      filterable: true,
      remote: true,
      lazyLoad: true,
      isCacheData: true,
      defaultValue: [
        SelectData(
          label: '北京市',
          value: 'beijing',
          data: CityModel(id: 'beijing', name: '北京市'),
        ),
      ],
      options: initialCityData,
      remoteFetch: _remoteSearchCities,
      lazyLoadFetch: _lazyLoadDistricts,
      onMultipleChanged: (values, dataList, selectedItems) {
        setState(() {
          selectedCities = selectedItems;
        });
        print('选中城市数量: ${selectedItems.length}');
      },
    );
  }

  Future<List<SelectData<CityModel>>> _remoteSearchCities(String keyword) async {
    // 实现远程搜索逻辑
    return await CityService.searchCities(keyword);
  }

  Future<List<SelectData<CityModel>>> _lazyLoadDistricts(SelectData<CityModel> city) async {
    // 实现懒加载逻辑
    return await CityService.getDistricts(city.data.id);
  }
}
```

### 自定义数据模型

```dart
class Department {
  final String id;
  final String name;
  final String? parentId;
  final int level;

  Department({
    required this.id,
    required this.name,
    this.parentId,
    required this.level,
  });
}

class DepartmentSelector extends StatelessWidget {
  final List<Department> departments;
  final Function(Department) onSelected;

  const DepartmentSelector({
    required this.departments,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TreeSelect<Department>(
      title: '选择部门',
      options: _buildDepartmentTree(departments),
      onSingleChanged: (value, data, selectedItem) {
        onSelected(data);
      },
    );
  }

  List<SelectData<Department>> _buildDepartmentTree(List<Department> departments) {
    // 构建树形结构的逻辑
    Map<String?, List<Department>> grouped = {};
    for (var dept in departments) {
      grouped.putIfAbsent(dept.parentId, () => []).add(dept);
    }

    List<SelectData<Department>> buildChildren(String? parentId) {
      return (grouped[parentId] ?? []).map((dept) {
        final children = buildChildren(dept.id);
        return SelectData<Department>(
          label: dept.name,
          value: dept.id,
          data: dept,
          hasChildren: children.isNotEmpty,
          children: children.isNotEmpty ? children : null,
        );
      }).toList();
    }

    return buildChildren(null);
  }
}
```

### 权限管理示例

```dart
class PermissionSelector extends StatefulWidget {
  @override
  _PermissionSelectorState createState() => _PermissionSelectorState();
}

class _PermissionSelectorState extends State<PermissionSelector> {
  List<SelectData<Permission>> selectedPermissions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TreeSelect<Permission>(
          title: '选择权限',
          multiple: true,
          filterable: true,
          options: _buildPermissionTree(),
          onMultipleChanged: (values, dataList, selectedItems) {
            setState(() {
              selectedPermissions = selectedItems;
            });
          },
        ),

        // 显示选中的权限
        if (selectedPermissions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('已选择的权限:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...selectedPermissions.map((perm) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• ${perm.label}'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<SelectData<Permission>> _buildPermissionTree() {
    return [
      SelectData<Permission>(
        label: '用户管理',
        value: 'user',
        data: Permission(id: 'user', name: '用户管理'),
        hasChildren: true,
        children: [
          SelectData<Permission>(
            label: '查看用户',
            value: 'user.view',
            data: Permission(id: 'user.view', name: '查看用户'),
          ),
          SelectData<Permission>(
            label: '编辑用户',
            value: 'user.edit',
            data: Permission(id: 'user.edit', name: '编辑用户'),
          ),
          SelectData<Permission>(
            label: '删除用户',
            value: 'user.delete',
            data: Permission(id: 'user.delete', name: '删除用户'),
          ),
        ],
      ),
      SelectData<Permission>(
        label: '系统设置',
        value: 'system',
        data: Permission(id: 'system', name: '系统设置'),
        hasChildren: true,
        children: [
          SelectData<Permission>(
            label: '基础设置',
            value: 'system.basic',
            data: Permission(id: 'system.basic', name: '基础设置'),
          ),
          SelectData<Permission>(
            label: '高级设置',
            value: 'system.advanced',
            data: Permission(id: 'system.advanced', name: '高级设置'),
          ),
        ],
      ),
    ];
  }
}
```

## API 参考

### TreeSelect 属性

| 属性                | 类型                                                     | 默认值               | 说明             |
| ------------------- | -------------------------------------------------------- | -------------------- | ---------------- |
| `defaultValue`      | `List<SelectData<T>>?`                                   | `null`               | 默认选中值       |
| `options`           | `List<SelectData<T>>`                                    | `[]`                 | 树形数据选项     |
| `onSingleChanged`   | `Function(dynamic, T, SelectData<T>)?`                   | `null`               | 单选模式回调     |
| `onMultipleChanged` | `Function(List<dynamic>, List<T>, List<SelectData<T>>)?` | `null`               | 多选模式回调     |
| `multiple`          | `bool`                                                   | `false`              | 是否多选模式     |
| `title`             | `String?`                                                | `null`               | 弹窗标题         |
| `tips`              | `String?`                                                | `null`               | 提示文本         |
| `hintText`          | `String`                                                 | `'请输入关键字搜索'` | 搜索框提示文本   |
| `remoteFetch`       | `Future<List<SelectData<T>>> Function(String)?`          | `null`               | 远程搜索函数     |
| `remote`            | `bool`                                                   | `false`              | 是否启用远程搜索 |
| `filterable`        | `bool`                                                   | `false`              | 是否启用本地过滤 |
| `lazyLoad`          | `bool`                                                   | `false`              | 是否启用懒加载   |
| `lazyLoadFetch`     | `Future<List<SelectData<T>>> Function(SelectData<T>)?`   | `null`               | 懒加载函数       |
| `isCacheData`       | `bool`                                                   | `true`               | 是否缓存数据     |

### SelectData 数据结构

```dart
class SelectData<T> {
  final String label;           // 显示文本
  final dynamic value;          // 值
  final T data;                // 关联数据
  final bool hasChildren;       // 是否有子节点
  final List<SelectData<T>>? children; // 子节点列表

  const SelectData({
    required this.label,
    required this.value,
    required this.data,
    this.hasChildren = false,
    this.children,
  });
}
```

### 回调函数

#### onSingleChanged (单选回调)

```dart
void Function(dynamic value, T data, SelectData<T> selectedItem)?
```

- `value`: 选中项的 value 值
- `data`: 选中项的 data 数据
- `selectedItem`: 完整的选中项数据

#### onMultipleChanged (多选回调)

```dart
void Function(List<dynamic> values, List<T> dataList, List<SelectData<T>> selectedItems)?
```

- `values`: 所有选中项的 value 值列表
- `dataList`: 所有选中项的 data 数据列表
- `selectedItems`: 所有选中项的完整数据列表

#### remoteFetch (远程搜索函数)

```dart
Future<List<SelectData<T>>> Function(String keyword)?
```

- `keyword`: 搜索关键字
- 返回值: 搜索结果列表

#### lazyLoadFetch (懒加载函数)

```dart
Future<List<SelectData<T>>> Function(SelectData<T> parentItem)?
```

- `parentItem`: 父节点数据
- 返回值: 子节点数据列表

## 数据结构设计

### 基础树形数据

```dart
final List<SelectData<String>> cityData = [
  SelectData(
    label: '北京市',
    value: 'beijing',
    data: 'beijing',
    hasChildren: true,
    children: [
      SelectData(
        label: '朝阳区',
        value: 'chaoyang',
        data: 'chaoyang',
        hasChildren: false,
      ),
      SelectData(
        label: '海淀区',
        value: 'haidian',
        data: 'haidian',
        hasChildren: true,
        children: [
          SelectData(
            label: '中关村街道',
            value: 'zhongguancun',
            data: 'zhongguancun',
          ),
        ],
      ),
    ],
  ),
];
```

### 懒加载数据结构

```dart
// 初始数据（只有第一级）
final List<SelectData<String>> lazyData = [
  SelectData(
    label: '北京市',
    value: 'beijing',
    data: 'beijing',
    hasChildren: true, // 标记有子节点，但不提供 children
  ),
  SelectData(
    label: '上海市',
    value: 'shanghai',
    data: 'shanghai',
    hasChildren: true,
  ),
];

// 懒加载函数返回子节点
Future<List<SelectData<String>>> loadChildren(SelectData<String> parent) async {
  switch (parent.value) {
    case 'beijing':
      return [
        SelectData(label: '朝阳区', value: 'chaoyang', data: 'chaoyang'),
        SelectData(label: '海淀区', value: 'haidian', data: 'haidian'),
      ];
    default:
      return [];
  }
}
```

## 使用场景

### 1. 组织架构选择

```dart
TreeSelect<Department>(
  title: '选择部门',
  multiple: false,
  filterable: true,
  options: departmentData,
  onSingleChanged: (value, data, selectedItem) {
    // 处理部门选择
    print('选中部门: ${data.name}');
  },
)
```

### 2. 地区选择器

```dart
TreeSelect<Region>(
  title: '选择地区',
  multiple: true,
  lazyLoad: true,
  lazyLoadFetch: loadRegionChildren,
  options: provinceData,
  onMultipleChanged: (values, dataList, selectedItems) {
    // 处理地区选择
    print('选中地区: ${dataList.map((r) => r.name).join(', ')}');
  },
)
```

### 3. 商品分类选择

```dart
TreeSelect<Category>(
  title: '选择商品分类',
  remote: true,
  remoteFetch: searchCategories,
  hintText: '搜索分类名称',
  onSingleChanged: (value, data, selectedItem) {
    // 处理分类选择
    print('选中分类: ${data.name}');
  },
)
```

### 4. 权限管理

```dart
TreeSelect<Permission>(
  title: '分配权限',
  multiple: true,
  filterable: true,
  options: permissionData,
  onMultipleChanged: (values, dataList, selectedItems) {
    // 处理权限分配
    assignPermissions(dataList);
  },
)
```

## 性能优化

### 1. 数据缓存

```dart
TreeSelect<String>(
  isCacheData: true, // 启用数据缓存
  remote: true,
  remoteFetch: remoteSearch,
  // 其他配置...
)
```

### 2. 懒加载优化

```dart
// 使用懒加载减少初始数据量
TreeSelect<String>(
  lazyLoad: true,
  options: topLevelData, // 只提供顶级数据
  lazyLoadFetch: (parent) async {
    // 按需加载子数据
    return await loadChildrenData(parent.value);
  },
)
```

### 3. 搜索防抖

```dart
class DebouncedTreeSelect extends StatefulWidget {
  @override
  _DebouncedTreeSelectState createState() => _DebouncedTreeSelectState();
}

class _DebouncedTreeSelectState extends State<DebouncedTreeSelect> {
  Timer? _debounceTimer;

  Future<List<SelectData<String>>> _debouncedSearch(String keyword) async {
    // 取消之前的定时器
    _debounceTimer?.cancel();

    // 创建新的定时器
    final completer = Completer<List<SelectData<String>>>();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final result = await actualSearchFunction(keyword);
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return TreeSelect<String>(
      remote: true,
      remoteFetch: _debouncedSearch,
      // 其他配置...
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
```

## 使用限制

1. **数据格式**: 必须使用 `SelectData<T>` 格式的数据
2. **泛型类型**: `T` 类型必须与 `SelectData<T>` 的泛型类型一致
3. **回调函数**: `remote` 为 `true` 时必须提供 `remoteFetch` 函数
4. **懒加载**: `lazyLoad` 为 `true` 时必须提供 `lazyLoadFetch` 函数
5. **性能**: 大量数据时建议使用懒加载或远程搜索
6. **内存**: 启用缓存时注意内存使用

## 最佳实践

### 1. 数据结构设计

```dart
// 推荐：使用有意义的 value 和 data
SelectData<CityModel>(
  label: '北京市',
  value: 'beijing_001', // 唯一标识
  data: CityModel(id: 'beijing_001', name: '北京市', code: 'BJ'),
  hasChildren: true,
)

// 不推荐：value 和 data 相同且无意义
SelectData<String>(
  label: '北京市',
  value: '北京市',
  data: '北京市',
)
```

### 2. 错误处理

```dart
Future<List<SelectData<String>>> safeRemoteSearch(String keyword) async {
  try {
    return await apiService.searchCities(keyword);
  } catch (e) {
    // 记录错误日志
    debugPrint('搜索失败: $e');

    // 返回空列表或默认数据
    return [];
  }
}
```

### 3. 加载状态处理

```dart
class SmartTreeSelect extends StatefulWidget {
  @override
  _SmartTreeSelectState createState() => _SmartTreeSelectState();
}

class _SmartTreeSelectState extends State<SmartTreeSelect> {
  bool _isLoading = false;

  Future<List<SelectData<String>>> _handleRemoteSearch(String keyword) async {
    setState(() => _isLoading = true);

    try {
      final result = await remoteSearchFunction(keyword);
      return result;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading)
          const LinearProgressIndicator(),
        TreeSelect<String>(
          remote: true,
          remoteFetch: _handleRemoteSearch,
          // 其他配置...
        ),
      ],
    );
  }
}
```

### 4. 默认值处理

```dart
// 推荐：动态设置默认值
TreeSelect<String>(
  key: ValueKey(defaultValue?.first.value), // 确保组件重新渲染
  defaultValue: defaultValue,
  options: options,
  onSingleChanged: (value, data, selectedItem) {
    // 更新状态
    setState(() {
      currentSelection = selectedItem;
    });
  },
)
```

## 注意事项

1. **Key 管理**: 当默认值变化时，建议使用 `ValueKey` 确保组件重新渲染
2. **内存泄漏**: 及时取消定时器和网络请求
3. **数据一致性**: 确保 `value` 在整个数据集中唯一
4. **用户体验**: 提供适当的加载状态和错误提示
5. **性能监控**: 监控大数据量时的性能表现

## 常见问题

### Q: 如何实现级联选择？

A: 使用懒加载模式，根据父节点动态加载子节点：

```dart
Future<List<SelectData<String>>> loadCascadeData(SelectData<String> parent) async {
  // 根据父节点加载对应的子节点
  return await apiService.getChildren(parent.value);
}
```

### Q: 如何实现搜索高亮？

A: 组件内部会自动处理搜索结果，无需额外处理高亮。

### Q: 如何限制选择数量？

A: 在回调函数中进行限制：

```dart
onMultipleChanged: (values, dataList, selectedItems) {
  if (selectedItems.length > 5) {
    // 显示提示信息
    showDialog(/* 提示最多选择5项 */);
    return;
  }
  // 处理正常选择
}
```

### Q: 如何实现全选/反选？

A: 需要在外部实现控制逻辑：

```dart
void selectAll() {
  final allItems = getAllLeafNodes(treeData);
  setState(() {
    selectedItems = allItems;
  });
}

void clearAll() {
  setState(() {
    selectedItems.clear();
  });
}
```
