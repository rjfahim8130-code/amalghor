import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amalghor/core/constants/app_constants.dart';
import 'package:amalghor/core/services/app_settings_service.dart';
import 'package:amalghor/core/theme/app_theme.dart';

class PdfGeneratorScreen extends StatefulWidget {
  const PdfGeneratorScreen({super.key});

  @override
  State<PdfGeneratorScreen> createState() => _PdfGeneratorScreenState();
}

class _PdfGeneratorScreenState extends State<PdfGeneratorScreen> {
  int _selectedYear = DateTime.now().year;
  PdfMode _mode = PdfMode.full;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AppSettingsService>();
    _mode = settings.pdfMode;
  }

  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);

    // TODO: Full PDF generation logic will be implemented next
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AppSettingsService>().t(
                  'PDF তৈরির ফিচার শীঘ্রই সম্পূর্ণ হবে ইনশাআল্লাহ',
                  'PDF generation feature will be completed soon InshaAllah',
                ),
          ),
          backgroundColor: AppColors.cardElevated,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsService>();
    final isBn = settings.isBangla;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isBn ? 'PDF ক্যালেন্ডার' : 'PDF Calendar'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            isBn ? 'সাল নির্বাচন করুন' : 'Select Year',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<int>(
              value: _selectedYear,
              isExpanded: true,
              dropdownColor: AppColors.cardElevated,
              underline: const SizedBox(),
              items: List.generate(5, (i) {
                final year = DateTime.now().year + i;
                return DropdownMenuItem(
                  value: year,
                  child: Text(
                    year.toString(),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                );
              }),
              onChanged: (v) => setState(() => _selectedYear = v!),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isBn ? 'ক্যালেন্ডার মোড' : 'Calendar Mode',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            title: isBn ? 'পূর্ণ ৩৬৫ দিন' : 'Full 365 Days',
            subtitle: isBn ? 'প্রতিদিন আলাদা' : 'Each day separate',
            selected: _mode == PdfMode.full,
            onTap: () => setState(() => _mode = PdfMode.full),
          ),
          _ModeCard(
            title: isBn ? 'সংক্ষিপ্ত (১ মিনিট)' : 'Short (1 Minute)',
            subtitle: isBn
                ? '১ মিনিটের মধ্যে কাছাকাছি দিনগুলো গ্রুপ'
                : 'Group days within 1 minute difference',
            selected: _mode == PdfMode.oneMinute,
            onTap: () => setState(() => _mode = PdfMode.oneMinute),
          ),
          _ModeCard(
            title: isBn ? 'সংক্ষিপ্ত (৩০ সেকেন্ড)' : 'Short (30 Seconds)',
            subtitle: isBn
                ? 'আরও কম্প্যাক্ট স্থায়ী ক্যালেন্ডার'
                : 'More compact permanent calendar',
            selected: _mode == PdfMode.thirtySecond,
            onTap: () => setState(() => _mode = PdfMode.thirtySecond),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generatePdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isGenerating
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded),
                        const SizedBox(width: 10),
                        Text(
                          isBn ? 'PDF তৈরি করুন' : 'Generate PDF',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFF1F1F1F),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
