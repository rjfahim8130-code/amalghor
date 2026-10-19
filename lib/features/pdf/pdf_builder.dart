import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/settings_model.dart';
import '../../services/bangla_date_service.dart';
import '../../services/hijri_service.dart';
import 'pdf_cluster.dart';
import 'pdf_fonts.dart';

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

  /// Locale for the generated PDF (e.g. 'en' or 'bn').
  final String locale;

  const PdfOptions({
    required this.primaryCalendar,
    required this.madhhab,
    required this.showSafetyTimes,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.columns,
    this.appName = 'AmalGhor',
    this.appTagline = 'Prayer timetable',
    this.locale = 'bn',
  });
}

class PdfBuilder {
  final PdfFonts fonts;
  final PdfOptions options;
  final BanglaDateService bangla = const BanglaDateService();
  final HijriService hijri = const HijriService();

  PdfBuilder({
    required this.fonts,
    required this.options,
  });

  bool get _isEn => options.locale == 'en';

  Future<Uint8List> build(ClusterResult result) async {
    final doc = pw.Document(
      title: '${options.appName} — ${result.year}',
      author: options.appName,
      theme: fonts.theme,
    );

    final byMonth = _groupByMonth(result.rows);
    final months = byMonth.keys.toList()..sort();

    for (final month in months) {
      final rows = byMonth[month]!;
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.portrait,
          margin: const pw.EdgeInsets.fromLTRB(16, 20, 16, 16),
          header: (ctx) => ctx.pageNumber == 1
              ? _header(month, result)
              : pw.SizedBox.shrink(),
          footer: (ctx) => _footer(ctx, result),
          build: (ctx) => [
            pw.SizedBox(height: 6),
            _buildTable(rows),
          ],
        ),
      );
    }

    return doc.save();
  }

  Map<int, List<ClusterRow>> _groupByMonth(List<ClusterRow> rows) {
    final map = <int, List<ClusterRow>>{};
    for (final r in rows) {
      final m = r.startDate.month;
      map.putIfAbsent(m, () => []).add(r);
    }
    return map;
  }

  pw.Widget _header(int month, ClusterResult result) {
    final monthEn =
        DateFormat('MMMM y').format(DateTime(result.year, month));
    final banglaMonths = _banglaMonthsFor(result.year, month);
    final hijriMonths = _hijriMonthsFor(result.year, month);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              children: [
                pw.Container(
                  width: 24,
                  height: 24,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#10B981'),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      _isEn ? 'A' : 'আ',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
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
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#10B981'),
                      ),
                    ),
                    pw.Text(
                      options.appTagline,
                      style: pw.TextStyle(
                        fontSize: 6.5,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  options.locationName,
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Text(
                  '${options.latitude.toStringAsFixed(2)}°, '
                  '${options.longitude.toStringAsFixed(2)}°',
                  style: pw.TextStyle(
                    fontSize: 6.5,
                    color: PdfColors.grey500,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          monthEn,
          style: pw.TextStyle(
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#10B981'),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          banglaMonths,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColor.fromHex('#D4A24A'),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          hijriMonths,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColor.fromHex('#0EA5E9'),
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '${_madhhabLabel(options.madhhab)} '
          '${_isEn ? 'Madhhab' : 'মাযহাব'}  •  '
          '${result.granularity.label}',
          style: pw.TextStyle(
            fontSize: 7,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 5),
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

  String _madhhabLabel(MadhhabType m) {
    if (m == MadhhabType.hanafi) {
      return _isEn ? 'Hanafi' : 'হানাফী';
    }
    return _isEn ? "Shafi'i" : 'শাফেঈ';
  }

  pw.Widget _footer(pw.Context ctx, ClusterResult result) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 6),
      padding: const pw.EdgeInsets.only(top: 4),
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
                ? (_isEn
                    ? 'Sehri: 7 min before  •  Iftar: 3 min after'
                    : 'সেহরি: ৭ মিনিট আগে  •  ইফতার: ৩ মিনিট পরে')
                : (_isEn
                    ? 'Sehri / Iftar: actual time'
                    : 'সেহরি / ইফতার: মূল সময়'),
            style: pw.TextStyle(
              fontSize: 6.5,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            '${options.appName}  •  '
            '${_isEn ? 'Page' : 'পৃষ্ঠা'} '
            '${ctx.pageNumber} / ${ctx.pagesCount}',
            style: pw.TextStyle(
              fontSize: 6.5,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTable(List<ClusterRow> rows) {
    Set<PdfColumn> cols = options.columns;
    if (cols.isEmpty || cols.length < 2) {
      cols = PdfColumnSelection.defaultSelection(
        isHanafi: options.madhhab == MadhhabType.hanafi,
      ).columns;
    }

    final ordered = <PdfColumn>[
      PdfColumn.date,
      ...PdfColumn.values.where(
        (c) => c != PdfColumn.date && cols.contains(c),
      ),
    ];

    // Header row
    final header = pw.TableRow(
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#10B981'),
      ),
      children: ordered
          .map(
            (c) => pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 1.5,
                vertical: 3,
              ),
              child: pw.Text(
                _columnLabel(c),
                style: pw.TextStyle(
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          )
          .toList(),
    );

    // Data rows
    final dataRows = <pw.TableRow>[];
    for (var r = 0; r < rows.length; r++) {
      final row = rows[r];
      final isEven = r.isEven;

      dataRows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isEven ? PdfColors.white : PdfColor.fromHex('#F3F4F6'),
          ),
          children: ordered.map((c) {
            final isDate = c == PdfColumn.date;
            return pw.Container(
              alignment:
                  isDate ? pw.Alignment.centerLeft : pw.Alignment.center,
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 3,
              ),
              child: pw.Text(
                _cellFor(row, c),
                style: pw.TextStyle(
                  fontSize: 7,
                  lineSpacing: 1.2,
                ),
                textAlign: isDate ? pw.TextAlign.left : pw.TextAlign.center,
              ),
            );
          }).toList(),
        ),
      );
    }

    final widths = <int, pw.TableColumnWidth>{};
    for (var i = 0; i < ordered.length; i++) {
      widths[i] = ordered[i] == PdfColumn.date
          ? const pw.FlexColumnWidth(1.6)
          : const pw.FlexColumnWidth(1.0);
    }

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey400,
        width: 0.35,
      ),
      columnWidths: widths,
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [header, ...dataRows],
    );
  }

  String _columnLabel(PdfColumn c) {
    final isEn = _isEn;
    switch (c) {
      case PdfColumn.date:
        return isEn ? 'Date' : 'তারিখ';
      case PdfColumn.fajr:
        return isEn ? 'Fajr' : 'ফজর';
      case PdfColumn.sunrise:
        return isEn ? 'Sunrise' : 'সূর্যোদয়';
      case PdfColumn.dhuhr:
        return isEn ? 'Dhuhr' : 'যোহর';
      case PdfColumn.asr:
        return isEn ? 'Asr' : 'আসর';
      case PdfColumn.maghrib:
        return isEn ? 'Maghrib' : 'মাগরিব';
      case PdfColumn.isha:
        return isEn ? 'Isha' : 'এশা';
      case PdfColumn.sehri:
        return isEn ? 'Sehri' : 'সেহরি';
      case PdfColumn.iftar:
        return isEn ? 'Iftar' : 'ইফতার';
      case PdfColumn.tahajjud:
        return isEn ? 'Tahajjud' : 'তাহাজ্জুদ';
      case PdfColumn.ishraq:
        return isEn ? 'Ishraq' : 'ইশরাক';
      case PdfColumn.midnight:
        return isEn ? 'Midnight' : 'রাত অর্ধেক';
      case PdfColumn.solarNoon:
        return isEn ? 'Solar noon' : 'মধ্য আকাশ';
      case PdfColumn.sunset:
        return isEn ? 'Sunset' : 'সূর্যাস্ত';
      case PdfColumn.ishaMustahab:
        return isEn ? 'Mustahabb Isha' : 'মুস্তাহাব এশা';
    }
  }

  String _cellFor(ClusterRow row, PdfColumn col) {
    switch (col) {
      case PdfColumn.date:
        return _dateCell(row);
      case PdfColumn.tahajjud:
        return _shortTime(row.times.lastThirdStart);
      case PdfColumn.sehri:
        return _sehriIftarCell(
          actual: row.times.sehriActual,
          safety: row.times.sehriSafety,
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
        return _sehriIftarCell(
          actual: row.times.iftarActual,
          safety: row.times.iftarSafety,
        );
      case PdfColumn.maghrib:
        return _shortTime(row.times.maghrib);
      case PdfColumn.isha:
        return _shortTime(row.times.isha);
      case PdfColumn.ishaMustahab:
        return _shortTime(row.times.ishaMustahab);
    }
  }

  String _dateCell(ClusterRow row) {
    final start = row.startDate;
    final end = row.endDate;

    final enLabel = row.isSingleDay
        ? '${start.day}'
        : '${start.day}–${end.day}';

    final bn = bangla.convert(start);
    final hn = hijri.toHijri(start);

    return '$enLabel\n'
        '${bangla.toBanglaDigits(bn.day)} / '
        '${bangla.toBanglaDigits(hn.hDay)}';
  }

  /// Sehri/Iftar cell — single time only. If safety is enabled,
  /// use the safety time; otherwise the actual time. No label.
  String _sehriIftarCell({
    required DateTime actual,
    required DateTime safety,
  }) {
    return _shortTime(
      options.showSafetyTimes ? safety : actual,
    );
  }

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
