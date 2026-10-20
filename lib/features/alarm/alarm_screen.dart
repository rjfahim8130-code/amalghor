import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../providers/alarm_provider.dart';
import '../../services/alarm_service.dart';

class AlarmScreen extends ConsumerWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final alarms = ref.watch(alarmProvider);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: Row(
          children: [
            Icon(Icons.alarm_rounded, color: colors.gold, size: 22),
            const SizedBox(width: 8),
            Text(
              'অ্যালার্ম',
              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: alarms.isEmpty
          ? _EmptyState(
              icon: Icons.alarm_rounded,
              title: 'কোনো অ্যালার্ম নেই',
              subtitle: 'নিচের বাটনে ট্যাপ করে প্রথম অ্যালার্ম যোগ করুন',
              accent: colors.gold,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spaceLg,
                AppConstants.spaceLg,
                AppConstants.spaceLg,
                100,
              ),
              itemCount: alarms.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spaceMd),
              itemBuilder: (_, i) => _AlarmTile(alarm: alarms[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.gold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('নতুন অ্যালার্ম'),
        onPressed: () => _showEditor(context, ref, null),
      ),
    );
  }

  Future<void> _showEditor(BuildContext context, WidgetRef ref, UserAlarm? existing) async {
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
      onDismissed: (_) => ref.read(alarmProvider.notifier).delete(alarm.id),
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
              color: alarm.enabled ? colors.gold : colors.border,
              width: alarm.enabled ? 1.4 : 1.0,
            ),
            boxShadow: colors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: alarm.enabled ? 0.15 : 0.05),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(
                    color: alarm.enabled ? colors.gold.withValues(alpha: 0.4) : colors.border,
                  ),
                ),
                child: Icon(
                  Icons.alarm_rounded,
                  color: alarm.enabled ? colors.gold : colors.textFaint,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.timeLabel,
                      style: TextStyle(
                        color: alarm.enabled ? colors.gold : colors.textFaint,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      alarm.title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      alarm.daysLabel,
                      style: TextStyle(color: colors.textMuted, fontSize: AppConstants.fontMicro),
                    ),
                  ],
                ),
              ),
              Switch(
                value: alarm.enabled,
                activeColor: colors.gold,
                onChanged: (v) => ref.read(alarmProvider.notifier).toggle(alarm, v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ALARM EDITOR
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
    _titleController = TextEditingController(text: e?.title ?? '🌌 তাহাজ্জুদ');
    _bodyController = TextEditingController(text: e?.body ?? 'তাহাজ্জুদ আদায় ও দুআর জন্য প্রস্তুত হোন। 🌙');
    _time = e != null ? TimeOfDay(hour: e.hour, minute: e.minute) : const TimeOfDay(hour: 4, minute: 0);
    _days = Set.from(e?.daysOfWeek ?? {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final colors = AppColors.of(context);
    final result = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _TimePickerSheet(
        initial: _time,
        accent: colors.gold,
      ),
    );
    if (result != null) setState(() => _time = result);
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final alarm = UserAlarm(
      id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
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

    return AlertDialog(
      backgroundColor: colors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        side: BorderSide(color: colors.border),
      ),
      title: Row(
        children: [
          Icon(Icons.alarm_rounded, color: colors.gold, size: 22),
          const SizedBox(width: 8),
          Text(widget.existing == null ? 'নতুন অ্যালার্ম' : 'সম্পাদনা', style: TextStyle(color: colors.textPrimary)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TimeDisplayChip(time: _time, accent: colors.gold, onTap: _pickTime),
            const SizedBox(height: AppConstants.spaceMd),
            TextField(
              controller: _titleController,
              style: TextStyle(color: colors.textPrimary),
              decoration: const InputDecoration(hintText: 'শিরোনাম (যেমন: 🌌 তাহাজ্জুদ)'),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            TextField(
              controller: _bodyController,
              style: TextStyle(color: colors.textPrimary),
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'বার্তা (ঐচ্ছিক)'),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Text('কোন দিনগুলোতে?', style: TextStyle(color: colors.textMuted, fontSize: AppConstants.fontCaption)),
            const SizedBox(height: AppConstants.spaceSm),
            _DaysSelector(
              selected: _days,
              accent: colors.gold,
              onToggle: (day) {
                setState(() {
                  if (_days.contains(day)) { _days.remove(day); } else { _days.add(day); }
                });
              },
            ),
            if (_days.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('কোনো দিন সিলেক্ট না করলে প্রতিদিন বাজবে', style: TextStyle(color: colors.textFaint, fontSize: AppConstants.fontMicro, fontStyle: FontStyle.italic)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('বাতিল', style: TextStyle(color: colors.textMuted))),
        TextButton(onPressed: _save, child: Text('সংরক্ষণ', style: TextStyle(color: colors.gold))),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// TIME PICKER SHEET (Custom Wheel Style)
// ─────────────────────────────────────────────

class _TimePickerSheet extends StatefulWidget {
  final TimeOfDay initial;
  final Color accent;
  const _TimePickerSheet({required this.initial, required this.accent});

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minuteCtrl;
  late FixedExtentScrollController _periodCtrl;

  late int _hour12;
  late int _minute;
  late int _periodIndex;

  @override
  void initState() {
    super.initState();
    final h = widget.initial.hour;
    _periodIndex = h < 12 ? 0 : 1;
    _hour12 = h % 12 == 0 ? 12 : h % 12;
    _minute = widget.initial.minute;
    _hourCtrl = FixedExtentScrollController(initialItem: _hour12 - 1);
    _minuteCtrl = FixedExtentScrollController(initialItem: _minute);
    _periodCtrl = FixedExtentScrollController(initialItem: _periodIndex);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    _periodCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    var h = _hour12 % 12;
    if (_periodIndex == 1) h += 12;
    Navigator.of(context).pop(TimeOfDay(hour: h, minute: _minute));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXl)),
      ),
      padding: const EdgeInsets.fromLTRB(AppConstants.spaceLg, AppConstants.spaceLg, AppConstants.spaceLg, AppConstants.spaceXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.textFaint, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: AppConstants.spaceLg),
          Text('সময় নির্বাচন করুন', style: TextStyle(color: colors.textPrimary, fontSize: AppConstants.fontSubtitle, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppConstants.spaceLg),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    border: Border.all(color: widget.accent.withValues(alpha: 0.25)),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _Wheel(
                        controller: _hourCtrl,
                        itemCount: 12,
                        itemBuilder: (index) => '${index + 1}',
                        selectedColor: widget.accent,
                        unselectedColor: colors.textFaint,
                        onChanged: (v) => setState(() => _hour12 = v + 1),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.only(right: 8), child: Text('h', style: TextStyle(color: colors.textMuted, fontSize: 14))),
                    Expanded(
                      flex: 3,
                      child: _Wheel(
                        controller: _minuteCtrl,
                        itemCount: 60,
                        itemBuilder: (index) => index.toString().padLeft(2, '0'),
                        selectedColor: widget.accent,
                        unselectedColor: colors.textFaint,
                        onChanged: (v) => setState(() => _minute = v),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.only(right: 8), child: Text('min', style: TextStyle(color: colors.textMuted, fontSize: 14))),
                    Expanded(
                      flex: 2,
                      child: _Wheel(
                        controller: _periodCtrl,
                        itemCount: 2,
                        itemBuilder: (index) => index == 0 ? 'AM' : 'PM',
                        selectedColor: widget.accent,
                        unselectedColor: colors.textFaint,
                        onChanged: (v) => setState(() => _periodIndex = v),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textMuted,
                    side: BorderSide(color: colors.border),
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMd)),
                  ),
                  child: const Text('বাতিল'),
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMd)),
                  ),
                  child: const Text('নিশ্চিত করুন', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) itemBuilder;
  final Color selectedColor;
  final Color unselectedColor;
  final ValueChanged<int> onChanged;

  const _Wheel({
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 46,
      physics: const FixedExtentScrollPhysics(),
      diameterRatio: 1.5,
      perspective: 0.003,
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final centered = controller.hasClients && (controller.offset / 46).round() == index;
          return Center(
            child: Text(
              itemBuilder(index),
              style: TextStyle(
                color: centered ? selectedColor : unselectedColor,
                fontSize: centered ? 26 : 18,
                fontWeight: centered ? FontWeight.w700 : FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeDisplayChip extends StatelessWidget {
  final TimeOfDay time;
  final Color accent;
  final VoidCallback onTap;

  const _TimeDisplayChip({required this.time, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceLg, horizontal: AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: accent,
                fontSize: 40,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Icon(Icons.edit, color: accent, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DaysSelector extends StatelessWidget {
  final Set<int> selected;
  final Color accent;
  final ValueChanged<int> onToggle;

  const _DaysSelector({required this.selected, required this.accent, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    const names = ['সো', 'ম', 'বু', 'বৃ', 'শু', 'শ', 'র'];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(7, (i) {
        final day = i + 1;
        final isSelected = selected.contains(day);
        return GestureDetector(
          onTap: () => onToggle(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? accent : colors.surfaceInset,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isSelected ? accent : colors.border),
            ),
            child: Center(
              child: Text(
                names[i],
                style: TextStyle(
                  color: isSelected ? Colors.black : colors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const _EmptyState({required this.icon, required this.title, required this.subtitle, required this.accent});

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
                color: accent.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: accent, size: 44),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Text(title, style: TextStyle(color: colors.textPrimary, fontSize: AppConstants.fontSubtitle, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppConstants.spaceSm),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: colors.textMuted, fontSize: AppConstants.fontBody)),
          ],
        ),
      ),
    );
  }
}
