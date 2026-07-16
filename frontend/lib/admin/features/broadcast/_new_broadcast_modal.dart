import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';

class NewBroadcastModal extends ConsumerStatefulWidget {
  const NewBroadcastModal({required this.campId, super.key});

  final CampId campId;

  @override
  ConsumerState<NewBroadcastModal> createState() => _NewBroadcastModalState();
}

class _NewBroadcastModalState extends ConsumerState<NewBroadcastModal> {
  final _content = TextEditingController();
  bool _busy = false;
  String? _errorText;

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _content.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _busy = true;
      _errorText = null;
    });
    try {
      await ref.read(
        sendBroadcastMessageProvider(widget.campId, text).future,
      );
      ref.invalidate(broadcastMessageListProvider(widget.campId));
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _errorText = '공지 발송에 실패했습니다');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 공지 작성'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _content,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: '공지 내용'),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _busy || _content.text.trim().isEmpty ? null : _submit,
          child: const Text('발송'),
        ),
      ],
    );
  }
}
