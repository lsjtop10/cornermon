import 'dart:typed_data';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> buildBadgeStickerPdf(List<api.Badge> badges) async {
  final document = pw.Document();
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
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
                      width: 110,
                      height: 110,
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
