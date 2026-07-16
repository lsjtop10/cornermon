import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> buildTrackPinPdf({
  required String trackNo,
  required String pin,
}) async {
  final document = pw.Document();
  document.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a6,
      build: (_) => pw.Center(
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text('Cornermon Track PIN', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 16),
            pw.Text('Track $trackNo', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 12),
            pw.Text(pin, style: pw.TextStyle(fontSize: 34)),
          ],
        ),
      ),
    ),
  );
  return document.save();
}
