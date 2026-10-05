class AppConstants {
  static const String appName = 'আমলঘর';
  static const String appNameEn = 'Amalghor';
  static const String appTagline = 'Live Islamic Time Dashboard + Prayer Calendar PDF';
  static const String appTaglineBn = 'লাইভ ইসলামিক টাইম ড্যাশবোর্ড + নামাজের ক্যালেন্ডার PDF';

  // Storage Keys
  static const String keyLanguage = 'language';
  static const String keyMadhhab = 'madhhab';
  static const String keyPrimaryCalendar = 'primary_calendar';
  static const String keyLocationLat = 'location_lat';
  static const String keyLocationLng = 'location_lng';
  static const String keyLocationName = 'location_name';
  static const String keyTimezone = 'timezone';
  static const String keyThemeMode = 'theme_mode';
  static const String keyPdfMode = 'pdf_mode';
  static const String keyNotifications = 'notifications';
  static const String keyFirstLaunch = 'first_launch';

  // Default Values
  static const double defaultLat = 23.8103; // Dhaka
  static const double defaultLng = 90.4125;
  static const String defaultLocationName = 'Dhaka, Bangladesh';
  static const String defaultTimezone = 'Asia/Dhaka';
}

enum AppLanguage { bangla, english }

enum Madhhab { hanafi, shafi, maliki, hanbali }

enum PrimaryCalendar { bangla, english, hijri }

enum PdfMode { full, oneMinute, thirtySecond }

enum ThemeModeOption { dark, light }
