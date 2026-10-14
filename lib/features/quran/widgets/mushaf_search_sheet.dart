import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../data/models/mushaf_models.dart';
import '../../../providers/mushaf_provider.dart';

class MushafSearchSheet extends ConsumerStatefulWidget {
  final void Function(int page) onGoToPage;

  const MushafSearchSheet({super.key, required this.onGoToPage});

  @override
  ConsumerState<MushafSearchSheet> createState() => _MushafSearchSheetState();
}

class _MushafSearchSheetState extends ConsumerState<MushafSearchSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;

    final config = ref.read(mushafConfigProvider).valueOrNull;
    if (config == null) return;

    // ফরম্যাট:
    // "19"        → পৃষ্ঠা ১৯
    // "পারা 2"    → ২য় পারার শুরু
    // "2 14"      → পারা ২, পৃষ্ঠা ১৪
    // "2:14"      → পারা ২, পৃষ্ঠা ১৪
    final page = _parse(raw, config);
    if (page == null) {
      setState(() => _error = 'সঠিক নম্বর দিন (যেমন: ১৯ অথবা ২ ১৪)');
      return;
    }
    widget.onGoToPage(page);
  }

  int? _parse(String raw, MushafConfig config) {
    final text = raw
        .replaceAll('পারা', ' ')
        .replaceAll('পৃষ্ঠা', ' ')
        .replaceAll('page', ' ')
        .replaceAll('para', ' ')
        .replaceAll(':', ' ')
        .replaceAll(',', ' ')
        .trim();

    final parts = text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return null;

    if (parts.length == 1) {
      final n = int.tryParse(parts[0]);
      if (n == null) return null;
      // শুধু এক নম্বর = গ্লোবাল পৃষ্ঠা
      if (config.isValidContentPage(n)) return n;
      // অথবা পারা নম্বর (১–৩০)
      if (n >= 1 && n <= 30) {
        final start = config.paraOf(n)?.startPage;
        return start; // int?
      }
      return null;
    }

    if (parts.length >= 2) {
      final para = int.tryParse(parts[0]);
      final paraPage = int.tryParse(parts[1]);
      if (para == null || paraPage == null) return null;
      final page = config.pageForParaPage(para, paraPage);
      return page; // int?
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'সার্চ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'পৃষ্ঠা: ১৯  |  পারা: ২  |  পারা+পৃষ্ঠা: ২ ১৪',
            style: TextStyle(fontSize: 12, color: AppConstants.textMuted),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.text,
            style: const TextStyle(color: AppConstants.textPrimary),
            decoration: InputDecoration(
              hintText: 'পৃষ্ঠা বা পারা নম্বর...',
              hintStyle: const TextStyle(color: AppConstants.textFaint),
              errorText: _error,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppConstants.emeraldPrimary,
              foregroundColor: Colors.black,
            ),
            child: const Text('যান'),
          ),
          const SizedBox(height: 16),
          const Text(
            'দ্রুত পারা',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppConstants.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 30,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final para = i + 1;
                return ActionChip(
                  label: Text('$para'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    final config = ref.read(mushafConfigProvider).valueOrNull;
                    final start = config?.paraOf(para)?.startPage;
                    if (start != null) widget.onGoToPage(start);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
