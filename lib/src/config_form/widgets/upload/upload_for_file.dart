import 'package:flutter/material.dart';
import 'package:flutter_simple_ui/models/index.dart';
import 'package:flutter_simple_ui/src/config_form/widgets/index.dart';
import 'package:flutter_simple_ui/src/file_upload/index.dart';

class UploadForFile extends StatefulWidget {
  final FormConfig config;
  final ConfigFormController controller;
  final void Function(Map<String, dynamic>)? onChanged;

  const UploadForFile({super.key, required this.config, required this.controller, this.onChanged});
  @override
  State<UploadForFile> createState() => _UploadForFileState();
}

class _UploadForFileState extends State<UploadForFile> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.config.props as UploadProps;
    final errorsInfo = widget.controller.errors;
    final List<FileUploadModel> files = widget.controller.getValue<List<dynamic>>(widget.config.name)?.whereType<FileUploadModel>().toList() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LabelInfo(widget.config.label, widget.config.required),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 18),
              child: FileUpload(
                key: ValueKey('upload_${widget.config.name}'),
                limit: props.maxFiles ?? -1,
                fileListType: props.fileListType,
                fileSource: props.fileSource,
                autoUpload: props.autoUpload,
                uploadConfig: UploadConfig(uploadUrl: props.uploadUrl, headers: null),
                isRemoveFailFile: props.isRemoveFailFile,
                customUpload: props.customUpload,
                customAreaContent: props.customAreaContent,
                defaultValue: files,
                onFileChange: (current, selected, action) {
                  widget.controller.setFieldValue(widget.config.name, selected);
                  props.onFileChange?.call(current, selected, action);
                  widget.onChanged?.call(widget.controller.getFormData());
                },
                onUploadProgress: (file, progress) {
                  props.onUploadProgress?.call(file, progress);
                },
                onUploadSuccess: (file) {
                  props.onUploadSuccess?.call(file);
                },
                onUploadFailed: (file, error) {
                  props.onUploadFailed?.call(file, error);
                  print('文件上传失败：${file.name}, 错误：$error');
                },
              ),
            ),
            if (errorsInfo[widget.config.name] != null) Positioned(bottom: 0, left: 0, child: ErrorInfo(errorsInfo[widget.config.name]!)),
          ],
        ),
      ],
    );
  }
}
