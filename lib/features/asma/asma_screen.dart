import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final names = ref.watch(asmaFilteredProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('আল্লাহর ৯৯ নাম'),
      ),
      body: Column(
        children: [
          // ─── Search bar ──────────────────────
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
              style: const TextStyle(color: AppConstants.textPrimary),
              decoration: InputDecoration(
                hintText: 'খুঁজুন (নাম / অর্থ / নম্বর)',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppConstants.textMuted,
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

          // ─── List ────────────────────────────
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

// ─────────────────────────────────────────────
// TILE
// ─────────────────────────────────────────────

class _AsmaTile extends StatelessWidget {
  final AsmaName name;

  const _AsmaTile({required this.name});

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onLongPress: () => _copy(context, localeCode),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: AppConstants.surfaceDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(color: AppConstants.dividerColor),
          ),
          child: Row(
            children: [
              // Number badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppConstants.emeraldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(
                    color:
                        AppConstants.emeraldPrimary.withValues(alpha: 0.4),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${name.number}',
                    style: const TextStyle(
                      color: AppConstants.emeraldPrimary,
                      fontSize: AppConstants.fontBody,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Arabic
                    Text(
                      name.arabic,
                      style: const TextStyle(
                        color: AppConstants.goldAccent,
                        fontSize: 26,
                        fontFamily: 'NotoNaskhArabic',
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Transliteration
                    Text(
                      name.transliteration,
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Meaning
                    Text(
                      name.meaningFor(localeCode),
                      style: const TextStyle(
                        color: AppConstants.textMuted,
                        fontSize: AppConstants.fontCaption,
                      ),
                    ),
                  ],
                ),
              ),

              // Copy button
              IconButton(
                icon: const Icon(
                  Icons.copy,
                  size: 16,
                  color: AppConstants.textFaint,
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

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off,
            color: AppConstants.textFaint,
            size: 48,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          const Text(
            'কোনো নাম পাওয়া যায়নি',
            style: TextStyle(
              color: AppConstants.textMuted,
              fontSize: AppConstants.fontBody,
            ),
          ),
        ],
      ),
    );
  }
}
