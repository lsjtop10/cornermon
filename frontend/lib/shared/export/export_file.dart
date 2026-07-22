import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ExportSaveResult { saved, cancelled }

/// 플랫폼 저장 위치 선택기에 넘길 완성된 내보내기 파일이다.
///
/// [name]에는 확장자를 포함하지 않는다. 확장자와 MIME type은 별도 필드로 전달한다.
class ExportFile {
  const ExportFile({
    required this.name,
    required this.bytes,
    required this.fileExtension,
    required this.mimeType,
  });

  factory ExportFile.pdf({required String name, required Uint8List bytes}) =>
      ExportFile(
        name: name,
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );

  factory ExportFile.xlsx({required String name, required Uint8List bytes}) =>
      ExportFile(
        name: name,
        bytes: bytes,
        fileExtension: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );

  final String name;
  final Uint8List bytes;
  final String fileExtension;
  final MimeType mimeType;

  String get filename => '$name.$fileExtension';
}

typedef SaveExportFile = Future<ExportSaveResult> Function(ExportFile file);

/// 네이티브 구현을 Provider 경계로 감싼다. null은 사용자가 파일 선택기를 취소한
/// 정상 흐름이므로 error가 아닌 [ExportSaveResult.cancelled]로 변환한다.
final saveExportFileProvider = Provider<SaveExportFile>((ref) {
  return (file) async {
    final path = await FileSaver.instance.saveAs(
      name: file.name,
      bytes: file.bytes,
      fileExtension: file.fileExtension,
      mimeType: file.mimeType,
    );
    return path == null ? ExportSaveResult.cancelled : ExportSaveResult.saved;
  };
});
