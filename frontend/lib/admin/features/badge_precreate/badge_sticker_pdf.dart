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
  final cellWidth = qrSize + _cellPadding;
  final cellHeight = qrSize + _cellPadding + _textBlockHeight;
  final crossAxisCount = gridColumnsFor(pageFormat, qrSize);
  final document = pw.Document();
  document.addPage(
    pw.MultiPage(
      pageFormat: pageFormat,
      build: (_) => [
        pw.GridView(
          crossAxisCount: crossAxisCount,
          childAspectRatio: cellWidth / cellHeight,
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

// 셀 하나가 감싸는 여백(마진 6*2 + 패딩 8*2).
const _cellPadding = (6 + 8) * 2;
// 셀 안 QR 아래 텍스트 2줄(shortId 12pt, qrPayload 7pt) + 사이 여백 높이.
const _textBlockHeight = 8 + 12 + 2 + 7;

/// [pageFormat] 인쇄 가능 폭에 [qrSize](pt)짜리 QR 셀이 몇 열 들어가는지 계산한다.
/// QR을 줄였는데 열 개수가 그대로면 셀이 헐렁해 보이는 문제(#249 리뷰)를 막기
/// 위해 crossAxisCount를 고정값이 아니라 QR 크기에서 역산한다.
int gridColumnsFor(PdfPageFormat pageFormat, double qrSize) =>
    (pageFormat.availableWidth / (qrSize + _cellPadding)).floor().clamp(
      1,
      20,
    );
