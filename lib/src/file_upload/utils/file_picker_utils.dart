import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/file_upload.dart';
import 'package:flutter_simple_ui/src/file_upload/utils/get_file_info.dart';

/// 文件选择工具类
class FilePickerUtils {
  /// 选择文件
  static Future<void> pickFile({Function(FileUploadModel)? onFileSelected}) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(type: FileType.any);

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        if (file.path != null && file.name.isNotEmpty && onFileSelected != null) {
          // 封装成FileUploadModel并调用回调
          FileUploadModel fileUploadModel = createFileUploadModel(
            fileName: file.name,
            filePath: file.path!,
            source: FileSource.file,
            fileSize: file.size,
            fileSizeInfo: formatFileSize(file.size),
          );
          onFileSelected(fileUploadModel);
        }
      } else {
        debugPrint('⚠️ 用户取消了文件选择');
      }
    } catch (e) {
      debugPrint('⚠️ 选择文件时发生错误: $e');
    }
  }

  /// 从相册选择图片
  static Future<void> pickImageFromGallery({Function(FileUploadModel)? onFileSelected}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
      if (image != null) {
        File imageFile = File(image.path);
        int fileSize = await imageFile.length();

        if (onFileSelected != null && image.path.isNotEmpty) {
          // 生成合适的文件名
          String fileName = image.name.isNotEmpty ? image.name : 'gallery_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          // 封装成FileUploadModel并调用回调
          FileUploadModel fileUploadModel = createFileUploadModel(
            fileName: fileName,
            filePath: image.path,
            source: FileSource.image,
            fileSize: fileSize,
            fileSizeInfo: formatFileSize(fileSize),
          );
          onFileSelected(fileUploadModel);
        }
      } else {
        debugPrint('⚠️ 用户取消了图片选择');
      }
    } catch (e) {
      debugPrint('⚠️ 从相册选择图片时发生错误: $e');
    }
  }

  /// 拍照上传
  static Future<void> pickImageFromCamera({Function(FileUploadModel)? onFileSelected}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
      if (image == null) return debugPrint('⚠️ 用户取消了拍照');
      if (onFileSelected == null || image.path.isEmpty) return;
      File imageFile = File(image.path);
      int fileSize = await imageFile.length();

      // 生成合适的文件名
      String fileName = image.name.isNotEmpty ? image.name : 'camera_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 封装成FileUploadModel并调用回调
      FileUploadModel fileUploadModel = createFileUploadModel(
        fileName: fileName,
        filePath: image.path,
        source: FileSource.camera,
        fileSize: fileSize,
        fileSizeInfo: formatFileSize(fileSize),
      );
      onFileSelected(fileUploadModel);
    } catch (e) {
      debugPrint('⚠️ 拍照时发生错误: $e');
    }
  }

  /// 构建卡片模式的文件项
  /// [fileModel] 文件模型
  /// [index] 索引
  /// [width] 宽度
  /// [onRemove] 移除回调
  static Widget buildCardFileItem(FileUploadModel fileModel, int index, double width, Function(int) onRemove) {
    final isImage = isImageFile(fileModel.name);

    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          // 文件内容
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 文件预览或图标
                if (isImage)
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(4), child: buildImagePreview(fileModel)),
                        // 上传中的遮罩层
                        if (fileModel.status == UploadStatus.uploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4)),
                              child: Center(
                                child: CircularProgressIndicator(value: fileModel.progress, color: Colors.white, strokeWidth: 3),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  Stack(
                    children: [
                      Icon(Icons.insert_drive_file, color: Colors.blue.shade600, size: 40),
                      // 上传中的进度指示器
                      if (fileModel.status == UploadStatus.uploading)
                        Positioned.fill(
                          child: Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(value: fileModel.progress, color: Colors.blue.shade600, strokeWidth: 3),
                            ),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 4),
                // 文件名
                Text(
                  fileModel.name.length > 10 ? '${fileModel.name.substring(0, 10)}...' : fileModel.name,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 10, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // 文件大小
                if (fileModel.fileSizeInfo != null)
                  Text(
                    fileModel.fileSizeInfo!,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          // 状态指示器
          Positioned(top: 4, left: 4, child: buildStatusIndicator(fileModel.status, fileModel.progress)),
          // 删除按钮
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => onRemove(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: Colors.red.shade400, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建文本信息模式的文件项
  static Widget buildTextInfoFileItem(FileUploadModel fileModel, int index, Function(int) onRemove) {
    final isImage = isImageFile(fileModel.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // 文件图标或小预览图
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
            child: Stack(
              children: [
                if (isImage)
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: buildImagePreview(fileModel))
                else
                  Icon(Icons.insert_drive_file, color: Colors.blue.shade600, size: 24),
                // 上传中的进度指示器
                if (fileModel.status == UploadStatus.uploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4)),
                      child: Center(
                        child: CircularProgressIndicator(value: fileModel.progress, color: Colors.white, strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 文件信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileModel.name,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // 状态指示器
                    buildStatusIndicator(fileModel.status, fileModel.progress),
                    const SizedBox(width: 8),
                    if (fileModel.fileSizeInfo != null) Text(fileModel.fileSizeInfo!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
                // 上传进度条（线性）
                if (fileModel.status == UploadStatus.uploading)
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: fileModel.progress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                        minHeight: 3,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('上传中...', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                          Text('${((fileModel.progress) * 100).toInt()}%', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // 删除按钮
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
            onPressed: () => onRemove(index),
          ),
        ],
      ),
    );
  }
}
