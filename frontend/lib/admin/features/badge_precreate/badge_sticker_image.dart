import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:barcode/barcode.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:image/image.dart' as img;

/// 배지 1장의 QR 코드를 [resolutionPx] x [resolutionPx] 크기 PNG로 그린다.
///
/// `printing`의 `Printing.raster`(PDF 래스터화)는 플랫폼 채널이 필요해 유닛
/// 테스트에서 쓸 수 없다. 대신 `pdf`가 이미 의존하는 `barcode` 패키지의
/// [Barcode.make]가 내놓는 사각형(모듈) 목록을 `image` 패키지 캔버스에 직접 채워
/// 순수 Dart로 PNG를 만든다 — 두 패키지 모두 기존 전이 의존성이라 새 패키지 추가가
/// 필요 없다.
Uint8List buildBadgeQrImage(api.Badge badge, {int resolutionPx = 512}) {
  final data = badge.qrPayload ?? badge.id ?? '';
  final size = resolutionPx.toDouble();
  final canvas = img.Image(width: resolutionPx, height: resolutionPx);
  img.fill(canvas, color: img.ColorRgb8(255, 255, 255));
  for (final element in Barcode.qrCode().make(data, width: size, height: size)) {
    if (element is! BarcodeBar || !element.black) continue;
    img.fillRect(
      canvas,
      x1: element.left.floor(),
      y1: element.top.floor(),
      x2: element.right.ceil() - 1,
      y2: element.bottom.ceil() - 1,
      color: img.ColorRgb8(0, 0, 0),
    );
  }
  return img.encodePng(canvas);
}

List<Uint8List> buildBadgeQrImages(
  List<api.Badge> badges, {
  int resolutionPx = 512,
}) => [
  for (final badge in badges)
    buildBadgeQrImage(badge, resolutionPx: resolutionPx),
];

/// 배지별 PNG 여러 장을 `배지ID.png` 이름으로 zip 하나에 묶는다.
///
/// `file_saver`는 파일 하나만 저장할 수 있어(#249), 기기 저장 시 여러 이미지를
/// 한 번에 내보내려면 압축이 필요하다.
Uint8List buildBadgeQrImagesZip(List<api.Badge> badges, List<Uint8List> images) {
  final archive = Archive();
  for (var i = 0; i < badges.length; i++) {
    final name = badges[i].shortId ?? badges[i].id ?? 'badge-$i';
    archive.addFile(ArchiveFile('$name.png', images[i].length, images[i]));
  }
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}
