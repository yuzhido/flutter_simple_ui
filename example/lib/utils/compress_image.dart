import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 图片压缩配置类
class ImageCompressConfig {
  /// 压缩质量 (0-100)
  final int quality;

  /// 最大宽度
  final int? maxWidth;

  /// 最大高度
  final int? maxHeight;

  /// 压缩格式
  final CompressFormat format;

  /// 是否保持宽高比
  final bool keepAspectRatio;

  /// 最大文件大小（字节）
  final int? maxFileSize;

  const ImageCompressConfig({this.quality = 85, this.maxWidth, this.maxHeight, this.format = CompressFormat.jpeg, this.keepAspectRatio = true, this.maxFileSize});
}

/// 压缩结果类
class CompressResult {
  /// 压缩后的文件路径
  final String filePath;

  /// 原始文件大小（字节）
  final int originalSize;

  /// 压缩后文件大小（字节）
  final int compressedSize;

  /// 压缩比例
  final double compressionRatio;

  /// 是否压缩成功
  final bool success;

  /// 错误信息
  final String? error;

  CompressResult({required this.filePath, required this.originalSize, required this.compressedSize, required this.compressionRatio, required this.success, this.error});
}

/// 图片压缩工具类
class ImageCompressUtil {
  /// 压缩图片文件
  static Future<CompressResult> compressImage(String imagePath, {ImageCompressConfig? config}) async {
    try {
      final originalFile = File(imagePath);
      if (!await originalFile.exists()) {
        return CompressResult(filePath: imagePath, originalSize: 0, compressedSize: 0, compressionRatio: 0, success: false, error: '文件不存在');
      }

      final originalSize = await originalFile.length();
      final compressConfig = config ?? const ImageCompressConfig();

      // 生成压缩后的文件路径
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imagePath);
      final extension = _getExtensionByFormat(compressConfig.format);
      final compressedPath = path.join(tempDir.path, '${fileName}_compressed_${DateTime.now().millisecondsSinceEpoch}.$extension');

      // 执行压缩
      final compressedFile = await _performCompression(imagePath, compressedPath, compressConfig);

      if (compressedFile == null) {
        return CompressResult(filePath: imagePath, originalSize: originalSize, compressedSize: 0, compressionRatio: 0, success: false, error: '压缩失败');
      }

      final compressedSize = await compressedFile.length();
      final compressionRatio = (originalSize - compressedSize) / originalSize;

      // 如果设置了最大文件大小限制，检查是否满足要求
      if (compressConfig.maxFileSize != null && compressedSize > compressConfig.maxFileSize!) {
        // 尝试进一步压缩
        final furtherCompressed = await _compressToTargetSize(compressedPath, compressConfig.maxFileSize!, compressConfig);
        if (furtherCompressed != null) {
          final finalSize = await furtherCompressed.length();
          final finalRatio = (originalSize - finalSize) / originalSize;
          return CompressResult(filePath: furtherCompressed.path, originalSize: originalSize, compressedSize: finalSize, compressionRatio: finalRatio, success: true);
        }
      }

      return CompressResult(filePath: compressedFile.path, originalSize: originalSize, compressedSize: compressedSize, compressionRatio: compressionRatio, success: true);
    } catch (e) {
      return CompressResult(filePath: imagePath, originalSize: 0, compressedSize: 0, compressionRatio: 0, success: false, error: e.toString());
    }
  }

  /// 执行图片压缩
  static Future<File?> _performCompression(String sourcePath, String targetPath, ImageCompressConfig config) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        quality: config.quality,
        minWidth: config.maxWidth ?? 0,
        minHeight: config.maxHeight ?? 0,
        format: config.format,
        keepExif: false,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      print('压缩失败: $e');
      return null;
    }
  }

  /// 压缩到目标文件大小
  static Future<File?> _compressToTargetSize(String imagePath, int targetSize, ImageCompressConfig config) async {
    int quality = config.quality;
    File? result;

    // 逐步降低质量直到满足大小要求
    while (quality > 10) {
      quality -= 10;

      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imagePath);
      final extension = _getExtensionByFormat(config.format);
      final tempPath = path.join(tempDir.path, '${fileName}_temp_${quality}_${DateTime.now().millisecondsSinceEpoch}.$extension');

      result = await _performCompression(
        imagePath,
        tempPath,
        ImageCompressConfig(quality: quality, maxWidth: config.maxWidth, maxHeight: config.maxHeight, format: config.format, keepAspectRatio: config.keepAspectRatio),
      );

      if (result != null) {
        final size = await result.length();
        if (size <= targetSize) {
          break;
        }
      }
    }

    return result;
  }

  /// 根据压缩格式获取文件扩展名
  static String _getExtensionByFormat(CompressFormat format) {
    switch (format) {
      case CompressFormat.jpeg:
        return 'jpg';
      case CompressFormat.png:
        return 'png';
      case CompressFormat.webp:
        return 'webp';
      case CompressFormat.heic:
        return 'heic';
    }
  }

  /// 批量压缩图片
  static Future<List<CompressResult>> compressImages(List<String> imagePaths, {ImageCompressConfig? config, Function(int current, int total)? onProgress}) async {
    final results = <CompressResult>[];

    for (int i = 0; i < imagePaths.length; i++) {
      onProgress?.call(i + 1, imagePaths.length);

      final result = await compressImage(imagePaths[i], config: config);

      results.add(result);
    }

    return results;
  }

  /// 获取图片信息
  static Future<Map<String, dynamic>?> getImageInfo(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      return {'width': image.width, 'height': image.height, 'fileSize': await file.length(), 'format': path.extension(imagePath).toLowerCase()};
    } catch (e) {
      print('获取图片信息失败: $e');
      return null;
    }
  }

  /// 预设的压缩配置
  static const ImageCompressConfig lowQuality = ImageCompressConfig(quality: 60, maxWidth: 1024, maxHeight: 1024);

  static const ImageCompressConfig mediumQuality = ImageCompressConfig(quality: 80, maxWidth: 1920, maxHeight: 1920);

  static const ImageCompressConfig highQuality = ImageCompressConfig(quality: 90, maxWidth: 2048, maxHeight: 2048);

  /// 智能压缩配置（根据文件大小自动选择）
  static ImageCompressConfig smartConfig(int fileSizeBytes) {
    if (fileSizeBytes > 5 * 1024 * 1024) {
      // > 5MB
      return lowQuality;
    } else if (fileSizeBytes > 2 * 1024 * 1024) {
      // > 2MB
      return mediumQuality;
    } else {
      return highQuality;
    }
  }
}
