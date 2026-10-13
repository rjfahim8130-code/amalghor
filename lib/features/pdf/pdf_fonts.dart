import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Loads and caches the fonts used in the PDF.
///
/// Bangla rendering uses NotoSansBengali — it has full conjunct
/// coverage (যুক্তাক্ষর) when embedded properly. We do NOT use
/// Kalpurush here because its PDF rendering via the `pdf` package
/// breaks ligatures for many yuktakkhors.
///
/// Arabic rendering uses NotoNaskhArabic which has full shaping
/// support.
class PdfFonts {
  final pw.Font latinRegular;
  final pw.Font latinBold;
  final pw.Font banglaRegular;
  final pw.Font banglaBold;
  final pw.Font arabicRegular;
  final pw.Font arabicBold;

  const PdfFonts({
    required this.latinRegular,
    required this.latinBold,
    required this.banglaRegular,
    required this.banglaBold,
    required this.arabicRegular,
    required this.arabicBold,
  });

  /// Theme data used by every generated PDF.
  ///
  /// Falls back to Bangla for text that has no Latin glyph, and to
  /// Arabic for text that has no Latin or Bangla glyph.
  pw.ThemeData get theme => pw.ThemeData.withFont(
        base: latinRegular,
        bold: latinBold,
        italic: latinRegular,
        boldItalic: latinBold,
        fontFallback: [
          banglaRegular,
          banglaBold,
          arabicRegular,
          arabicBold,
        ],
      );

  static Future<PdfFonts> load() async {
    final latinRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter_18pt-Regular.ttf'),
    );
    final latinBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter_18pt-Bold.ttf'),
    );
    final banglaRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf'),
    );
    final banglaBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansBengali-Bold.ttf'),
    );
    final arabicRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'),
    );
    final arabicBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoNaskhArabic-Bold.ttf'),
    );

    return PdfFonts(
      latinRegular: latinRegular,
      latinBold: latinBold,
      banglaRegular: banglaRegular,
      banglaBold: banglaBold,
      arabicRegular: arabicRegular,
      arabicBold: arabicBold,
    );
  }
}
