# NoticeInfo 消息通知组件

一个功能丰富的消息通知组件，支持自动滚动、点击事件和自定义样式。

## 示例展示

<img src="Snipaste_2025-10-15_14-30-14.png" width="300" alt="消息通知基本样式" />
<img src="Snipaste_2025-10-15_14-30-30.png" width="300" alt="消息通知滚动效果" />

## 功能特性

- **消息展示**: 支持自定义消息内容
- **点击交互**: 可添加点击事件处理
- **自动滚动**: 当文本过长时自动启用滚动功能
- **无缝滚动**: 支持无缝无限循环滚动效果
- **自定义样式**: 可自定义高度、内边距等样式
- **智能检测**: 自动检测文本长度决定是否启用滚动
- **动画控制**: 可自定义滚动速度和暂停时间

## 基础用法

### 简单消息通知

```dart
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

// 默认消息
NoticeInfo()

// 自定义消息
NoticeInfo(
  message: '这是一条自定义消息通知',
)
```

### 带点击事件

```dart
NoticeInfo(
  message: '点击我查看详情',
  onTap: () {
    // 处理点击事件
    print('消息被点击了');
  },
)
```

### 自定义样式

```dart
NoticeInfo(
  message: '自定义样式的通知',
  height: 60.0,
  padding: EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 16.0
  ),
)
```

## 滚动功能

### 启用自动滚动

```dart
NoticeInfo(
  message: '这是一条超长的消息通知，当文本内容超出容器宽度时，会自动启用无限循环滚动功能。',
  enableScroll: true,
)
```

### 自定义滚动参数

```dart
NoticeInfo(
  message: '自定义滚动速度和暂停时间的消息',
  enableScroll: true,
  scrollDuration: Duration(seconds: 5),  // 滚动持续时间
  pauseDuration: Duration(seconds: 1),   // 暂停时间
  seamless: true,                        // 无缝滚动
)
```

### 长文本滚动示例

```dart
NoticeInfo(
  message: '这是一条非常非常长的消息通知，包含了大量的文字内容，用来演示当文本内容远远超出容器宽度时的滚动效果。',
  enableScroll: true,
  scrollDuration: Duration(seconds: 8),
  pauseDuration: Duration(seconds: 3),
)
```

## 完整示例

```dart
class NoticeInfoExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('消息通知示例')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基础用法
            NoticeInfo(),
            SizedBox(height: 16),

            // 自定义消息
            NoticeInfo(
              message: '重要通知：系统将于今晚进行维护',
            ),
            SizedBox(height: 16),

            // 带点击事件
            NoticeInfo(
              message: '点击查看活动详情',
              onTap: () {
                // 跳转到详情页面
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DetailPage()));
              },
            ),
            SizedBox(height: 16),

            // 长文本滚动
            NoticeInfo(
              message: '这是一条很长的消息，会自动检测是否需要滚动显示',
              enableScroll: true,
              scrollDuration: Duration(seconds: 6),
              pauseDuration: Duration(seconds: 2),
            ),
          ],
        ),
      ),
    );
  }
}
```

## API 参考

### NoticeInfo 属性

| 属性             | 类型                  | 默认值                  | 说明             |
| ---------------- | --------------------- | ----------------------- | ---------------- |
| `message`        | `String`              | `'恭述提示文字'`        | 显示的消息内容   |
| `onTap`          | `VoidCallback?`       | `null`                  | 点击事件回调     |
| `padding`        | `EdgeInsetsGeometry?` | `null`                  | 内边距           |
| `height`         | `double?`             | `null`                  | 组件高度         |
| `enableScroll`   | `bool`                | `false`                 | 是否启用滚动功能 |
| `scrollDuration` | `Duration`            | `Duration(seconds: 10)` | 滚动持续时间     |
| `pauseDuration`  | `Duration`            | `Duration(seconds: 2)`  | 滚动暂停时间     |
| `seamless`       | `bool`                | `true`                  | 是否启用无缝滚动 |

### 回调函数

#### onTap

```dart
VoidCallback? onTap
```

当用户点击消息通知时触发的回调函数。

## 滚动机制说明

### 自动检测

- 组件会自动检测文本内容是否超出容器宽度
- 只有在文本过长且 `enableScroll` 为 `true` 时才会启用滚动
- 短文本不会触发滚动效果

### 滚动类型

- **无缝滚动** (`seamless: true`): 使用动画控制器实现平滑的无限循环滚动
- **标准滚动** (`seamless: false`): 使用 ScrollController 实现传统滚动

### 性能优化

- 滚动动画只在需要时创建和启动
- 组件销毁时自动清理动画控制器
- 支持动态更新消息内容和滚动参数

## 样式自定义

### 基础样式

```dart
NoticeInfo(
  message: '自定义样式',
  height: 50.0,
  padding: EdgeInsets.all(12.0),
)
```

### 结合主题使用

```dart
NoticeInfo(
  message: '主题样式通知',
  padding: EdgeInsets.symmetric(
    horizontal: Theme.of(context).spacing.medium,
    vertical: Theme.of(context).spacing.small,
  ),
)
```

## 使用限制

1. **文本内容**: 建议消息内容不要过于复杂，保持简洁明了
2. **滚动性能**: 超长文本可能影响滚动性能，建议合理控制文本长度
3. **点击区域**: 整个组件区域都是可点击的，注意避免误触
4. **动画资源**: 启用滚动时会创建动画控制器，注意内存使用

## 最佳实践

1. **消息内容**: 保持消息简洁，突出重点信息
2. **滚动设置**: 根据消息长度合理设置滚动速度
3. **用户体验**: 重要消息可以禁用滚动，确保用户能完整阅读
4. **交互反馈**: 添加点击事件时提供适当的视觉反馈
5. **性能考虑**: 在列表中使用时注意控制滚动动画的数量

## 注意事项

- 滚动功能需要设置 `enableScroll: true` 才会生效
- 无缝滚动模式下，文本会无限循环显示
- 组件会自动处理文本测量和滚动检测
- 支持动态更新消息内容，会自动重新检测是否需要滚动
- 在页面销毁时会自动清理相关资源
