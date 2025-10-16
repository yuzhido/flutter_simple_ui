import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter_simple_ui/models/file_upload.dart';

/// 文件上传工具类
class FileUploadUtils {
  /// 真实的HTTP上传方法
  static Future<FileUploadResult> realUpload({
    required FileUploadModel fileModel,
    UploadConfig? uploadConfig,
    Future<FileUploadModel?> Function(String filePath, Function(double) onProgress)? customUpload,
    required Function(UploadStatus status, {double? progress}) onStatusUpdate,
    required Function(String error) onError,
    required Function(FileUploadModel updatedModel) onSuccess,
  }) async {
    // 检查是否有自定义上传函数
    if (customUpload != null) {
      return await _customUpload(fileModel: fileModel, customUpload: customUpload, onStatusUpdate: onStatusUpdate, onError: onError, onSuccess: onSuccess);
    }

    // 检查标准上传配置
    if (uploadConfig == null || !uploadConfig.isValid) {
      final error = '上传配置无效：缺少上传URL或自定义上传函数';
      onError(error);
      return FileUploadResult.error(error);
    }

    try {
      // 创建Dio实例
      final dio = Dio();

      // 设置超时时间
      dio.options.connectTimeout = Duration(seconds: uploadConfig.timeout);
      dio.options.receiveTimeout = Duration(seconds: uploadConfig.timeout);
      dio.options.sendTimeout = Duration(seconds: uploadConfig.timeout);

      // 设置请求头
      if (uploadConfig.headers != null) {
        dio.options.headers.addAll(uploadConfig.headers!);
      }

      // 获取文件路径
      final filePath = fileModel.path;
      if (filePath.isEmpty) {
        const error = '文件路径无效';
        onError(error);
        return FileUploadResult.error(error);
      }

      // 创建文件对象
      final file = File(filePath);
      if (!await file.exists()) {
        const error = '文件不存在';
        onError(error);
        return FileUploadResult.error(error);
      }

      // 准备表单数据
      final formData = FormData();

      // 添加文件
      formData.files.add(MapEntry(uploadConfig.fileFieldName, await MultipartFile.fromFile(filePath, filename: fileModel.name)));

      // 添加额外的表单数据
      if (uploadConfig.extraData != null) {
        uploadConfig.extraData!.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      // 发送请求
      final response = await dio.request(
        uploadConfig.uploadUrl!,
        data: formData,
        options: Options(method: uploadConfig.method),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            onStatusUpdate(UploadStatus.uploading, progress: progress);
          }
        },
      );

      // 检查响应状态
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 尝试解析服务器返回的数据并更新FileUploadModel
        FileUploadModel? updatedModel;
        try {
          if (response.data is Map<String, dynamic>) {
            // 创建更新后的FileUploadModel，保留原有数据并更新服务器返回的信息
            final responseData = response.data as Map<String, dynamic>;

            // 更新FileInfo信息，如果fileInfo为null则创建新的
            final updatedFileInfo =
                fileModel.fileInfo?.copyWith(
                  // 如果服务器返回了新的ID，使用服务器的ID
                  id: responseData['id']?.toString(),
                  // 如果服务器返回了文件URL，更新requestPath
                  requestPath:
                      responseData['requestPath']?.toString() ?? responseData['url']?.toString() ?? responseData['path']?.toString() ?? responseData['file_url']?.toString(),
                  // 如果服务器返回了文件名，更新fileName
                  fileName: responseData['filename']?.toString() ?? responseData['fileName']?.toString() ?? responseData['file_name']?.toString(),
                ) ??
                FileInfo(
                  id: responseData['id']?.toString() ?? '',
                  fileName: responseData['filename']?.toString() ?? responseData['fileName']?.toString() ?? responseData['file_name']?.toString() ?? fileModel.name,
                  requestPath:
                      responseData['requestPath']?.toString() ?? responseData['url']?.toString() ?? responseData['path']?.toString() ?? responseData['file_url']?.toString() ?? '',
                );

            // 创建更新后的FileUploadModel，保持原有的id
            updatedModel = fileModel.copyWith(
              id: fileModel.id, // 保持原有的FileUploadModel的id
              fileInfo: updatedFileInfo,
              status: UploadStatus.success,
              progress: 1.0,
            );
          }
        } catch (e) {
          // 如果解析失败，使用原始模型但更新状态
          updatedModel = fileModel.copyWith(status: UploadStatus.success, progress: 1.0);
        }

        final finalModel = updatedModel ?? fileModel.copyWith(status: UploadStatus.success, progress: 1.0);
        onSuccess(finalModel);
        return FileUploadResult.success(finalModel);
      } else {
        final error = '上传失败：HTTP ${response.statusCode}';
        onError(error);
        return FileUploadResult.error(error);
      }
    } on DioException catch (e) {
      // Dio异常处理
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = '连接超时';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = '发送超时';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = '接收超时';
          break;
        case DioExceptionType.badResponse:
          errorMessage = '服务器错误: ${e.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          errorMessage = '请求已取消';
          break;
        case DioExceptionType.connectionError:
          errorMessage = '网络连接错误';
          break;
        default:
          errorMessage = '上传异常: ${e.message}';
      }
      onError(errorMessage);
      return FileUploadResult.error(errorMessage);
    } catch (e) {
      // 其他异常
      final errorMessage = '上传异常: $e';
      onError(errorMessage);
      return FileUploadResult.error(errorMessage);
    }
  }

  /// 自定义上传方法
  static Future<FileUploadResult> _customUpload({
    required FileUploadModel fileModel,
    required Future<FileUploadModel?> Function(String filePath, Function(double) onProgress) customUpload,
    required Function(UploadStatus status, {double? progress}) onStatusUpdate,
    required Function(String error) onError,
    required Function(FileUploadModel updatedModel) onSuccess,
  }) async {
    try {
      onStatusUpdate(UploadStatus.uploading, progress: 0.0);

      final filePath = fileModel.path;
      if (filePath.isEmpty) {
        const error = '文件路径无效';
        onError(error);
        return FileUploadResult.error(error);
      }

      final result = await customUpload(filePath, (progress) {
        onStatusUpdate(UploadStatus.uploading, progress: progress);
      });
      onStatusUpdate(UploadStatus.uploading, progress: 1.0);
      // 处理自定义上传返回的结果
      FileUploadModel updatedModel;
      if (result != null) {
        // 自定义上传成功，使用返回的FileUploadModel，但保持原有的id
        updatedModel = result.copyWith(
          id: fileModel.id, // 保持原有的FileUploadModel的id
          status: UploadStatus.success,
          progress: 1.0,
          url: result.url ?? '',
        );
      } else {
        // 自定义上传失败，返回null
        onError('自定义上传失败');
        updatedModel = fileModel.copyWith(status: UploadStatus.failed, progress: 0.0);
      }
      onSuccess(updatedModel);
      return FileUploadResult.success(updatedModel);
    } catch (e) {
      final errorMessage = '自定义上传异常: $e';
      onError(errorMessage);
      return FileUploadResult.error(errorMessage);
    }
  }
}

/// 文件上传结果类
class FileUploadResult {
  final bool isSuccess;
  final String? error;
  final dynamic data;

  FileUploadResult._({required this.isSuccess, this.error, this.data});

  factory FileUploadResult.success(dynamic data) {
    return FileUploadResult._(isSuccess: true, data: data);
  }

  factory FileUploadResult.error(String error) {
    return FileUploadResult._(isSuccess: false, error: error);
  }
}
