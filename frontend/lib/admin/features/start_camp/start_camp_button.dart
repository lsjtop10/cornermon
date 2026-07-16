import 'package:cornermon/admin/features/start_camp/start_camp_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartCampButton extends ConsumerStatefulWidget {
  const StartCampButton({super.key});
  @override
  ConsumerState<StartCampButton> createState() => _StartCampButtonState();
}

class _StartCampButtonState extends ConsumerState<StartCampButton> {
  bool _submitting = false;
  String? _error;
  Future<void> _confirm(BuildContext dialogContext) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(startCampControllerProvider.notifier).confirm();
      final result = ref.read(startCampControllerProvider);
      if (result.hasError) throw result.error!;
      if (dialogContext.mounted) Navigator.pop(dialogContext);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: _submitting
        ? null
        : () => showDialog<void>(
            context: context,
            builder: (dialogContext) => StatefulBuilder(
              builder: (_, _) => AlertDialog(
                title: const Text('코너학습을 시작할까요?'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PIN 카드는 이미 발급돼 있으니 시작 전까지는 로그인이 거부됩니다'),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text('취소'),
                  ),
                  FilledButton(
                    onPressed: _submitting
                        ? null
                        : () => _confirm(dialogContext),
                    child: _submitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('시작 확정'),
                  ),
                ],
              ),
            ),
          ),
    icon: const Icon(Icons.play_arrow),
    label: const Text('코너학습 시작'),
  );
}
