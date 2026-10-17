import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../providers/custom_notification_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/custom_notification_service.dart';

/// Notification Hub — tabbed screen.
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
        title: Text(
          '🔔 নোটিফিকেশন',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.emerald,
          labelColor: colors.emerald,
          unselectedLabelColor: colors.textMuted,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
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
          const _EmptyCustomState()
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
// PRAYER NOTIFICATION TILE — with offset slider
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
                Switch(value: enabled, onChanged: onToggle),
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
      onDismissed: (_) {
        ref.read(customNotificationProvider.notifier).delete(item.id);
      },
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
                            fontSize: 24,
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
        widget.existing == null ? 'নতুন নোটিফিকেশন' : 'সম্পাদনা',
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

class _EmptyCustomState extends StatelessWidget {
  const _EmptyCustomState();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: colors.textFaint,
              size: 48,
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Text(
              'এখনো কোনো কাস্টম নোটিফিকেশন নেই',
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

// ─────────────────────────────────────────────
// PERMISSION BANNER
// ─────────────────────────────────────────────

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
