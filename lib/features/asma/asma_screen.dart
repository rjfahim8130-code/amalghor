import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../data/models/asma_models.dart';
import '../../providers/asma_provider.dart';

/// Screen listing all 99 Names of Allah with search.
class AsmaScreen extends ConsumerStatefulWidget {
  const AsmaScreen({super.key});

  @override
  ConsumerState<AsmaScreen> createState() => _AsmaScreenState();
}

class _AsmaScreenState extends ConsumerState<AsmaScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final names = ref.watch(asmaFilteredProvider);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        backgroundColor: colors.pageBackground,
        title: Text(
          'আল্লাহর ৯৯ নাম',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceLg,
              AppConstants.spaceMd,
              AppConstants.spaceLg,
              AppConstants.spaceSm,
            ),
            child: TextField(
              controller: _controller,
              onChanged: (v) =>
                  ref.read(asmaSearchProvider.notifier).update(v),
              style: TextStyle(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'খুঁজুন (নাম / অর্থ / নম্বর)',
                prefixIcon: Icon(
                  Icons.search,
                  color: colors.textMuted,
                ),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _controller.clear();
                          ref.read(asmaSearchProvider.notifier).clear();
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: names.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceLg,
                      vertical: AppConstants.spaceSm,
                    ),
                    itemCount: names.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppConstants.spaceSm),
                    itemBuilder: (_, i) => _AsmaTile(name: names[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AsmaTile extends StatelessWidget {
  final AsmaName name;

  const _AsmaTile({required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onLongPress: () => _copy(context, localeCode),
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            border: Border.all(color: colors.border, width: 1.0),
            boxShadow: colors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.iconBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: colors.iconBorder),
                ),
                child: Center(
                  child: Text(
                    '${name.number}',
                    style: TextStyle(
                      color: colors.emerald,
                      fontSize: AppConstants.fontBody,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.arabic,
                      style: TextStyle(
                        color: colors.gold,
                        fontSize: 26,
                        fontFamily: 'NotoNaskhArabic',
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name.transliteration,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name.meaningFor(localeCode),
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: AppConstants.fontCaption,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy,
                  size: 16,
                  color: colors.textFaint,
                ),
                onPressed: () => _copy(context, localeCode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context, String localeCode) async {
    final text =
        '${name.number}. ${name.arabic} — ${name.transliteration}'
        ' (${name.meaningFor(localeCode)})';
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            color: colors.textFaint,
            size: 48,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'কোনো নাম পাওয়া যায়নি',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: AppConstants.fontBody,
            ),
          ),
        ],
      ),
    );
  }
}
