import 'package:flutter/material.dart';

class NetworkImageShow extends StatelessWidget {
  final String imagePath;
  final String fileModelId;
  const NetworkImageShow(this.imagePath, this.fileModelId, {super.key});
  @override
  Widget build(BuildContext context) {
    // 创建唯一的Key，用于Widget识别
    final imageKey = Key('image_$fileModelId');
    return Image.network(
      imagePath,
      key: imageKey,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: 300, // 限制解码宽度，提升性能
      cacheHeight: 300, // 限制解码高度，提升性能
      // 添加缓存控制，避免重复加载
      headers: const {
        'Cache-Control': 'max-age=3600', // 缓存1小时
      },
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.broken_image, color: Colors.grey.shade400, size: 40);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        final progress = loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null;
        debugPrint('⏳ 网络图片加载中: ${(progress ?? 0) * 100}%');
        return Center(child: CircularProgressIndicator(value: progress));
      },
    );
  }
}
