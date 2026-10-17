import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../providers/custom_notification_provider.dart';
import '../../services/custom_notification_service.dart';

/// Full-screen custom notification management (silent push).
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final items = ref.watch(customNotificationProvider);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: Text(
          '🔔 নোটিফিকেশন',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: items.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spaceLg,
                AppConstants.spaceLg,
                AppConstants.spaceLg,
                100,
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppConstants.spaceMd),
              itemBuilder: (_, i) => _NotificationTile(item: items[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.emerald,
        foregroundColor: colors.textOnEmerald,
        icon: const Icon(Icons.add),
        label: const Text('নতুন নোটিফিকেশন'),
        onPressed: () => _showEditor(context, ref, null),
      ),
    );
  }

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref,
    UserNotification? existing,
  ) async {
    final result = await showDialog<UserNotification>(
      context: context,
      builder: (ctx) => _NotificationEditorDialog(existing: existing),
    );
    if (result == null) return;

    if (existing == null) {
      await ref.read(customNotificationProvider.notifier).add(result);
    } else {
      await ref.read(customNotificationProvider.notifier).update(result);
    }
  }
}

// ─────────────────────────────────────────────
// TILE
// ─────────────────────────────────────────────

class _NotificationTile extends ConsumerWidget {
  final UserNotification item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);

    return Dismissible(
      key: ValueKey('notif-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.spaceXl),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
      ),
      onDismissed: (_) {
        ref.read(customNotificationProvider.notifier).delete(item.id);
      },
      child: InkWell(
        onTap: () async {
          final result = await showDialog<UserNotification>(
            context: context,
            builder: (ctx) => _NotificationEditorDialog(existing: item),
          );
          if (result == null) return;
          await ref
              .read(customNotificationProvider.notifier)
              .update(result);
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            border: Border.all(
              color: item.enabled ? colors.borderStrong : colors.border,
              width: item.enabled ? 1.4 : 1.0,
            ),
            boxShadow: colors.cardShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          color: item.enabled
                              ? colors.emerald
                              : colors.textFaint,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.timeLabel,
                          style: TextStyle(
                            color: item.enabled
                                ? colors.emerald
                                : colors.textFaint,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            fontFeatures:
                                const [FontFeature.tabularFigures()],
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.body.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.body,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: AppConstants.fontCaption,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      item.daysLabel,
                      style: TextStyle(
                        color: colors.textFaint,
                        fontSize: AppConstants.fontMicro,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: item.enabled,
                onChanged: (v) => ref
                    .read(customNotificationProvider.notifier)
                    .toggle(item, v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EDITOR DIALOG
// ─────────────────────────────────────────────

class _NotificationEditorDialog extends StatefulWidget {
  final UserNotification? existing;

  const _NotificationEditorDialog({this.existing});

  @override
  State<_NotificationEditorDialog> createState() =>
      _NotificationEditorDialogState();
}

class _NotificationEditorDialogState
    extends State<_NotificationEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late TimeOfDay _time;
  late Set<int> _days;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(
      text: e?.title ?? '📖 কুরআন পড়ার সময়',
    );
    _bodyController = TextEditingController(
      text: e?.body ?? 'আজকের তিলাওয়াতের লক্ষ্য পূরণ করুন। ✨',
    );
    _time = e != null
        ? TimeOfDay(hour: e.hour, minute: e.minute)
        : const TimeOfDay(hour: 20, minute: 0);
    _days = Set.from(e?.daysOfWeek ?? {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final n = UserNotification(
      id: widget.existing?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      body: _bodyController.text.trim(),
      hour: _time.hour,
      minute: _time.minute,
      daysOfWeek: _days,
      enabled: true,
    );
    Navigator.of(context).pop(n);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AlertDialog(
      backgroundColor: colors.cardBackground,
      title: Text(
        widget.existing == null ? 'নতুন নোটিফিকেশন' : 'নোটিফিকেশন সম্পাদনা',
        style: TextStyle(color: colors.textPrimary),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spaceLg,
                ),
                decoration: BoxDecoration(
                  color: colors.emerald.withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  '${_time.hour.toString().padLeft(2, '0')}:'
                  '${_time.minute.toString().padLeft(2, '0')}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.emerald,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            TextField(
              controller: _titleController,
              style: TextStyle(color: colors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'শিরোনাম (যেমন: 📖 কুরআন পড়ার সময়)',
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            TextField(
              controller: _bodyController,
              style: TextStyle(color: colors.textPrimary),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'বার্তা (ঐচ্ছিক)',
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Text(
              'কোন দিনগুলোতে?',
              style: TextStyle(
                color: colors.textMuted,
                fontSize: AppConstants.fontCaption,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(7, (i) {
                final day = i + 1;
                const names = ['সো', 'ম', 'বু', 'বৃ', 'শু', 'শ', 'র'];
                final selected = _days.contains(day);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _days.remove(day);
                      } else {
                        _days.add(day);
                      }
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                          selected ? colors.emerald : colors.surfaceInset,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            selected ? colors.emerald : colors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        names[i],
                        style: TextStyle(
                          color: selected
                              ? colors.textOnEmerald
                              : colors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (_days.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'কোনো দিন সিলেক্ট না করলে প্রতিদিন আসবে',
                  style: TextStyle(
                    color: colors.textFaint,
                    fontSize: AppConstants.fontMicro,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('বাতিল', style: TextStyle(color: colors.textMuted)),
        ),
        TextButton(
          onPressed: _save,
          child: Text('সংরক্ষণ', style: TextStyle(color: colors.emerald)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: colors.emerald.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: colors.emerald,
                size: 44,
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              'কোনো নোটিফিকেশন নেই',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: AppConstants.fontSubtitle,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              'নিচের বাটনে ট্যাপ করে প্রথম নোটিফিকেশন যোগ করুন',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: AppConstants.fontBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
