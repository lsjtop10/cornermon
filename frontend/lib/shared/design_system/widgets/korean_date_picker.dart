import 'package:flutter/material.dart';

/// 날짜를 고르는 즉시 닫히는 캘린더 다이얼로그 — 확인/취소 버튼을 두지 않는다.
Future<DateTime?> showKoreanDatePicker({
  required BuildContext context,
  required DateTime? initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 328,
        height: 460,
        child: CalendarDatePicker(
          initialDate: initialDate ?? DateTime.now(),
          firstDate: firstDate,
          lastDate: lastDate,
          onDateChanged: (date) => Navigator.of(dialogContext).pop(date),
        ),
      ),
    ),
  );
}
