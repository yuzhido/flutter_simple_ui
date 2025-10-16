import 'package:example/utils/compress_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CompressDemoPage extends StatefulWidget {
  const CompressDemoPage({super.key});

  @override
  State<CompressDemoPage> createState() => _CompressDemoPageState();
}

class _CompressDemoPageState extends State<CompressDemoPage> {
  final ImagePicker _picker = ImagePicker();
  File? _originalImage;
  File? _compressedImage;
  CompressResult? _compressResult;
  bool _isCompressing = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

      if (image != null) {
        setState(() {
          _originalImage = File(image.path);
          _compressedImage = null;
          _compressResult = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
    }
  }

  Future<void> _compressImage() async {
    if (_originalImage == null) return;

    setState(() {
      _isCompressing = true;
    });

    try {
      final result = await ImageCompressUtil.compressImage(_originalImage!.path, config: const ImageCompressConfig(quality: 80, maxWidth: 1920, maxHeight: 1920));
      print(result.compressedSize);
      print(result.originalSize);
      setState(() {
        _compressResult = result;
        if (result.success) {
          _compressedImage = File(result.filePath);
        }
        _isCompressing = false;
      });

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('压缩成功！')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('压缩失败: ${result.error}')));
      }
    } catch (e) {
      setState(() {
        _isCompressing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('压缩异常: $e')));
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图片压缩演示')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.photo_library), label: const Text('选择图片')),

            const SizedBox(height: 16),

            if (_originalImage != null) ...[
              const Text('原始图片:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_originalImage!, fit: BoxFit.contain),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _isCompressing ? null : _compressImage,
                icon: _isCompressing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.compress),
                label: Text(_isCompressing ? '压缩中...' : '压缩图片'),
              ),
            ],

            if (_compressResult != null) ...[
              const SizedBox(height: 24),
              const Text('压缩结果:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('原始大小: ${_formatFileSize(_compressResult!.originalSize)}'),
                      Text('压缩后大小: ${_formatFileSize(_compressResult!.compressedSize)}'),
                      Text('压缩比例: ${(_compressResult!.compressionRatio * 100).toStringAsFixed(1)}%'),
                      Text('节省空间: ${_formatFileSize(_compressResult!.originalSize - _compressResult!.compressedSize)}'),
                    ],
                  ),
                ),
              ),
            ],

            if (_compressedImage != null) ...[
              const SizedBox(height: 16),
              const Text('压缩后图片:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_compressedImage!, fit: BoxFit.contain),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
