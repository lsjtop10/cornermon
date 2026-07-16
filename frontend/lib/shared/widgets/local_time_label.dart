import 'package:flutter/material.dart';

/// 절대 시각 표시는 반드시 이 위젯을 거친다 — API의 UTC DateTime을 호출부가
/// 변환 없이 그대로 넘겨도 여기서 toLocal() 후 포맷하므로 누락이 불가능하다.
class LocalTimeLabel extends StatelessWidget {
  const LocalTimeLabel({required this.dateTime, super.key});

  final DateTime dateTime;

  @override
  Widget build(BuildContext context) =>
      Text(TimeOfDay.fromDateTime(dateTime.toLocal()).format(context));
}
