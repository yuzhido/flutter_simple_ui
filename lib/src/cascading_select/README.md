# CascadingSelect 级联选择组件

一个功能强大的三级级联选择组件，支持多选和单选两种模式。

## 示例展示

<img src="Snipaste_2025-10-15_14-05-30.png" width="300" alt="级联选择基本界面" />
<img src="Snipaste_2025-10-15_14-05-45.png" width="300" alt="级联选择多选模式" />
<img src="Snipaste_2025-10-15_14-06-00.png" width="300" alt="级联选择单选模式" />

## 功能特性

- 🎯 支持三级级联数据结构
- 🔄 支持多选和单选两种模式
- 📱 响应式设计，支持横向滚动
- 🎨 美观的UI设计，支持自定义样式
- ✅ 支持"不限"选项（多选模式）
- 🔍 实时显示选择状态

## 使用示例

### 基本用法

```dart
import 'package:flutter/material.dart';
import 'package:simple_ui_for_flutter/simple_ui_for_flutter.dart';

class CascadingSelectExample extends StatefulWidget {
  @override
  _CascadingSelectExampleState createState() => _CascadingSelectExampleState();
}

class _CascadingSelectExampleState extends State<CascadingSelectExample> {
  List<CascadingItem<String>> _buildOptions() {
    return [
      CascadingItem(
        label: '广东省',
        value: 'guangdong',
        children: [
          CascadingItem(
            label: '广州市',
            value: 'guangzhou',
            children: [
              CascadingItem(label: '天河区', value: 'tianhe'),
              CascadingItem(label: '越秀区', value: 'yuexiu'),
              CascadingItem(label: '海珠区', value: 'haizhu'),
            ],
          ),
          CascadingItem(
            label: '深圳市',
            value: 'shenzhen',
            children: [
              CascadingItem(label: '南山区', value: 'nanshan'),
              CascadingItem(label: '福田区', value: 'futian'),
              CascadingItem(label: '罗湖区', value: 'luohu'),
            ],
          ),
        ],
      ),
      CascadingItem(
        label: '北京市',
        value: 'beijing',
        children: [
          CascadingItem(
            label: '北京市',
            value: 'beijing_city',
            children: [
              CascadingItem(label: '朝阳区', value: 'chaoyang'),
              CascadingItem(label: '海淀区', value: 'haidian'),
              CascadingItem(label: '西城区', value: 'xicheng'),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('级联选择示例')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 多选模式
            CascadingSelect<String>(
              options: _buildOptions(),
              title: '选择地区（多选）',
              multiple: true,
              showUnlimited: true,
              defaultSelectedValues: ['tianhe', 'nanshan'],
              onConfirm: (selected) {
                print('多选结果: ${selected.map((e) => e.label).join(', ')}');
              },
            ),
            SizedBox(height: 20),
            // 单选模式
            CascadingSelect<String>(
              options: _buildOptions(),
              title: '选择地区（单选）',
              multiple: false,
              onConfirm: (selected) {
                print('单选路径: ${selected.map((e) => e.label).join(' -> ')}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### 带额外数据的用法

```dart
class ExtraDataExample extends StatelessWidget {
  List<CascadingItem<Map<String, dynamic>>> _buildOptionsWithExtra() {
    return [
      CascadingItem(
        label: '电子产品',
        value: 'electronics',
        extra: {'icon': Icons.phone_android, 'color': Colors.blue},
        children: [
          CascadingItem(
            label: '手机',
            value: 'phone',
            extra: {'price_range': '1000-8000'},
            children: [
              CascadingItem(
                label: 'iPhone',
                value: 'iphone',
                extra: {'brand': 'Apple', 'popularity': 95},
              ),
              CascadingItem(
                label: '华为',
                value: 'huawei',
                extra: {'brand': 'Huawei', 'popularity': 88},
              ),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CascadingSelect<Map<String, dynamic>>(
      options: _buildOptionsWithExtra(),
      title: '选择产品',
      onConfirm: (selected) {
        for (var item in selected) {
          print('选中: ${item.label}, 额外数据: ${item.extra}');
        }
      },
    );
  }
}
```

## API 参考

### CascadingSelect

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `options` | `List<CascadingItem<T>>` | **必需** | 三级级联数据源 |
| `title` | `String` | `'三级联选多选'` | 弹窗顶部标题 |
| `multiple` | `bool` | `true` | 选择模式：true=多选，false=单选 |
| `showUnlimited` | `bool` | `true` | 是否显示"不限"选项（仅多选模式有效） |
| `defaultSelectedValues` | `List<dynamic>?` | `null` | 默认选中的第三级value列表（仅多选模式） |
| `onConfirm` | `Function(List<CascadingItem<T>>)?` | `null` | 确认选择回调 |

### CascadingItem

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `label` | `String` | **必需** | 显示文本 |
| `value` | `dynamic` | **必需** | 选项值，用于唯一标识 |
| `extra` | `T?` | `null` | 额外数据，可以是任意类型 |
| `children` | `List<CascadingItem<T>>` | `[]` | 子级选项列表 |

## 回调说明

### onConfirm 回调

- **多选模式**：返回所有选中的第三级项的列表
- **单选模式**：返回当前选中的路径 `[一级, 二级, 三级]`

```dart
onConfirm: (List<CascadingItem<T>> selected) {
  if (multiple) {
    // 多选模式：selected 包含所有选中的第三级项
    print('选中的项目: ${selected.map((e) => e.label).join(', ')}');
  } else {
    // 单选模式：selected 包含选择路径 [一级, 二级, 三级]
    print('选择路径: ${selected.map((e) => e.label).join(' -> ')}');
  }
}
```

## 样式定制

组件使用了预定义的颜色和样式，主要包括：

- 主色调：`#007AFF`（iOS蓝）
- 背景色：白色和浅灰色渐变
- 圆角：8px 和 10px
- 阴影：轻微的投影效果

如需自定义样式，可以通过修改组件源码中的颜色常量来实现。

## 注意事项

1. **数据结构**：确保数据是三级结构，每级都有 `label` 和 `value` 属性
2. **唯一性**：每个选项的 `value` 应该是唯一的，用于标识选项
3. **性能**：对于大量数据，建议进行分页或懒加载处理
4. **多选模式**："不限"选项与具体选项互斥，选择"不限"会清除该二级下的所有具体选项
5. **单选模式**：每级都是单选，不会自动选中下级选项

## 完整示例

查看 `example/` 目录中的完整示例代码，了解更多使用场景和最佳实践。