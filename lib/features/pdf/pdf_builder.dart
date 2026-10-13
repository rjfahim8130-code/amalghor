import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/settings_model.dart';
import '../../services/bangla_date_service.dart';
import '../../services/hijri_service.dart';
import 'pdf_cluster.dart';
import 'pdf_fonts.dart';

/// Options controlling how the PDF is rendered.
class PdfOptions {
  final CalendarPrimary primaryCalendar;
  final MadhhabType madhhab;
  final bool showSafetyTimes;
  final String locationName;
  final double latitude;
  final double longitude;

  const PdfOptions({
    required this.primaryCalendar,
    required this.madhhab,
    required this.showSafetyTimes,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });
}

/// High-level PDF builder for the yearly prayer calendar.
class PdfBuilder {
  final PdfFonts fonts;
  final PdfOptions options;
  final BanglaDateService bangla = const BanglaDateService();
  final HijriService hijri = const HijriService();

  PdfBuilder({
    required this.fonts,
    required this.options,
  });

  /// Build the full PDF and return its bytes.
  Future<Uint8List> build(ClusterResult result) async {
    final doc = pw.Document(theme: fonts.theme);

    // Split clusters by month so each page shows a single Gregorian month.
    final byMonth = _groupByMonth(result.rows);

    final months = byMonth.keys.toList()..sort();

    for (final month in months) {
      final rows = byMonth[month]!;
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.portrait,
          margin: const pw.EdgeInsets.fromLTRB(24, 28, 24, 24),
          header: (ctx) => _header(month, result),
          footer: (ctx) => _footer(ctx, result),
          build: (ctx) => [
            _table(rows),
          ],
        ),
      );
    }

    return doc.save();
  }

  // ─────────────────────────────────────────────
  // GROUPS
  // ─────────────────────────────────────────────

  Map<int, List<ClusterRow>> _groupByMonth(List<ClusterRow> rows) {
    final map = <int, List<ClusterRow>>{};
    for (final r in rows) {
      final m = r.startDate.month;
      map.putIfAbsent(m, () => []).add(r);
    }
    return map;
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────

  pw.Widget _header(int month, ClusterResult result) {
    // English month name.
    final monthEn = DateFormat('MMMM y').format(DateTime(result.year, month));

    // Bangla months: may span two Bangla months in the same Gregorian month.
    final banglaMonths = _banglaMonthsFor(result.year, month);

    // Hijri months: same span logic.
    final hijriMonths = _hijriMonthsFor(result.year, month);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // English month (emerald)
          pw.Text(
            monthEn,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#10B981'),
            ),
          ),
          pw.SizedBox(height: 4),

          // Bangla months (gold)
          pw.Text(
            banglaMonths,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColor.fromHex('#D4A24A'),
            ),
          ),
          pw.SizedBox(height: 2),

          // Hijri months (sky blue)
          pw.Text(
            hijriMonths,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColor.fromHex('#0EA5E9'),
            ),
          ),
          pw.SizedBox(height: 8),

          // Location + method meta
          pw.Text(
            '${options.locationName}  •  '
            '${options.latitude.toStringAsFixed(2)}°, '
            '${options.longitude.toStringAsFixed(2)}°  •  '
            '${_madhhabLabel(options.madhhab)}  •  '
            '${result.granularity.label}',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey700,
            ),
          ),
          pw.Divider(color: PdfColors.grey400, height: 12),
        ],
      ),
    );
  }

  String _banglaMonthsFor(int year, int month) {
    final first = DateTime(year, month, 1);
    final last = DateTime(year, month + 1, 0);
    final b1 = bangla.convert(first).monthIndex;
    final b2 = bangla.convert(last).monthIndex;
    if (b1 == b2) return bangla.monthName(b1);
    return '${bangla.monthName(b1)} — ${bangla.monthName(b2)}';
  }

  String _hijriMonthsFor(int year, int month) {
    final first = DateTime(year, month, 1);
    final last = DateTime(year, month + 1, 0);
    final h1 = hijri.monthOfYear(first);
    final h2 = hijri.monthOfYear(last);
    if (h1 == h2) return hijri.monthName(h1, 'bn');
    return '${hijri.monthName(h1, 'bn')} — ${hijri.monthName(h2, 'bn')}';
  }

  String _madhhabLabel(MadhhabType m) =>
      m == MadhhabType.hanafi ? 'হানাফী' : 'শাফেঈ';

  // ─────────────────────────────────────────────
  // FOOTER
  // ─────────────────────────────────────────────

  pw.Widget _footer(pw.Context ctx, ClusterResult result) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            options.showSafetyTimes
                ? 'সেহরি: সতর্ক (ফজরের ৭ মিনিট আগে) | '
                    'ইফতার: সতর্ক (মাগরিবের ৩ মিনিট পরে)'
                : 'সেহরি / ইফতার: আসল সময়',
            style: pw.TextStyle(
              fontSize: 7,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} / ${ctx.pagesCount}',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TABLE
  // ─────────────────────────────────────────────

  pw.Widget _table(List<ClusterRow> rows) {
    final isHanafi = options.madhhab == MadhhabType.hanafi;

    // Headers.
    final headers = <String>[
      'তারিখ',
      'তাহাজ্জুদ',
      'সেহরি',
      'ফজর',
      'সূর্যোদয়',
      'ইশরাক',
      'যোহর',
      'আসর',
      'সূর্যাস্ত',
      'ইফতার',
      'মাগরিব',
      'এশা',
      if (isHanafi) 'মুস্তাহাব\nএশা',
    ];

    // Data rows.
    final data = rows.map((r) {
      return <String>[
        _dateCell(r),
        _shortTime(r.times.lastThirdStart),
        _safetyCell(r.times.sehriSafety, r.times.sehriActual, 'আসল'),
        _shortTime(r.times.fajr),
        _shortTime(r.times.sunrise),
        _shortTime(r.times.ishraq),
        _shortTime(r.times.dhuhr),
        _shortTime(r.times.asr),
        _shortTime(r.times.sunset),
        _safetyCell(r.times.iftarSafety, r.times.iftarActual, 'আসল'),
        _shortTime(r.times.maghrib),
        _shortTime(r.times.isha),
        if (isHanafi) _shortTime(r.times.ishaMustahab),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(
        color: PdfColors.grey400,
        width: 0.4,
      ),
      headerStyle: pw.TextStyle(
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#10B981'),
      ),
      cellStyle: pw.TextStyle(fontSize: 8),
      cellAlignments: {
        for (var i = 0; i < headers.length; i++) i: pw.Alignment.center,
      },
      cellPadding: const pw.EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 3,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CELL HELPERS
  // ─────────────────────────────────────────────

  String _dateCell(ClusterRow row) {
    final start = row.startDate;
    final end = row.endDate;

    final enStart = start.day.toString();
    final enEnd = end.day.toString();
    final enLabel = row.isSingleDay ? enStart : '$enStart–$enEnd';

    final bn = bangla.convert(start);
    final hn = hijri.toHijri(start);

    return '$enLabel\n'
        '${bangla.toBanglaDigits(bn.day)}  '
        '${bangla.toBanglaDigits(hn.hDay)}';
  }

  String _safetyCell(DateTime safety, DateTime actual, String label) {
    if (!options.showSafetyTimes) return _shortTime(actual);
    return '${_shortTime(safety)}\n$label ${_shortTime(actual)}';
  }

  String _shortTime(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final period = d.hour < 12 ? 'AM' : 'PM';
    return '$h12:$m $period';
  }
}
