import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/settings_provider.dart';

/// First-launch onboarding flow.
///
/// Users select their preferred language, after which the app
/// marks onboarding as complete.
class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top: skip button ───────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceLg,
                vertical: AppConstants.spaceSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_page < 2)
                    TextButton(
                      onPressed: _finish,
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: AppConstants.textMuted),
                      ),
                    ),
                ],
              ),
            ),

            // ─── Pages ──────────────────────────
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _PageOne(),
                  _PageTwo(),
                  _PageThree(),
                ],
              ),
            ),

            // ─── Page indicator ────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppConstants.emeraldPrimary
                        : AppConstants.textFaint,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                  ),
                );
              }),
            ),

            const SizedBox(height: AppConstants.spaceLg),

            // ─── Next / Get started button ─────
            Padding(
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_page < 2) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    } else {
                      _finish();
                    }
                  },
                  child: Text(_page < 2 ? 'পরবর্তী' : 'শুরু করুন'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).complete();
    widget.onComplete();
  }
}

// ─────────────────────────────────────────────
// PAGES
// ─────────────────────────────────────────────

class _PageOne extends StatelessWidget {
  const _PageOne();

  @override
  Widget build(BuildContext context) {
    return const _PageLayout(
      icon: Icons.access_time_rounded,
      iconColor: AppConstants.emeraldPrimary,
      title: 'আমলঘর',
      subtitle: 'আপনার প্রতিদিনের নামায ও ইবাদতের\nনির্ভরযোগ্য সঙ্গী',
      bullets: [
        'সঠিক সময়ে নামাযের সময়সূচি',
        'সম্পূর্ণ অফলাইনে চলে',
        'কোনো সার্ভার নেই, কোনো ট্র্যাকিং নেই',
      ],
    );
  }
}

class _PageTwo extends ConsumerWidget {
  const _PageTwo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppConstants.emeraldPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.language,
              color: AppConstants.emeraldPrimary,
              size: 48,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXl),
          const Text(
            'ভাষা নির্বাচন করুন',
            style: TextStyle(
              color: AppConstants.textPrimary,
              fontSize: AppConstants.fontTitle,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spaceSm),
          const Text(
            'Choose your language',
            style: TextStyle(
              color: AppConstants.textMuted,
              fontSize: AppConstants.fontBody,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spaceXl),

          _LangOption(
            label: 'বাংলা',
            sublabel: 'Bangla',
            code: 'bn',
            selected: settings.locale.languageCode == 'bn',
            onTap: () => notifier.setLocale(const Locale('bn')),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          _LangOption(
            label: 'English',
            sublabel: 'ইংরেজি',
            code: 'en',
            selected: settings.locale.languageCode == 'en',
            onTap: () => notifier.setLocale(const Locale('en')),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          _LangOption(
            label: 'العربية',
            sublabel: 'আরবি',
            code: 'ar',
            selected: settings.locale.languageCode == 'ar',
            onTap: () => notifier.setLocale(const Locale('ar')),
          ),
        ],
      ),
    );
  }
}

class _PageThree extends StatelessWidget {
  const _PageThree();

  @override
  Widget build(BuildContext context) {
    return const _PageLayout(
      icon: Icons.check_circle_outline,
      iconColor: AppConstants.emeraldPrimary,
      title: 'সব প্রস্তুত',
      subtitle: 'আপনার ডিভাইস সম্পূর্ণ অফলাইনে কাজ করবে।\nএখন থেকে নামাযের সঠিক সময়,\nকুরআন, দুআ, তাসবীহ — সব হাতের মুঠোয়।',
      bullets: [],
    );
  }
}

// ─────────────────────────────────────────────
// LAYOUT TEMPLATE
// ─────────────────────────────────────────────

class _PageLayout extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<String> bullets;

  const _PageLayout({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: iconColor.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 56),
          ),
          const SizedBox(height: AppConstants.space2xl),
          Text(
            title,
            style: const TextStyle(
              color: AppConstants.textPrimary,
              fontSize: AppConstants.fontTitle,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppConstants.textMuted,
              fontSize: AppConstants.fontBody,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (bullets.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceXl),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check,
                      color: AppConstants.emeraldPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: AppConstants.spaceSm),
                    Text(
                      b,
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: AppConstants.fontBody,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LANGUAGE OPTION
// ─────────────────────────────────────────────

class _LangOption extends StatelessWidget {
  final String label;
  final String sublabel;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({
    required this.label,
    required this.sublabel,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceLg,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppConstants.emeraldPrimary.withValues(alpha: 0.15)
                : AppConstants.surfaceDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: selected
                  ? AppConstants.emeraldPrimary
                  : AppConstants.dividerColor,
              width: selected ? 1.6 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? AppConstants.emeraldPrimary
                    : AppConstants.textFaint,
                size: 22,
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: AppConstants.fontSubtitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: const TextStyle(
                        color: AppConstants.textMuted,
                        fontSize: AppConstants.fontCaption,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  color: AppConstants.emeraldPrimary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
