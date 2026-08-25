import 'package:pdf/pdf.dart';

/// 배지 스티커를 내보낼 형식.
enum BadgeExportFormat {
  /// 여러 배지를 한 용지에 격자로 배치한 PDF.
  pdfSheet,

  /// 배지 1장당 QR 코드 1개짜리 PNG.
  images,
}

/// PDF 용지 크기 프리셋. [PaperSizePreset.custom]이면 [PaperSize.customWidthMm]/
/// [PaperSize.customHeightMm]로 라벨 프린터 등 임의 크기를 지정한다.
enum PaperSizePreset { a4, letter, custom }

class PaperSize {
  const PaperSize.preset(this.preset)
    : customWidthMm = null,
      customHeightMm = null;

  const PaperSize.custom({
    required double widthMm,
    required double heightMm,
  }) : preset = PaperSizePreset.custom,
       customWidthMm = widthMm,
       customHeightMm = heightMm;

  final PaperSizePreset preset;
  final double? customWidthMm;
  final double? customHeightMm;

  PdfPageFormat toPdfPageFormat() => switch (preset) {
    PaperSizePreset.a4 => PdfPageFormat.a4,
    PaperSizePreset.letter => PdfPageFormat.letter,
    PaperSizePreset.custom => PdfPageFormat(
      customWidthMm! * PdfPageFormat.mm,
      customHeightMm! * PdfPageFormat.mm,
    ),
  };
}

/// PDF 시트에서 QR 코드 한 변의 길이(mm) 프리셋.
enum QrSizeMmPreset { small, medium, large }

const qrSizeMmPresetValues = {
  QrSizeMmPreset.small: 25.0,
  QrSizeMmPreset.medium: 35.0,
  QrSizeMmPreset.large: 45.0,
};

/// 개별 이미지로 내보낼 때 QR 코드 한 변의 해상도(px) 프리셋.
enum QrResolutionPreset { small, medium, large }

const qrResolutionPresetValues = {
  QrResolutionPreset.small: 256,
  QrResolutionPreset.medium: 512,
  QrResolutionPreset.large: 1024,
};

/// 배지 내보내기 화면에서 고른 형식/용지/QR 크기를 한데 묶어 컨트롤러에 넘긴다.
class BadgeExportSettings {
  const BadgeExportSettings({
    this.format = BadgeExportFormat.pdfSheet,
    this.paperSize = const PaperSize.preset(PaperSizePreset.a4),
    this.qrSizeMm = 35,
    this.qrResolutionPx = 512,
  });

  final BadgeExportFormat format;
  final PaperSize paperSize;
  final double qrSizeMm;
  final int qrResolutionPx;
}
