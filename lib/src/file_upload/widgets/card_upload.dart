import 'package:flutter/material.dart';

class CardUpload extends StatefulWidget {
  final double width;
  final Widget? uploadIcon;
  final Widget? uploadText;
  const CardUpload({super.key, required this.width, this.uploadIcon, this.uploadText});
  @override
  State<CardUpload> createState() => _CardUploadState();
}

class _CardUploadState extends State<CardUpload> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      width: widget.width,
      height: widget.width,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 上传文件图标
          widget.uploadIcon ?? const Icon(Icons.camera_enhance_outlined),
          // 上传标题
          const SizedBox(height: 4),
          widget.uploadText ?? const Text('拍照上传', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
