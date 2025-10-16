import 'package:flutter/cupertino.dart';
import 'package:flutter_simple_ui/models/file_upload.dart';
import 'file_picker_utils.dart';

/// 显示文件来源选择弹窗
showFileSourceDialog(BuildContext context, {Function(FileUploadModel)? onFileSelected}) {
  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: const Text('请选择文件来源', style: TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel)),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              FilePickerUtils.pickFile(onFileSelected: onFileSelected);
            },
            child: const Row(
              children: [
                Icon(CupertinoIcons.folder, color: CupertinoColors.systemBlue),
                SizedBox(width: 12),
                Text('选择文件'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              FilePickerUtils.pickImageFromGallery(onFileSelected: onFileSelected);
            },
            child: const Row(
              children: [
                Icon(CupertinoIcons.photo_on_rectangle, color: CupertinoColors.systemBlue),
                SizedBox(width: 12),
                Text('从相册选择'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              FilePickerUtils.pickImageFromCamera(onFileSelected: onFileSelected);
            },
            child: const Row(
              children: [
                Icon(CupertinoIcons.camera, color: CupertinoColors.systemBlue),
                SizedBox(width: 12),
                Text('拍照上传'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消', style: TextStyle(fontSize: 18)),
        ),
      );
    },
  );
}

/// 显示图片或拍照选择弹窗（苹果风格）
showImageOrCameraDialog(BuildContext context, {Function(FileUploadModel)? onFileSelected}) {
  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: const Text('请选择', style: TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel)),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              FilePickerUtils.pickImageFromGallery(onFileSelected: onFileSelected);
            },
            child: const Row(
              children: [
                Icon(CupertinoIcons.photo_on_rectangle, color: CupertinoColors.systemBlue),
                SizedBox(width: 12),
                Text('从相册选择'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              FilePickerUtils.pickImageFromCamera(onFileSelected: onFileSelected);
            },
            child: const Row(
              children: [
                Icon(CupertinoIcons.camera, color: CupertinoColors.systemBlue),
                SizedBox(width: 12),
                Text('拍照'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消', style: TextStyle(fontSize: 18)),
        ),
      );
    },
  );
}

// 是否显示上传按钮
bool isShowButton(allFiles, fileListType, limit) {
  if (fileListType == FileListType.card) return false;
  if (limit == -1 || allFiles.length < limit) return true;
  return false;
}

// 是否显示上传卡片
bool isShowCard(allFiles, fileListType, limit) {
  if (fileListType != FileListType.card) return false;
  if (limit == -1 || allFiles.length < limit) return true;
  return false;
}

/// 根据fileSource决定交互方式
void handleFileSelection(BuildContext context, FileSource fileSource, onFileSelected) {
  switch (fileSource) {
    case FileSource.file:
      // 只允许选择文件，直接调用文件选择
      FilePickerUtils.pickFile(onFileSelected: onFileSelected);
      break;
    case FileSource.image:
      // 只允许选择图片，直接调用相册选择
      FilePickerUtils.pickImageFromGallery(onFileSelected: onFileSelected);
      break;
    case FileSource.camera:
      // 只允许拍照，直接调用摄像头
      FilePickerUtils.pickImageFromCamera(onFileSelected: onFileSelected);
      break;
    case FileSource.imageOrCamera:
      // 允许选择图片或拍照，显示包含这两个选项的弹窗
      showImageOrCameraDialog(context, onFileSelected: onFileSelected);
      break;
    case FileSource.all:
      // 允许所有类型，显示完整的选择弹窗
      showFileSourceDialog(context, onFileSelected: onFileSelected);
      break;
    default:
      // 网络文件
      break;
  }
}
