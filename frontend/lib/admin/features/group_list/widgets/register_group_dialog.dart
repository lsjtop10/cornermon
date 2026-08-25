import 'dart:async';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/api/providers/badge_providers.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/qr_scan_frame.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class RegisterGroupDialog extends ConsumerStatefulWidget {
  const RegisterGroupDialog({required this.campId, super.key});
  final CampId campId;
  @override
  ConsumerState<RegisterGroupDialog> createState() =>
      _RegisterGroupDialogState();
}

class _RegisterGroupDialogState extends ConsumerState<RegisterGroupDialog> {
  final _name = TextEditingController();
  final _payload = TextEditingController();
  final MobileScannerController _scannerController =
      MobileScannerController();
  int _tab = 0;
  bool _busy = false;
  bool _scanned = false;
  @override
  void dispose() {
    _name.dispose();
    _payload.dispose();
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  // 카메라 프리뷰(MobileScanner) 위젯을 트리에서 통째로 스왑하면, 아직 처리 중인 네이티브
  // 프레임 콜백이 이미 dispose된 카메라를 참조해 "Attempt to invoke virtual method ...
  // on a null object reference"로 프로덕션에서 죽었다(mobile_scanner Android 플랫폼 뷰
  // 언마운트 레이스). 위젯은 계속 마운트해 두고 controller.stop()으로만 카메라를 멈춘다
  // — 진행자 QrScanScreen과 동일한 패턴(qr_scan_screen.dart 참고).
  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final token = capture.barcodes.firstOrNull?.rawValue;
    if (token == null) return;
    unawaited(_scannerController.stop());
    setState(() {
      _payload.text = token;
      _scanned = true;
    });
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _payload.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(
        scanRegisterBadgeProvider(
          widget.campId.value,
          _payload.text.trim(),
          _name.text.trim(),
        ).future,
      );
      ref.invalidate(groupListProvider(widget.campId));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 등록된 배지이거나 등록할 수 없습니다')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final badges = ref.watch(badgeListProvider);
    return AlertDialog(
      title: const Text('조 등록'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('카메라 QR')),
                ButtonSegment(value: 1, label: Text('목록에서 선택')),
                ButtonSegment(value: 2, label: Text('직접 입력')),
              ],
              selected: {_tab},
              onSelectionChanged: (value) =>
                  setState(() => _tab = value.single),
            ),
            const SizedBox(height: AppSpacing.space3),
            if (_tab == 0)
              SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      ColoredBox(
                        color: Colors.black,
                        child: MobileScanner(
                          controller: _scannerController,
                          onDetect: _onDetect,
                          errorBuilder: (context, error) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppSpacing.space4,
                              ),
                              child: Text(
                                '카메라를 사용할 수 없습니다. 카메라 권한을 확인해주세요.',
                                textAlign: TextAlign.center,
                                style: AppTypography.body.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: QrScanFrame(
                          state: _scanned
                              ? QrScanFrameState.success
                              : QrScanFrameState.scanning,
                          size: 160,
                        ),
                      ),
                      if (_scanned)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            'QR 인식 완료: ${_payload.text}',
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else if (_tab == 1)
              SizedBox(
                height: 180,
                child: badges.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const Text('배지를 불러오지 못했습니다'),
                  data: (items) => ListView(
                    children: [
                      for (final badge in items.where(
                        (item) => item.status == api.BadgeStatus.UNASSIGNED,
                      ))
                        ListTile(
                          title: Text(badge.shortId ?? badge.id ?? '-'),
                          selected: _payload.text == badge.qrPayload,
                          onTap: () => setState(
                            () => _payload.text = badge.qrPayload ?? '',
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else
              TextField(
                controller: _payload,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: '배지 ID',
                  hintText: 'QR 코드 아래 인쇄된 ID를 입력하세요',
                ),
              ),
            if (_payload.text.isNotEmpty)
              TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: '조 이름'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        AppButton(
          variant: AppButtonVariant.primary,
          size: AppButtonSize.compact,
          label: '등록 확정',
          onPressed:
              _busy || _payload.text.trim().isEmpty || _name.text.trim().isEmpty
              ? null
              : _submit,
        ),
      ],
    );
  }
}
