import 'dart:io';
import 'package:flutter/material.dart';

class FileImageShow extends StatelessWidget {
  final String imagePath;
  final String fileModelId;
  const FileImageShow(this.imagePath, this.fileModelId, {super.key});
  @override
  Widget build(BuildContext context) {
    // 创建唯一的Key，用于Widget识别
    final imageKey = Key('image_$fileModelId');

    return Image.file(
      File(imagePath),
      key: imageKey,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: 300, // 限制解码宽度，大幅提升大图片预览性能
      cacheHeight: 300, // 限制解码高度，减少内存占用
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.broken_image, color: Colors.grey.shade400, size: 40);
      },
    );
  }
}
