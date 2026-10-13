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
  final Set<PdfColumn> columns;
  final String appName;
  final String appTagline;

  const PdfOptions({
    required this.primaryCalendar,
    required this.madhhab,
    required this.showSafetyTimes,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.columns,
    this.appName = 'আমলঘর',
    this.appTagline = 'নামাযের সময়সূচি',
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

  Future<Uint8List> build(ClusterResult result) async {
    final doc = pw.Document(
      title: '${options.appName} — ${result.year}',
      author: options.appName,
      theme: fonts.theme,
    );

    // Split clusters by Gregorian month.
    final byMonth = _groupByMonth(result.rows);
    final months = byMonth.keys.toList()..sort();

    for (final month in months) {
      final rows = byMonth[month]!;
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.portrait,
          margin: const pw.EdgeInsets.fromLTRB(20, 24, 20, 20),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _header(month, result),
              pw.SizedBox(height: 10),
              _table(rows),
              pw.Spacer(),
              _footer(ctx, result),
            ],
          ),
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
    final monthEn =
        DateFormat('MMMM y').format(DateTime(result.year, month));
    final banglaMonths = _banglaMonthsFor(result.year, month);
    final hijriMonths = _hijriMonthsFor(result.year, month);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // ─── App brand row ──────────────────
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // App name + logo badge
            pw.Row(
              children: [
                pw.Container(
                  width: 26,
                  height: 26,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#10B981'),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'আ',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      options.appName,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#10B981'),
                      ),
                    ),
                    pw.Text(
                      options.appTagline,
                      style: pw.TextStyle(
                        fontSize: 7,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Location meta
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  options.locationName,
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Text(
                  '${options.latitude.toStringAsFixed(2)}°, '
                  '${options.longitude.toStringAsFixed(2)}°',
                  style: pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey500,
                  ),
                ),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 10),

        // ─── Month titles (3 calendars) ─────
        pw.Text(
          monthEn,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#10B981'),
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          banglaMonths,
          style: pw.TextStyle(
            fontSize: 11,
            color: PdfColor.fromHex('#D4A24A'),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          hijriMonths,
          style: pw.TextStyle(
            fontSize: 11,
            color: PdfColor.fromHex('#0EA5E9'),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${_madhhabLabel(options.madhhab)} মাযহাব  •  '
          '${result.granularity.label}',
          style: pw.TextStyle(
            fontSize: 7.5,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Divider(color: PdfColors.grey400, height: 2),
      ],
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
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            options.showSafetyTimes
                ? 'সেহরি: ৭ মিনিট আগে (সতর্ক) | ইফতার: ৩ মিনিট পরে (সতর্ক)'
                : 'সেহরি / ইফতার: আসল সময়',
            style: pw.TextStyle(
              fontSize: 7,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            '${options.appName} — পৃষ্ঠা ${ctx.pageNumber} / ${ctx.pagesCount}',
            style: pw.TextStyle(
              fontSize: 7,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TABLE — with automatic column fallback
  // ─────────────────────────────────────────────

  pw.Widget _table(List<ClusterRow> rows) {
    // ─── Fallback: if the user somehow cleared all columns (or
    //     state got out of sync), use the default set so the PDF
    //     always renders at least the date column.
    Set<PdfColumn> cols = options.columns;
    if (cols.isEmpty) {
      cols = PdfColumnSelection.defaultSelection(
        isHanafi: options.madhhab == MadhhabType.hanafi,
      ).columns;
    }

    // Always keep the date column first.
    final orderedCols = <PdfColumn>[
      PdfColumn.date,
      ...PdfColumn.values.where(
        (c) => c != PdfColumn.date && cols.contains(c),
      ),
    ];

    // Headers.
    final headers = <String>[
      for (final c in orderedCols) c.label,
    ];

    // Data rows.
    final data = rows.map((r) {
      return <String>[
        for (final c in orderedCols) _cellFor(r, c),
      ];
    }).toList();

    // Column alignment: first column left, others center.
    final alignments = <int, pw.Alignment>{
      for (var i = 0; i < orderedCols.length; i++)
        i: i == 0 ? pw.Alignment.centerLeft : pw.Alignment.center,
    };

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
      cellStyle: pw.TextStyle(fontSize: 7.5),
      cellAlignments: alignments,
      cellPadding: const pw.EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 2.5,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CELL HELPERS
  // ─────────────────────────────────────────────

  String _cellFor(ClusterRow row, PdfColumn col) {
    switch (col) {
      case PdfColumn.date:
        return _dateCell(row);
      case PdfColumn.tahajjud:
        return _shortTime(row.times.lastThirdStart);
      case PdfColumn.sehri:
        return _safetyCell(
          row.times.sehriSafety,
          row.times.sehriActual,
        );
      case PdfColumn.fajr:
        return _shortTime(row.times.fajr);
      case PdfColumn.sunrise:
        return _shortTime(row.times.sunrise);
      case PdfColumn.ishraq:
        return _shortTime(row.times.ishraq);
      case PdfColumn.dhuhr:
        return _shortTime(row.times.dhuhr);
      case PdfColumn.asr:
        return _shortTime(row.times.asr);
      case PdfColumn.sunset:
        return _shortTime(row.times.sunset);
      case PdfColumn.iftar:
        return _safetyCell(
          row.times.iftarSafety,
          row.times.iftarActual,
        );
      case PdfColumn.maghrib:
        return _shortTime(row.times.maghrib);
      case PdfColumn.isha:
        return _shortTime(row.times.isha);
      case PdfColumn.ishaMustahab:
        return _shortTime(row.times.ishaMustahab);
    }
  }

  /// Date cell: English (big) on top, Bangla & Hijri (small) below.
  /// Multi-day clusters show "1-3" instead of "1".
  String _dateCell(ClusterRow row) {
    final start = row.startDate;
    final end = row.endDate;

    final enLabel = row.isSingleDay
        ? '${start.day}'
        : '${start.day}–${end.day}';

    final bn = bangla.convert(start);
    final hn = hijri.toHijri(start);

    final bnLabel = bangla.toBanglaDigits(bn.day);
    final hnLabel = bangla.toBanglaDigits(hn.hDay);

    return '$enLabel\n$bnLabel    $hnLabel';
  }

  /// Safety cell: big safety time on top, small "real" time below.
  String _safetyCell(DateTime safety, DateTime actual) {
    if (!options.showSafetyTimes) return _shortTime(actual);
    return '${_shortTime(safety)}\nআসল ${_shortTime(actual)}';
  }

  /// Format HH:MM with seconds when seconds != 0.
  String _shortTime(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final s = d.second;
    final period = d.hour < 12 ? 'AM' : 'PM';
    if (s == 0) {
      return '$h12:$m $period';
    }
    return '$h12:$m:${s.toString().padLeft(2, '0')} $period';
  }
}
