import 'package:flutter/material.dart';
import '../../api/hobby_api.dart';

/// 显示“新增爱好”弹窗
///
/// [initialName] 预填的爱好名称（来自下拉输入框的值）
/// [onCreated] 创建成功后的回调，返回创建的 Hobby 数据
Future<bool?> showAddHobbyDialog(BuildContext context, {String? initialName, void Function(Hobby)? onCreated}) async {
  final TextEditingController nameController = TextEditingController(text: initialName ?? '');
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isSubmitting = false;

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('新增爱好'),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: 360,
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '爱好名称', hintText: '例如：足球、摄影'),
                  textInputAction: TextInputAction.done,
                  maxLength: 50,
                  validator: (val) {
                    final v = val?.trim() ?? '';
                    if (v.isEmpty) return '请输入爱好名称';
                    if (v.length > 50) return '名称长度请不要超过50';
                    return null;
                  },
                  onFieldSubmitted: (_) async {
                    // 回车提交
                    if (!isSubmitting) {
                      await _submitCreate(
                        ctx,
                        context,
                        formKey,
                        nameController,
                        setState,
                        onCreated,
                        (val) => setState(() {
                          isSubmitting = val;
                        }),
                      );
                    }
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        await _submitCreate(
                          ctx,
                          context,
                          formKey,
                          nameController,
                          setState,
                          onCreated,
                          (val) => setState(() {
                            isSubmitting = val;
                          }),
                        );
                      },
                child: isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('创建'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _submitCreate(
  BuildContext dialogStateContext,
  BuildContext scaffoldContext,
  GlobalKey<FormState> formKey,
  TextEditingController nameController,
  void Function(void Function()) setState,
  void Function(Hobby)? onCreated,
  void Function(bool) setSubmitting,
) async {
  if (!(formKey.currentState?.validate() ?? false)) return;
  setSubmitting(true);

  try {
    final name = nameController.text.trim();
    final res = await HobbyApi.createHobby(Hobby(name: name));
    final success = res['success'] == true;
    if (success) {
      final data = res['data'];
      Hobby created;
      if (data is Map<String, dynamic>) {
        created = Hobby.fromJson(data);
      } else {
        created = Hobby(name: name);
      }

      setSubmitting(false);
      Navigator.of(dialogStateContext).pop(true);
      if (onCreated != null) onCreated(created);
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(const SnackBar(content: Text('爱好创建成功')));
    } else {
      final msg = (res['message'] ?? '创建失败').toString();
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(SnackBar(content: Text(msg)));
      setSubmitting(false);
      Navigator.of(dialogStateContext).pop(false);
    }
  } catch (e) {
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(SnackBar(content: Text('创建失败: $e')));
    setSubmitting(false);
    Navigator.of(dialogStateContext).pop(false);
  }
}