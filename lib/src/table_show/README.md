# TableShow 组件

TableShow 是一个功能强大的表格展示组件，支持固定列、自定义样式、动态行高等特性，适用于各种数据展示场景。

## 示例展示

<img src="Snipaste_2025-10-15_14-33-10.png" width="300" alt="基础表格展示" />
<img src="Snipaste_2025-10-15_14-33-25.png" width="300" alt="固定列表格" />
<img src="Snipaste_2025-10-15_14-33-40.png" width="300" alt="自定义样式表格" />

## 功能特性

- **固定列支持** - 左侧列可固定，右侧列可水平滚动
- **自定义样式** - 支持自定义表头和单元格样式
- **动态行高** - 支持根据内容动态计算行高
- **边框圆角** - 支持自定义边框颜色和圆角
- **响应式布局** - 自动适应不同屏幕尺寸
- **空数据处理** - 优雅处理空数据状态

## 基础用法

### 简单表格

```dart
import 'package:flutter_simple_ui/src/table_show/index.dart';

TableShow(
  columns: const [
    {'label': '姓名', 'prop': 'name', 'width': 120},
    {'label': '年龄', 'prop': 'age', 'width': 80},
    {'label': '城市', 'prop': 'city', 'width': 100},
  ],
  data: const [
    {'name': '张三', 'age': 25, 'city': '北京'},
    {'name': '李四', 'age': 30, 'city': '上海'},
    {'name': '王五', 'age': 28, 'city': '深圳'},
  ],
)
```

### 固定列表格

```dart
TableShow(
  columns: const [
    {'label': 'ID', 'prop': 'id', 'width': 80, 'fixed': true},
    {'label': '姓名', 'prop': 'name', 'width': 120, 'fixed': true},
    {'label': '部门', 'prop': 'department', 'width': 100},
    {'label': '职位', 'prop': 'position', 'width': 120},
    {'label': '邮箱', 'prop': 'email', 'width': 200},
    {'label': '电话', 'prop': 'phone', 'width': 150},
  ],
  data: const [
    {
      'id': 1,
      'name': '张三',
      'department': '技术部',
      'position': '工程师',
      'email': 'zhangsan@company.com',
      'phone': '13800138001',
    },
    // 更多数据...
  ],
  rowHeight: 50,
  headerHeight: 50,
)
```

### 自定义样式表格

```dart
TableShow(
  columns: const [
    {'label': '产品名称', 'prop': 'name', 'width': 150},
    {'label': '价格', 'prop': 'price', 'width': 100},
    {'label': '状态', 'prop': 'status', 'width': 100},
  ],
  data: const [
    {'name': 'iPhone 15 Pro', 'price': '¥8999', 'status': '有库存'},
    {'name': 'MacBook Pro', 'price': '¥12999', 'status': '有库存'},
    {'name': 'iPad Air', 'price': '¥4399', 'status': '缺货'},
  ],
  rowHeight: 60,
  headerHeight: 50,
  headerTextStyle: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Color(0xFF1976D2),
  ),
  cellTextStyle: const TextStyle(
    fontSize: 14,
    color: Color(0xFF333333),
  ),
  borderColor: const Color(0xFF2196F3),
  borderRadius: const BorderRadius.all(Radius.circular(8)),
)
```

### 动态行高表格

```dart
TableShow(
  columns: const [
    {'label': '标题', 'prop': 'title', 'width': 150},
    {'label': '内容', 'prop': 'content', 'width': 300},
  ],
  data: const [
    {'title': '短标题', 'content': '这是一段短内容'},
    {
      'title': '长标题示例',
      'content': '这是一段比较长的内容，包含了很多详细信息，需要更多的空间来展示'
    },
  ],
  rowHeightBuilder: (rowIndex, row) {
    // 根据内容长度动态计算行高
    final content = row['content']?.toString() ?? '';
    final baseHeight = 44.0;
    final contentLines = (content.length / 30).ceil();
    return baseHeight + (contentLines - 1) * 20.0;
  },
  headerTextStyle: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: Color(0xFF2E7D32),
  ),
  cellTextStyle: const TextStyle(
    fontSize: 13,
    color: Color(0xFF424242),
  ),
)
```

## 高级用法

### 完整配置示例

```dart
TableShow(
  columns: const [
    {'label': 'ID', 'prop': 'id', 'width': 60, 'fixed': true},
    {'label': '用户名', 'prop': 'username', 'width': 120, 'fixed': true},
    {'label': '邮箱', 'prop': 'email', 'width': 200},
    {'label': '部门', 'prop': 'department', 'width': 120},
    {'label': '角色', 'prop': 'role', 'width': 100},
    {'label': '状态', 'prop': 'status', 'width': 80},
    {'label': '创建时间', 'prop': 'createTime', 'width': 150},
    {'label': '最后登录', 'prop': 'lastLogin', 'width': 150},
  ],
  data: userData,
  rowHeight: 48,
  headerHeight: 52,
  defaultColumnWidth: 120,
  borderColor: const Color(0xFFE0E0E0),
  borderRadius: const BorderRadius.all(Radius.circular(6)),
  headerTextStyle: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: Color(0xFF37474F),
  ),
  cellTextStyle: const TextStyle(
    fontSize: 13,
    color: Color(0xFF546E7A),
  ),
  rowHeightBuilder: (index, row) {
    // 特殊行可以有不同高度
    if (row['role'] == 'admin') {
      return 56.0; // 管理员行稍高
    }
    return 48.0; // 默认行高
  },
)
```

### 响应式表格

```dart
class ResponsiveTableShow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return TableShow(
      columns: [
        {'label': 'ID', 'prop': 'id', 'width': isSmallScreen ? 50 : 80, 'fixed': true},
        {'label': '姓名', 'prop': 'name', 'width': isSmallScreen ? 80 : 120, 'fixed': true},
        {'label': '邮箱', 'prop': 'email', 'width': isSmallScreen ? 150 : 200},
        if (!isSmallScreen) {'label': '部门', 'prop': 'department', 'width': 120},
        if (!isSmallScreen) {'label': '电话', 'prop': 'phone', 'width': 150},
      ],
      data: tableData,
      rowHeight: isSmallScreen ? 40 : 48,
      headerHeight: isSmallScreen ? 36 : 44,
      cellTextStyle: TextStyle(
        fontSize: isSmallScreen ? 12 : 14,
        color: const Color(0xFF333333),
      ),
    );
  }
}
```

## API 参考

### TableShow 属性

| 属性                 | 类型                                          | 默认值              | 说明             |
| -------------------- | --------------------------------------------- | ------------------- | ---------------- |
| `columns`            | `List<Map<String, dynamic>>`                  | **必需**            | 列定义数组       |
| `data`               | `List<Map<String, dynamic>>`                  | **必需**            | 数据数组         |
| `rowHeight`          | `double`                                      | `44.0`              | 默认行高         |
| `headerHeight`       | `double`                                      | `44.0`              | 表头高度         |
| `defaultColumnWidth` | `double`                                      | `120.0`             | 默认列宽         |
| `borderColor`        | `Color`                                       | `Color(0xFFE0E0E0)` | 边框颜色         |
| `borderRadius`       | `BorderRadius?`                               | `null`              | 圆角设置         |
| `headerTextStyle`    | `TextStyle?`                                  | `null`              | 表头文字样式     |
| `cellTextStyle`      | `TextStyle?`                                  | `null`              | 单元格文字样式   |
| `rowHeightBuilder`   | `double Function(int, Map<String, dynamic>)?` | `null`              | 动态行高计算函数 |

### 列定义 (Column)

每个列定义是一个 `Map<String, dynamic>`，支持以下属性：

| 属性    | 类型     | 必需 | 说明                                      |
| ------- | -------- | ---- | ----------------------------------------- |
| `label` | `String` | ✓    | 列标题                                    |
| `prop`  | `String` | ✓    | 数据属性名                                |
| `width` | `double` | ✗    | 列宽度，未设置时使用 `defaultColumnWidth` |
| `fixed` | `bool`   | ✗    | 是否固定列，默认 `false`                  |

### 回调函数

#### rowHeightBuilder

```dart
double Function(int rowIndex, Map<String, dynamic> rowData)?
```

- `rowIndex`: 行索引（从 0 开始）
- `rowData`: 当前行的数据
- 返回值: 该行的高度

## 样式定制

### 默认样式

```dart
// 默认表头样式
const TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: Color(0xFF333333),
)

// 默认单元格样式
const TextStyle(
  fontSize: 14,
  color: Color(0xFF666666),
)

// 默认边框颜色
const Color(0xFFE0E0E0)
```

### 主题适配

```dart
TableShow(
  columns: columns,
  data: data,
  headerTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
    fontWeight: FontWeight.w600,
    color: Theme.of(context).primaryColor,
  ),
  cellTextStyle: Theme.of(context).textTheme.bodyMedium,
  borderColor: Theme.of(context).dividerColor,
)
```

## 使用限制

1. **数据格式**: 数据必须是 `List<Map<String, dynamic>>` 格式
2. **列属性**: `prop` 必须对应数据中的键名
3. **固定列**: 固定列会按定义顺序显示在左侧
4. **性能**: 大量数据时建议使用分页或虚拟滚动
5. **宽度**: 组件会占用父容器的全部宽度

## 最佳实践

### 1. 列宽设置

```dart
// 推荐：根据内容设置合适的列宽
const columns = [
  {'label': 'ID', 'prop': 'id', 'width': 60},           // 短内容用小宽度
  {'label': '姓名', 'prop': 'name', 'width': 100},       // 中等内容
  {'label': '邮箱', 'prop': 'email', 'width': 200},      // 长内容用大宽度
  {'label': '状态', 'prop': 'status', 'width': 80},      // 状态类用小宽度
];
```

### 2. 固定列使用

```dart
// 推荐：将关键信息列设为固定
const columns = [
  {'label': 'ID', 'prop': 'id', 'width': 60, 'fixed': true},      // 主键固定
  {'label': '姓名', 'prop': 'name', 'width': 100, 'fixed': true}, // 关键信息固定
  {'label': '详细信息', 'prop': 'detail', 'width': 300},          // 详细信息可滚动
];
```

### 3. 动态行高优化

```dart
// 推荐：缓存计算结果避免重复计算
final Map<int, double> _heightCache = {};

double _calculateRowHeight(int index, Map<String, dynamic> row) {
  if (_heightCache.containsKey(index)) {
    return _heightCache[index]!;
  }

  final content = row['content']?.toString() ?? '';
  final height = 44.0 + (content.length / 50).ceil() * 20.0;
  _heightCache[index] = height;
  return height;
}
```

### 4. 空数据处理

```dart
// 推荐：提供空数据状态
Widget buildTable() {
  if (data.isEmpty) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '暂无数据',
        style: TextStyle(color: Color(0xFF999999)),
      ),
    );
  }

  return TableShow(
    columns: columns,
    data: data,
  );
}
```

## 注意事项

1. **性能考虑**: 大量数据时建议分页显示
2. **内存管理**: 动态行高时注意缓存策略
3. **响应式**: 小屏幕时考虑隐藏部分列
4. **可访问性**: 重要数据建议设为固定列
5. **样式一致性**: 保持与应用整体风格一致

## 常见问题

### Q: 如何实现表格排序？

A: 组件本身不提供排序功能，需要在数据层面处理：

```dart
List<Map<String, dynamic>> sortedData = List.from(originalData);
sortedData.sort((a, b) => a['name'].compareTo(b['name']));

TableShow(
  columns: columns,
  data: sortedData,
)
```

### Q: 如何实现行选择？

A: 可以通过添加选择列和状态管理实现：

```dart
final List<bool> selectedRows = List.filled(data.length, false);

TableShow(
  columns: [
    {
      'label': '',
      'prop': 'selected',
      'width': 50,
      'fixed': true,
    },
    ...otherColumns,
  ],
  data: data.asMap().entries.map((entry) {
    final index = entry.key;
    final row = Map<String, dynamic>.from(entry.value);
    row['selected'] = Checkbox(
      value: selectedRows[index],
      onChanged: (value) {
        setState(() {
          selectedRows[index] = value ?? false;
        });
      },
    );
    return row;
  }).toList(),
)
```

### Q: 如何处理长文本？

A: 使用动态行高或文本截断：

```dart
// 方案1: 动态行高
rowHeightBuilder: (index, row) {
  final text = row['description']?.toString() ?? '';
  return 44.0 + (text.length / 30).ceil() * 20.0;
}

// 方案2: 文本截断（在数据处理时）
final processedData = data.map((row) {
  final newRow = Map<String, dynamic>.from(row);
  final description = newRow['description']?.toString() ?? '';
  if (description.length > 50) {
    newRow['description'] = '${description.substring(0, 50)}...';
  }
  return newRow;
}).toList();
```
