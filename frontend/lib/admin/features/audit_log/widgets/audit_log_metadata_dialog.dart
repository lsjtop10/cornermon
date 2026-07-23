import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:flutter/material.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';

/// A13 감사 로그 상세 정보 팝업 — 행을 탭하면 metadata를 key-value로 보여준다.
class AuditLogMetadataDialog extends StatelessWidget {
  const AuditLogMetadataDialog({required this.metadata, super.key});

  final BuiltMap<String, JsonObject?>? metadata;

  static Future<void> show(BuildContext context, AuditLog log) => showDialog<void>(
    context: context,
    builder: (context) => AuditLogMetadataDialog(metadata: log.metadata),
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final entries = metadata?.entries.toList() ?? const [];

    return AlertDialog(
      backgroundColor: colors.bgSurfaceRaised,
      constraints: const BoxConstraints(minWidth: 400, maxWidth: 560),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        '상세 정보',
        style: AppTypography.title3.copyWith(color: colors.textPrimary),
      ),
      content: entries.isEmpty
          ? Text(
              '추가 정보 없음',
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in entries)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.space2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: AppTypography.label.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          Text(
                            _describeValue(entry.value),
                            style: AppTypography.body.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}

String _describeValue(JsonObject? value) {
  if (value == null) return '-';
  if (value.isMap || value.isList) {
    return const JsonEncoder.withIndent('  ').convert(value.value);
  }
  return value.toString();
}
