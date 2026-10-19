import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/alarm_provider.dart';
import '../../services/alarm_service.dart';

/// Full-screen manual alarm management.
class AlarmScreen extends ConsumerWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final alarms = ref.watch(alarmProvider);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: Text(
          l10n.alarms,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: alarms.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spaceLg,
                AppConstants.spaceLg,
                AppConstants.spaceLg,
                100,
              ),
              itemCount: alarms.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppConstants.spaceMd),
              itemBuilder: (_, i) => _AlarmTile(alarm: alarms[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.emerald,
        foregroundColor: colors.textOnEmerald,
        icon: const Icon(Icons.add),
        label: Text(l10n.newAlarm),
        onPressed: () => _showEditor(context, ref, null),
      ),
    );
  }

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref,
    UserAlarm? existing,
  ) async {
    final result = await showDialog<UserAlarm>(
      context: context,
      builder: (ctx) => _AlarmEditorDialog(existing: existing),
    );
    if (result == null) return;

    if (existing == null) {
      await ref.read(alarmProvider.notifier).add(result);
    } else {
      await ref.read(alarmProvider.notifier).update(result);
    }
  }
}

// ─────────────────────────────────────────────
// ALARM TILE
// ─────────────────────────────────────────────

class _AlarmTile extends ConsumerWidget {
  final UserAlarm alarm;

  const _AlarmTile({required this.alarm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);

    return Dismissible(
      key: ValueKey('alarm-${alarm.id}'),
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
        ref.read(alarmProvider.notifier).delete(alarm.id);
      },
      child: InkWell(
        onTap: () async {
          final result = await showDialog<UserAlarm>(
            context: context,
            builder: (ctx) => _AlarmEditorDialog(existing: alarm),
          );
          if (result == null) return;
          await ref.read(alarmProvider.notifier).update(result);
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            border: Border.all(
              color: alarm.enabled ? colors.borderStrong : colors.border,
              width: alarm.enabled ? 1.4 : 1.0,
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
                          Icons.alarm_rounded,
                          color: alarm.enabled
                              ? colors.emerald
                              : colors.textFaint,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          alarm.timeLabel,
                          style: TextStyle(
                            color: alarm.enabled
                                ? colors.emerald
                                : colors.textFaint,
                            fontSize: 28,
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
                      alarm.title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (alarm.body.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          alarm.body,
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
                      alarm.daysLabel,
                      style: TextStyle(
                        color: colors.textFaint,
                        fontSize: AppConstants.fontMicro,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: alarm.enabled,
                onChanged: (v) =>
                    ref.read(alarmProvider.notifier).toggle(alarm, v),
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

class _AlarmEditorDialog extends StatefulWidget {
  final UserAlarm? existing;

  const _AlarmEditorDialog({this.existing});

  @override
  State<_AlarmEditorDialog> createState() => _AlarmEditorDialogState();
}

class _AlarmEditorDialogState extends State<_AlarmEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late TimeOfDay _time;
  late Set<int> _days;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(
      text: e?.title ?? '',
    );
    _bodyController = TextEditingController(
      text: e?.body ?? '',
    );
    _time = e != null
        ? TimeOfDay(hour: e.hour, minute: e.minute)
        : const TimeOfDay(hour: 4, minute: 0);
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
    final alarm = UserAlarm(
      id: widget.existing?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      body: _bodyController.text.trim(),
      hour: _time.hour,
      minute: _time.minute,
      daysOfWeek: _days,
      enabled: true,
    );
    Navigator.of(context).pop(alarm);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    const bnDays = ['সো', 'ম', 'বু', 'বৃ', 'শু', 'শ', 'র'];
    const enDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayNames = isBn ? bnDays : enDays;

    return AlertDialog(
      backgroundColor: colors.cardBackground,
      title: Text(
        widget.existing == null ? l10n.newAlarm : l10n.editAlarm,
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
              decoration: InputDecoration(
                hintText: l10n.alarmTitleHint,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            TextField(
              controller: _bodyController,
              style: TextStyle(color: colors.textPrimary),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.alarmBodyHint,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Text(
              l10n.whichDays,
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
                        dayNames[i],
                        style: TextStyle(
                          color: selected
                              ? colors.textOnEmerald
                              : colors.textMuted,
                          fontSize: 11,
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
                  l10n.noDayMeansEveryday,
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
          child: Text(l10n.cancel,
              style: TextStyle(color: colors.textMuted)),
        ),
        TextButton(
          onPressed: _save,
          child: Text(l10n.save,
              style: TextStyle(color: colors.emerald)),
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
    final l10n = AppLocalizations.of(context);
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
                Icons.alarm_rounded,
                color: colors.emerald,
                size: 44,
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              l10n.noAlarms,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: AppConstants.fontSubtitle,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              l10n.addFirstAlarm,
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
