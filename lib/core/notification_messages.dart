/// Central repository for all notification message strings.
///
/// Every message has a Title (with emoji) and a Body (with emoji).
/// Emoji rules:
///   - One emoji in the title.
///   - One or two emojis in the body (max).
///   - No faces, eyes, hands, or human gestures.
///
/// Localization:
///   Pass `locale` = 'en' or 'bn' to get the matching language.
///   Arabic UI is not supported — only English + Bangla.
class NotificationMessages {
  NotificationMessages._();

  // ─────────────────────────────────────────────
  // PRAYER REMINDERS
  // ─────────────────────────────────────────────

  /// Get (title, body) for a given prayer and offset.
  ///
  /// [prayerKey] — one of: fajr, dhuhr, asr, maghrib, isha
  /// [offsetMinutes] — 0 = at the time, 10 = 10 min before, 5 = 5 min before,
  ///                  negative = after the time
  /// [locale] — 'en' or 'bn' (defaults to 'bn')
  static ({String title, String body}) prayer({
    required String prayerKey,
    required int offsetMinutes,
    String locale = 'bn',
  }) {
    switch (prayerKey) {
      case 'fajr':
        return _fajr(offsetMinutes, locale);
      case 'dhuhr':
        return _dhuhr(offsetMinutes, locale);
      case 'asr':
        return _asr(offsetMinutes, locale);
      case 'maghrib':
        return _maghrib(offsetMinutes, locale);
      case 'isha':
        return _isha(offsetMinutes, locale);
      default:
        if (locale == 'en') {
          return (
            title: '🕌 Prayer',
            body: 'It is time for prayer. Please pray. 🕌',
          );
        }
        return (
          title: '🕌 নামায',
          body: 'নামাযের সময় হয়েছে। নামায আদায় করুন। 🕌',
        );
    }
  }

  static ({String title, String body}) _fajr(int offset, String locale) {
    final isEn = locale == 'en';
    final name = isEn ? 'Fajr' : 'ফজর';
    const emoji = '🌅';
    if (offset == 0) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Fajr time has begun. Prepare for prayer. 🕌'
            : 'ফজরের ওয়াক্ত শুরু হয়েছে। নামাযের প্রস্তুতি নিন। 🕌',
      );
    }
    if (offset >= 10) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Fajr begins in $offset minutes. ✨'
            : 'আর মাত্র $offset মিনিট পর ফজরের ওয়াক্ত শুরু হবে। ✨',
      );
    }
    if (offset > 0) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Only $offset minutes left until Fajr. 🌸'
            : 'ফজরের ওয়াক্ত শুরু হতে আর মাত্র $offset মিনিট বাকি। 🌸',
      );
    }
    return (
      title: '$emoji $name',
      body: isEn
          ? 'Fajr began ${-offset} minutes ago. Please pray. 🕌'
          : 'ফজরের ওয়াক্ত শুরু হয়েছে ${-offset} মিনিট আগে। নামায আদায় করুন। 🕌',
    );
  }

  static ({String title, String body}) _dhuhr(int offset, String locale) {
    final isEn = locale == 'en';
    final name = isEn ? 'Dhuhr' : 'যোহর';
    const emoji = '☀️';
    if (offset == 0) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Dhuhr time has begun. Prepare for prayer. 🕌'
            : 'যোহরের ওয়াক্ত শুরু হয়েছে। নামায আদায়ের প্রস্তুতি নিন। 🕌',
      );
    }
    if (offset >= 10) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Dhuhr begins in $offset minutes. ✨'
            : 'আর মাত্র $offset মিনিট পর যোহরের ওয়াক্ত শুরু হবে। ✨',
      );
    }
    if (offset > 0) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Only $offset minutes left until Dhuhr. 🌸'
            : 'যোহরের ওয়াক্ত শুরু হতে আর মাত্র $offset মিনিট বাকি। 🌸',
      );
    }
    return (
      title: '$emoji $name',
      body: isEn
          ? 'Dhuhr began ${-offset} minutes ago. Please pray. 🕌'
          : 'যোহরের ওয়াক্ত শুরু হয়েছে ${-offset} মিনিট আগে। নামায আদায় করুন। 🕌',
    );
  }

  static ({String title, String body}) _asr(int offset, String locale) {
    final isEn = locale == 'en';
    final name = isEn ? 'Asr' : 'আসর';
    const emoji = '🌤️';
    if (offset == 0) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Asr time has begun. Prepare for prayer. 🕌'
            : 'আসরের ওয়াক্ত শুরু হয়েছে। নামাযের প্রস্তুতি নিন। 🕌',
      );
    }
    if (offset >= 10) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Asr begins in $offset minutes. ✨'
            : 'আর মাত্র $offset মিনিট পর আসরের ওয়াক্ত শুরু হবে। ✨',
      );
    }
    if (offset > 0) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Only $offset minutes left until Asr. 🌸'
            : 'আসরের ওয়াক্ত শুরু হতে আর মাত্র $offset মিনিট বাকি। 🌸',
      );
    }
    return (
      title: '$emoji $name',
      body: isEn
          ? 'Asr began ${-offset} minutes ago. Please pray. 🕌'
          : 'আসরের ওয়াক্ত শুরু হয়েছে ${-offset} মিনিট আগে। নামায আদায় করুন। 🕌',
    );
  }

  static ({String title, String body}) _maghrib(int offset, String locale) {
    final isEn = locale == 'en';
    final name = isEn ? 'Maghrib' : 'মাগরিব';
    const emoji = '🌇';
    if (offset == 0) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Maghrib time has begun. Please pray. 🕌'
            : 'মাগরিবের ওয়াক্ত শুরু হয়েছে। নামায আদায় করুন। 🕌',
      );
    }
    if (offset >= 10) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Maghrib begins in $offset minutes. ✨'
            : 'আর মাত্র $offset মিনিট পর মাগরিবের ওয়াক্ত শুরু হবে। ✨',
      );
    }
    if (offset > 0) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Only $offset minutes left until Maghrib. 🌸'
            : 'মাগরিবের ওয়াক্ত শুরু হতে আর মাত্র $offset মিনিট বাকি। 🌸',
      );
    }
    return (
      title: '$emoji $name',
      body: isEn
          ? 'Maghrib began ${-offset} minutes ago. Please pray. 🕌'
          : 'মাগরিবের ওয়াক্ত শুরু হয়েছে ${-offset} মিনিট আগে। নামায আদায় করুন। 🕌',
    );
  }

  static ({String title, String body}) _isha(int offset, String locale) {
    final isEn = locale == 'en';
    final name = isEn ? 'Isha' : 'এশা';
    const emoji = '🌙';
    if (offset == 0) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Isha time has begun. Prepare for prayer. 🕌'
            : 'এশার ওয়াক্ত শুরু হয়েছে। নামায আদায়ের প্রস্তুতি নিন। 🕌',
      );
    }
    if (offset >= 10) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Isha begins in $offset minutes. ✨'
            : 'আর মাত্র $offset মিনিট পর এশার ওয়াক্ত শুরু হবে। ✨',
      );
    }
    if (offset > 0) {
      return (
        title: '$emoji $name',
        body: isEn
            ? 'Only $offset minutes left until Isha. 🌸'
            : 'এশার ওয়াক্ত শুরু হতে আর মাত্র $offset মিনিট বাকি। 🌸',
      );
    }
    return (
      title: '$emoji $name',
      body: isEn
          ? 'Isha began ${-offset} minutes ago. Please pray. 🕌'
          : 'এশার ওয়াক্ত শুরু হয়েছে ${-offset} মিনিট আগে। নামায আদায় করুন। 🕌',
    );
  }

  // ─────────────────────────────────────────────
  // SEHRI END
  // ─────────────────────────────────────────────

  static ({String title, String body}) sehri(
    int offset, {
    String locale = 'bn',
  }) {
    final isEn = locale == 'en';
    if (offset <= 0) {
      return (
        title: isEn ? '🌅 Sehri ended' : '🌅 সেহরির সময় শেষ',
        body: isEn
            ? 'The Sehri time has ended. 🌙'
            : 'সেহরির নির্ধারিত সময় শেষ হয়েছে। 🌙',
      );
    }
    if (offset >= 20) {
      return (
        title: isEn ? '🥣 Sehri ends' : '🥣 সেহরি শেষ',
        body: isEn
            ? 'Only $offset minutes left for Sehri. Watch the time. 🌙'
            : 'সেহরির জন্য হাতে আছে আর মাত্র $offset মিনিট। সময়ের প্রতি খেয়াল রাখুন। 🌙',
      );
    }
    if (offset >= 15) {
      return (
        title: isEn ? '🥣 Sehri ends' : '🥣 সেহরি শেষ',
        body: isEn
            ? 'Only $offset minutes left until Sehri ends. Please finish quickly. 🌙'
            : 'সেহরির সময় শেষ হতে আর মাত্র $offset মিনিট বাকি। দ্রুত সেহরি সম্পন্ন করুন। 🌙',
      );
    }
    return (
      title: isEn ? '🥣 Sehri ends' : '🥣 সেহরি শেষ',
      body: isEn
          ? 'Only $offset minutes left until Sehri ends. ✨'
          : 'সেহরির সময় শেষ হতে আর মাত্র $offset মিনিট বাকি। ✨',
    );
  }

  // ─────────────────────────────────────────────
  // IFTAR
  // ─────────────────────────────────────────────

  static ({String title, String body}) iftar(
    int offset, {
    String locale = 'bn',
  }) {
    final isEn = locale == 'en';
    if (offset <= 0) {
      return (
        title: isEn ? '🌙 Iftar time' : '🌙 ইফতারের সময়',
        body: isEn
            ? 'Iftar time has arrived. May Allah accept your fast. 🤍'
            : 'ইফতারের সময় হয়েছে। আল্লাহ আপনার রোজা কবুল করুন। 🤍',
      );
    }
    if (offset >= 15) {
      return (
        title: isEn ? '🌙 Iftar' : '🌙 ইফতার',
        body: isEn
            ? 'Only $offset minutes left until Iftar. 🌸'
            : 'ইফতারের আর মাত্র $offset মিনিট বাকি। 🌸',
      );
    }
    if (offset >= 10) {
      return (
        title: isEn ? '🌙 Iftar' : '🌙 ইফতার',
        body: isEn
            ? 'Only $offset minutes left until Iftar. Get ready. ✨'
            : 'ইফতারের সময় হতে আর মাত্র $offset মিনিট বাকি। প্রস্তুতি নিয়ে নিন। ✨',
      );
    }
    return (
      title: isEn ? '🌙 Iftar' : '🌙 ইফতার',
      body: isEn
          ? 'Only $offset minutes left! Prepare for Iftar. 🥣'
          : 'আর মাত্র $offset মিনিট! ইফতারের প্রস্তুতি সম্পন্ন করুন। 🥣',
    );
  }

  // ─────────────────────────────────────────────
  // TAHAJJUD
  // ─────────────────────────────────────────────

  static ({String title, String body}) tahajjud(
    int offset, {
    String locale = 'bn',
  }) {
    final isEn = locale == 'en';
    if (offset <= 0) {
      return (
        title: isEn ? '🌌 Tahajjud' : '🌌 তাহাজ্জুদ',
        body: isEn
            ? 'The last third of the night has begun. Make time for Tahajjud and Dua. ✨'
            : 'রাতের শেষ তৃতীয়াংশ শুরু হয়েছে। তাহাজ্জুদ ও দুআর জন্য সময় বের করুন। ✨',
      );
    }
    if (offset >= 10) {
      return (
        title: isEn ? '🌌 Tahajjud' : '🌌 তাহাজ্জুদ',
        body: isEn
            ? 'Tahajjud begins in $offset minutes. 🌙'
            : 'তাহাজ্জুদের সময় শুরু হতে আর মাত্র $offset মিনিট বাকি। 🌙',
      );
    }
    return (
      title: isEn ? '🌌 Tahajjud' : '🌌 তাহাজ্জুদ',
      body: isEn
          ? 'In $offset minutes the Tahajjud window begins. 🕌'
          : 'আর মাত্র $offset মিনিট পর তাহাজ্জুদের নির্ধারিত সময় শুরু হবে। 🕌',
    );
  }

  // ─────────────────────────────────────────────
  // LABELS (for settings UI)
  // ─────────────────────────────────────────────

  static String labelFor(String key, {String locale = 'bn'}) {
    final isEn = locale == 'en';
    switch (key) {
      case 'fajr':
        return isEn ? 'Fajr' : 'ফজর';
      case 'dhuhr':
        return isEn ? 'Dhuhr' : 'যোহর';
      case 'asr':
        return isEn ? 'Asr' : 'আসর';
      case 'maghrib':
        return isEn ? 'Maghrib' : 'মাগরিব';
      case 'isha':
        return isEn ? 'Isha' : 'এশা';
      case 'sehri':
        return isEn ? 'Sehri ends' : 'সেহরি শেষ';
      case 'iftar':
        return isEn ? 'Iftar' : 'ইফতার';
      case 'tahajjud':
        return isEn ? 'Tahajjud' : 'তাহাজ্জুদ';
      default:
        return key;
    }
  }

  static String emojiFor(String key) {
    switch (key) {
      case 'fajr':
        return '🌅';
      case 'dhuhr':
        return '☀️';
      case 'asr':
        return '🌤️';
      case 'maghrib':
        return '🌇';
      case 'isha':
        return '🌙';
      case 'sehri':
        return '🥣';
      case 'iftar':
        return '🌙';
      case 'tahajjud':
        return '🌌';
      default:
        return '🕌';
    }
  }
}
