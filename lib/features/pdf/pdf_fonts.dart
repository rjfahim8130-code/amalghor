import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Loads and caches the three fonts used in the PDF:
///   - Inter (Latin)
///   - Noto Sans Bengali (Bangla)
///   - Noto Naskh Arabic (Arabic)
///
/// Fonts are read from assets/fonts/.
class PdfFonts {
  final pw.Font interRegular;
  final pw.Font interBold;
  final pw.Font notoBengaliRegular;
  final pw.Font notoBengaliBold;
  final pw.Font notoArabicRegular;
  final pw.Font notoArabicBold;

  const PdfFonts({
    required this.interRegular,
    required this.interBold,
    required this.notoBengaliRegular,
    required this.notoBengaliBold,
    required this.notoArabicRegular,
    required this.notoArabicBold,
  });

  /// Build the [pw.ThemeData] used by every generated document.
  pw.ThemeData get theme => pw.ThemeData.withFont(
        base: interRegular,
        bold: interBold,
        fontFallback: [
          notoBengaliRegular,
          notoBengaliBold,
          notoArabicRegular,
          notoArabicBold,
        ],
      );

  static Future<PdfFonts> load() async {
    final interRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter_18pt-Regular.ttf'),
    );
    final interBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter_18pt-Bold.ttf'),
    );
    final notoBengaliRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf'),
    );
    final notoBengaliBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansBengali-Bold.ttf'),
    );
    final notoArabicRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'),
    );
    final notoArabicBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoNaskhArabic-Bold.ttf'),
    );

    return PdfFonts(
      interRegular: interRegular,
      interBold: interBold,
      notoBengaliRegular: notoBengaliRegular,
      notoBengaliBold: notoBengaliBold,
      notoArabicRegular: notoArabicRegular,
      notoArabicBold: notoArabicBold,
    );
  }
}
