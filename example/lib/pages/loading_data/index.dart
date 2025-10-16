import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/flutter_simple_ui.dart';

class LoadingDataPage extends StatefulWidget {
  const LoadingDataPage({super.key});
  @override
  State<LoadingDataPage> createState() => _LoadingDataPageState();
}

class _LoadingDataPageState extends State<LoadingDataPage> {
  bool _showOverlay = false;
  double _progress = 0.0;
  bool _isLoading = false;

  void _startProgressDemo() {
    setState(() {
      _progress = 0.0;
      _isLoading = true;
    });

    // 模拟进度更新
    Future.delayed(const Duration(milliseconds: 100), () {
      _updateProgress();
    });
  }

  void _updateProgress() {
    if (_progress < 1.0) {
      setState(() {
        _progress += 0.1;
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        _updateProgress();
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: child,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LoadingData 组件示例'), backgroundColor: Colors.blue[600], foregroundColor: Colors.white),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('1. 基础圆形加载器', const SizedBox(height: 120, child: LoadingData(message: '正在加载用户数据...'))),
                _buildSection(
                  '2. 不同类型的加载器',
                  SizedBox(
                    height: 300,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text('圆形', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              const LoadingData(type: LoadingType.circular, message: '圆形加载', size: LoadingSize.medium),
                              const SizedBox(height: 32),
                              const Text('线性', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              const LoadingData(type: LoadingType.linear, message: '线性加载', size: LoadingSize.medium),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text('点状', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              const LoadingData(type: LoadingType.dots, message: '点状加载', size: LoadingSize.medium),
                              const SizedBox(height: 32),
                              const Text('旋转器', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              const LoadingData(type: LoadingType.spinner, message: '旋转加载', size: LoadingSize.medium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildSection(
                  '3. 不同尺寸',
                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text('小', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            const LoadingData(size: LoadingSize.small, message: '小尺寸'),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('中', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            const LoadingData(size: LoadingSize.medium, message: '中尺寸'),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('大', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            const LoadingData(size: LoadingSize.large, message: '大尺寸'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                _buildSection(
                  '4. 自定义颜色',
                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const LoadingData(color: Colors.red, message: '红色主题', size: LoadingSize.medium),
                        const LoadingData(color: Colors.green, message: '绿色主题', size: LoadingSize.medium),
                        LoadingData(color: Colors.purple, backgroundColor: Colors.purple.withValues(alpha: 0.1), message: '紫色主题', size: LoadingSize.medium),
                      ],
                    ),
                  ),
                ),
                _buildSection(
                  '5. 进度指示器',
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoadingData(type: LoadingType.circular, progress: _progress, message: '圆形进度: ${(_progress * 100).toInt()}%', size: LoadingSize.medium, color: Colors.blue),
                      const SizedBox(height: 16),
                      LoadingData(type: LoadingType.linear, progress: _progress, message: '线性进度: ${(_progress * 100).toInt()}%', size: LoadingSize.medium, color: Colors.orange),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _isLoading ? null : _startProgressDemo, child: Text(_isLoading ? '进度演示中...' : '开始进度演示')),
                    ],
                  ),
                ),
                _buildSection(
                  '6. 自定义样式',
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: LoadingData(
                            message: '自定义文字样式',
                            messageStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: LoadingData(message: '无消息显示', showMessage: false, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildSection(
                  '7. 覆盖层模式',
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('点击按钮查看覆盖层效果'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showOverlay = true;
                          });
                          Future.delayed(const Duration(seconds: 3), () {
                            if (mounted) {
                              setState(() {
                                _showOverlay = false;
                              });
                            }
                          });
                        },
                        child: const Text('显示覆盖层加载'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showOverlay)
            const LoadingData(
              overlay: true,
              message: '正在处理，请稍候...',
              overlayColor: Colors.black54,
              color: Colors.white,
              messageStyle: TextStyle(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
