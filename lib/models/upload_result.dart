import 'dart:typed_data';

enum UploadSource { image, file, camera }

class UploadResult {
  final UploadSource source;
  final String name;
  final String? path;
  final Uint8List? bytes;
  final int? size;
  final String? mimeType;

  const UploadResult({required this.source, required this.name, this.path, this.bytes, this.size, this.mimeType});
}
