import 'package:material_ui/material_ui.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import 'app_button.dart';

enum ConfirmModalKind { hardBlock, softConfirm, singleAckOnly }

IconData _iconFor(ConfirmModalKind kind) => switch (kind) {
  ConfirmModalKind.hardBlock => Icons.error_outline,
  ConfirmModalKind.softConfirm => Icons.warning_amber_rounded,
  ConfirmModalKind.singleAckOnly => Icons.info_outline,
};

Color _iconColorFor(ConfirmModalKind kind, AppColors colors) => switch (kind) {
  ConfirmModalKind.hardBlock => colors.danger,
  ConfirmModalKind.softConfirm => colors.warning,
  ConfirmModalKind.singleAckOnly => colors.info,
};

/// 확인/경고 다이얼로그의 공용 뼈대(배경·모서리·아이콘+제목 행)만 담당한다.
/// [showConfirmModal](단순 확인/취소, body는 문자열 한 줄)이 내부에서 이 셸을 쓰고,
/// 진행 상태·실시간 데이터처럼 자체 상태를 들고 있어야 하는 다이얼로그(캠프 시작/종료
/// 확인 등)는 이 셸을 직접 써서 콘텐츠와 액션을 자유롭게 구성한다 — 그래야 앱 전역의
/// 확인모달이 "직접 만든 AlertDialog"와 "공용 컴포넌트"로 갈라지지 않고 하나로 보인다.
class ConfirmModalShell extends StatelessWidget {
  const ConfirmModalShell({
    required this.kind,
    required this.title,
    required this.actions,
    this.content,
    this.constraints,
    super.key,
  });

  final ConfirmModalKind kind;
  final String title;
  final Widget? content;
  final List<Widget> actions;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    return AlertDialog(
      backgroundColor: colors.bgSurfaceRaised,
      constraints: constraints,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Row(
        children: [
          Icon(_iconFor(kind), color: _iconColorFor(kind, colors), size: 28.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              title,
              style: AppTypography.title3.copyWith(color: colors.textPrimary),
            ),
          ),
        ],
      ),
      content: content,
      actions: actions,
    );
  }
}

Future<bool> showConfirmModal(
  BuildContext context, {
  required ConfirmModalKind kind,
  required String title,
  String? body,
  AppButtonSize buttonSize = AppButtonSize.compact,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible:
        kind != ConfirmModalKind.hardBlock, // 하드 블록은 바깥 탭으로 닫기 불가능
    builder: (BuildContext context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final colors = isDark ? AppColors.dark : AppColors.light;

      List<Widget> actions;
      switch (kind) {
        case ConfirmModalKind.hardBlock:
          actions = [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                '확인',
                style: AppTypography.bodyEmphasis.copyWith(
                  color: colors.brandPrimary,
                ),
              ),
            ),
          ];
          break;
        case ConfirmModalKind.softConfirm:
          actions = [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                '취소',
                style: AppTypography.body.copyWith(color: colors.textSecondary),
              ),
            ),
            AppButton(
              variant: AppButtonVariant.destructive,
              size: buttonSize,
              label: '진행',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ];
          break;
        case ConfirmModalKind.singleAckOnly:
          actions = [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                '확인',
                style: AppTypography.bodyEmphasis.copyWith(
                  color: colors.brandPrimary,
                ),
              ),
            ),
          ];
          break;
      }

      return ConfirmModalShell(
        kind: kind,
        title: title,
        content: body != null
            ? Text(
                body,
                style: AppTypography.body.copyWith(color: colors.textSecondary),
              )
            : null,
        actions: actions,
      );
    },
  );

  return result ?? (kind == ConfirmModalKind.softConfirm ? false : true);
}
