import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../providers/custom_notification_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/custom_notification_service.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: Row(
          children: [
            Icon(Icons.notifications_active_outlined,
                color: colors.emerald, size: 22),
            const SizedBox(width: 8),
            Text(
              'নোটিফিকেশন',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.emerald,
          labelColor: colors.emerald,
          unselectedLabelColor: colors.textMuted,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'নামাযের রিমাইন্ডার'),
            Tab(text: 'কাস্টম'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PrayerRemindersTab(),
          _CustomNotificationsTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 1 — PRAYER REMINDERS
// ─────────────────────────────────────────────

class _PrayerRemindersTab extends ConsumerWidget {
  const _PrayerRemindersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    Future<void> update(Future<void> Function() action) async {
      await action();
      await ref.read(notificationProvider.notifier).reschedule();
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      children: [
        const _NotificationPermissionBanner(),
        const SizedBox(height: AppConstants.spaceMd),
        Text(
          'প্রতিটি নামাযের জন্য নোটিফিকেশন চালু/বন্ধ করুন এবং কত মিনিট আগে রিমাইন্ডার চান সেটা সেট করুন।',
          style: TextStyle(
            color: colors.textMuted,
            fontSize: AppConstants.fontCaption,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppConstants.spaceLg),
        _PrayerNotifTile(
          title: '🌅 ফজর',
          enabled: settings.notifFajr,
          offset: settings.offsetFajr,
          onToggle: (v) => update(() => notifier.setNotifFajr(v)),
          onOffset: (v) => update(() => notifier.setOffset('fajr', v)),
        ),
        _PrayerNotifTile(
          title: '☀️ যোহর',
          enabled: settings.notifDhuhr,
          offset: settings.offsetDhuhr,
          onToggle: (v) => update(() => notifier.setNotifDhuhr(v)),
          onOffset: (v) => update(() => notifier.setOffset('dhuhr', v)),
        ),
        _PrayerNotifTile(
          title: '🌤️ আসর',
          enabled: settings.notifAsr,
          offset: settings.offsetAsr,
          onToggle: (v) => update(() => notifier.setNotifAsr(v)),
          onOffset: (v) => update(() => notifier.setOffset('asr', v)),
        ),
        _PrayerNotifTile(
          title: '🌇 মাগরিব',
          enabled: settings.notifMaghrib,
          offset: settings.offsetMaghrib,
          onToggle: (v) => update(() => notifier.setNotifMaghrib(v)),
          onOffset: (v) => update(() => notifier.setOffset('maghrib', v)),
        ),
        _PrayerNotifTile(
          title: '🌙 এশা',
          enabled: settings.notifIsha,
          offset: settings.offsetIsha,
          onToggle: (v) => update(() => notifier.setNotifIsha(v)),
          onOffset: (v) => update(() => notifier.setOffset('isha', v)),
        ),
        _PrayerNotifTile(
          title: '🥣 সেহরি শেষ',
          enabled: settings.notifSehri,
          offset: settings.offsetSehri,
          onToggle: (v) => update(() => notifier.setNotifSehri(v)),
          onOffset: (v) => update(() => notifier.setOffset('sehri', v)),
        ),
        _PrayerNotifTile(
          title: '🌙 ইফতার',
          enabled: settings.notifIftar,
          offset: settings.offsetIftar,
          onToggle: (v) => update(() => notifier.setNotifIftar(v)),
          onOffset: (v) => update(() => notifier.setOffset('iftar', v)),
        ),
        _PrayerNotifTile(
          title: '🌌 তাহাজ্জুদ',
          enabled: settings.notifTahajjud,
          offset: settings.offsetTahajjud,
          onToggle: (v) => update(() => notifier.setNotifTahajjud(v)),
          onOffset: (v) => update(() => notifier.setOffset('tahajjud', v)),
        ),
        const SizedBox(height: AppConstants.spaceXl),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PRAYER NOTIFICATION TILE
// ─────────────────────────────────────────────

class _PrayerNotifTile extends StatelessWidget {
  final String title;
  final bool enabled;
  final int offset;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onOffset;

  const _PrayerNotifTile({
    required this.title,
    required this.enabled,
    required this.offset,
    required this.onToggle,
    required this.onOffset,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: enabled ? colors.borderStrong : colors.border,
            width: enabled ? 1.3 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: AppConstants.fontBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: enabled,
                  activeColor: colors.emerald,
                  onChanged: onToggle,
                ),
              ],
            ),
            if (enabled)
              Row(
                children: [
                  Text(
                    '${offset}মি',
                    style: TextStyle(
                      color: colors.emerald,
                      fontSize: AppConstants.fontCaption,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: offset.toDouble(),
                      min: 0,
                      max: 60,
                      divisions: 12,
                      activeColor: colors.emerald,
                      inactiveColor: colors.divider,
                      onChanged: (v) => onOffset(v.round()),
                    ),
                  ),
                  Text(
                    'আগে',
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: AppConstants.fontMicro,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 2 — CUSTOM NOTIFICATIONS
// ─────────────────────────────────────────────

class _CustomNotificationsTab extends ConsumerWidget {
  const _CustomNotificationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final items = ref.watch(customNotificationProvider);

    return Stack(
      children: [
        if (items.isEmpty)
          _EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'কোনো কাস্টম নোটিফিকেশন নেই',
            subtitle: 'নিচের বাটনে ট্যাপ করে প্রথম নোটিফিকেশন যোগ করুন',
            accent: colors.emerald,
          )
        else
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              AppConstants.spaceLg,
              100,
            ),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppConstants.spaceMd),
            itemBuilder: (_, i) => _NotificationTile(
              item: items[i],
              onTap: () => _showEditor(context, ref, items[i]),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            backgroundColor: colors.emerald,
            foregroundColor: colors.textOnEmerald,
            icon: const Icon(Icons.add),
            label: const Text('নতুন'),
            onPressed: () => _showEditor(context, ref, null),
          ),
        ),
      ],
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
// CUSTOM NOTIFICATION TILE
// ─────────────────────────────────────────────

class _NotificationTile extends ConsumerWidget {
  final UserNotification item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

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
      onDismissed: (_) =>
          ref.read(customNotificationProvider.notifier).delete(item.id),
      child: InkWell(
        onTap: onTap,
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.emerald
                      .withValues(alpha: item.enabled ? 0.15 : 0.05),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(
                    color: item.enabled
                        ? colors.emerald.withValues(alpha: 0.4)
                        : colors.border,
                  ),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: item.enabled
                      ? colors.emerald
                      : colors.textFaint,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.timeLabel,
                      style: TextStyle(
                        color: item.enabled
                            ? colors.emerald
                            : colors.textFaint,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFeatures:
                            const [FontFeature.tabularFigures()],
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      item.title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.daysLabel,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: AppConstants.fontMicro,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: item.enabled,
                activeColor: colors.emerald,
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
    final colors = AppColors.of(context);
    final result = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _TimePickerSheet(
        initial: _time,
        accent: colors.emerald,
      ),
    );
    if (result != null) setState(() => _time = result);
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        side: BorderSide(color: colors.border),
      ),
      title: Row(
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: colors.emerald,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            widget.existing == null ? 'নতুন নোটিফিকেশন' : 'সম্পাদনা',
            style: TextStyle(color: colors.textPrimary),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TimeDisplayChip(
              time: _time,
              accent: colors.emerald,
              onTap: _pickTime,
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
            _DaysSelector(
              selected: _days,
              accent: colors.emerald,
              onToggle: (day) {
                setState(() {
                  if (_days.contains(day)) {
                    _days.remove(day);
                  } else {
                    _days.add(day);
                  }
                });
              },
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
          child: Text(
            'বাতিল',
            style: TextStyle(color: colors.textMuted),
          ),
        ),
        TextButton(
          onPressed: _save,
          child: Text(
            'সংরক্ষণ',
            style: TextStyle(color: colors.emerald),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// TIME PICKER SHEET
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
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.spaceXl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textFaint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          Text(
            'সময় নির্বাচন করুন',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: AppConstants.fontSubtitle,
              fontWeight: FontWeight.w700,
            ),
          ),
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
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                    border: Border.all(
                      color: widget.accent.withValues(alpha: 0.25),
                    ),
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
                        onChanged: (v) =>
                            setState(() => _hour12 = v + 1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        'h',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _Wheel(
                        controller: _minuteCtrl,
                        itemCount: 60,
                        itemBuilder: (index) =>
                            index.toString().padLeft(2, '0'),
                        selectedColor: widget.accent,
                        unselectedColor: colors.textFaint,
                        onChanged: (v) =>
                            setState(() => _minute = v),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        'min',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _Wheel(
                        controller: _periodCtrl,
                        itemCount: 2,
                        itemBuilder: (index) =>
                            index == 0 ? 'AM' : 'PM',
                        selectedColor: widget.accent,
                        unselectedColor: colors.textFaint,
                        onChanged: (v) =>
                            setState(() => _periodIndex = v),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spaceMd,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spaceMd,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                  ),
                  child: const Text(
                    'নিশ্চিত করুন',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
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
          final centered = controller.hasClients &&
              (controller.offset / 46).round() == index;
          return Center(
            child: Text(
              itemBuilder(index),
              style: TextStyle(
                color: centered ? selectedColor : unselectedColor,
                fontSize: centered ? 26 : 18,
                fontWeight:
                    centered ? FontWeight.w700 : FontWeight.w500,
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

  const _TimeDisplayChip({
    required this.time,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spaceLg,
          horizontal: AppConstants.spaceMd,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${time.hour.toString().padLeft(2, '0')}:'
              '${time.minute.toString().padLeft(2, '0')}',
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

  const _DaysSelector({
    required this.selected,
    required this.accent,
    required this.onToggle,
  });

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
              border: Border.all(
                color: isSelected ? accent : colors.border,
              ),
            ),
            child: Center(
              child: Text(
                names[i],
                style: TextStyle(
                  color: isSelected
                      ? Colors.black
                      : colors.textMuted,
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

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

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
                border: Border.all(
                  color: accent.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(icon, color: accent, size: 44),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              title,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: AppConstants.fontSubtitle,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              subtitle,
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

class _NotificationPermissionBanner extends ConsumerWidget {
  const _NotificationPermissionBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final status = ref.watch(notificationProvider);

    if (status == NotificationPermissionStatus.granted) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        onTap: () async {
          final granted = await ref
              .read(notificationProvider.notifier)
              .requestPermission();
          if (granted) {
            await ref.read(notificationProvider.notifier).reschedule();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: colors.gold.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: colors.gold.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: colors.gold,
                size: 22,
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'নোটিফিকেশন চালু করুন',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'ট্যাপ করে অনুমতি দিন',
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: AppConstants.fontCaption,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.gold,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
