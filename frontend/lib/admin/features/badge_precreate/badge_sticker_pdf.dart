import 'dart:typed_data';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// 배지 스티커 시트 PDF를 만든다.
///
/// [pageFormat]은 용지 크기(A4/Letter/커스텀 mm, #249), [qrSizeMm]은 QR 코드 한 변의
/// 길이(mm)다. 라벨 프린터 등 비표준 용지에 맞추기 위해 둘 다 호출부에서 조절한다.
Future<Uint8List> buildBadgeStickerPdf(
  List<api.Badge> badges, {
  PdfPageFormat pageFormat = PdfPageFormat.a4,
  double qrSizeMm = 35,
}) async {
  final qrSize = qrSizeMm * PdfPageFormat.mm;
  final document = pw.Document();
  document.addPage(
    pw.MultiPage(
      pageFormat: pageFormat,
      build: (_) => [
        pw.GridView(
          crossAxisCount: 3,
          childAspectRatio: 1.1,
          children: [
            for (final badge in badges)
              pw.Container(
                margin: const pw.EdgeInsets.all(6),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: badge.qrPayload ?? badge.id ?? '',
                      width: qrSize,
                      height: qrSize,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      badge.shortId ?? badge.id ?? '',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      badge.qrPayload ?? badge.id ?? '',
                      style: pw.TextStyle(fontSize: 7),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    ),
  );
  return document.save();
}
