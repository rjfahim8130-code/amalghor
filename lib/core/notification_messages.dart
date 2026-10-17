/// Central repository for all notification message strings.
///
/// Every message has a Title (with emoji) and a Body (with emoji).
/// Emoji rules:
///   - One emoji in the title.
///   - One or two emojis in the body (max).
///   - No faces, eyes, hands, or human gestures.
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
  static ({String title, String body}) prayer({
    required String prayerKey,
    required int offsetMinutes,
  }) {
    switch (prayerKey) {
      case 'fajr':
        return _fajr(offsetMinutes);
      case 'dhuhr':
        return _dhuhr(offsetMinutes);
      case 'asr':
        return _asr(offsetMinutes);
      case 'maghrib':
        return _maghrib(offsetMinutes);
      case 'isha':
        return _isha(offsetMinutes);
      default:
        return (
          title: '🕌 নামায',
          body: 'নামাযের সময় হয়েছে। নামায আদায় করুন। 🕌',
        );
    }
  }

  static ({String title, String body}) _fajr(int offset) {
    if (offset == 0) {
      return (
        title: '🌅 ফজর',
        body: 'ফজরের ওয়াক্ত শুরু হয়েছে। নামাযের প্রস্তুতি নিন। 🕌',
      );
    }
    if (offset >= 10) {
      return (
        title: '🌅 ফজর',
        body: 'আর মাত্র $offset মিনিট পর ফজরের ওয়াক্ত শুরু হবে। ✨',
      );
    }
    if (offset > 0) {
      return (
        title: '🌅 ফজর',
        body: 'ফজরের ওয়াক্ত শুরু হতে আর মাত্র $offset মিনিট বাকি। 🌸',
      );
    }
    return (
      title: '🌅 ফজর',
      body: 'ফজরের ওয়াক্ত শুরু হয়েছে ${-offset} মিনিট আগে। নামায আদায় করুন। 🕌',
    );
  }

  static ({String title, String body}) _dhuhr(int offset) {
    if (offset == 0) {
      return (
        title: '☀️ যোহর',
        body: 'যোহরের ওয়াক্ত শুরু হয়েছে। নামায আদায়ের প্রস্তুতি নিন। 🕌',
      );
    }
    if (offset >= 10) {
      return (
        title: '☀️ যোহর',
        body: 'আর মাত্র $offset মিনিট পর যোহরের ওয়াক্ত শুরু হবে। ✨',
      );
    }
    if (offset > 0) {
      return (
        title: '☀️ যোহর',
        body: 'যোহরের ওয়াক্ত শুরু হতে আর মাত্র $offset মিনিট বাকি। 🌸',
      );
    }
    return (
      title: '☀️ যোহর',
      body: 'যোহরের ওয়াক্ত শুরু হয়েছে ${-offset} মিনিট আগে। নামায আদায় করুন। 🕌',
    );
  }

  static ({String title, String body}) _asr(int offset) {
    if (offset == 0) {
      return (
        title: '🌤️ আসর',
        body: 'আসরের ওয়াক্ত শুরু হয়েছে। নামাযের প্রস্তুতি নিন। 🕌',
      );
    }
    if (offset >= 10) {
      return (
        title: '🌤️ আসর',
        body: 'আর মাত্র $offset মিনিট পর আসরের ওয়াক্ত শুরু হবে। ✨',
      );
    }
    if (offset > 0) {
      return (
        title: '🌤️ আসর',
        body: 'আসরের ওয়াক্ত শুরু হতে আর মাত্র $offset মিনিট বাকি। 🌸',
      );
    }
    return (
      title: '🌤️ আসর',
      body: 'আসরের ওয়াক্ত শুরু হয়েছে ${-offset} মিনিট আগে। নামায আদায় করুন। 🕌',
    );
  }

  static ({String title, String body}) _maghrib(int offset) {
    if (offset == 0) {
      return (
        title: '🌇 মাগরিব',
        body: 'মাগরিবের ওয়াক্ত শুরু হয়েছে। নামায আদায় করুন। 🕌',
      );
    }
    if (offset >= 10) {
      return (
        title: '🌇 মাগরিব',
        body: 'আর মাত্র $offset মিনিট পর মাগরিবের ওয়াক্ত শুরু হবে। ✨',
      );
    }
    if (offset > 0) {
      return (
        title: '🌇 মাগরিব',
        body: 'মাগরিবের ওয়াক্ত শুরু হতে আর মাত্র $offset মিনিট বাকি। 🌸',
      );
    }
    return (
      title: '🌇 মাগরিব',
      body: 'মাগরিবের ওয়াক্ত শুরু হয়েছে ${-offset} মিনিট আগে। নামায আদায় করুন। 🕌',
    );
  }

  static ({String title, String body}) _isha(int offset) {
    if (offset == 0) {
      return (
        title: '🌙 এশা',
        body: 'এশার ওয়াক্ত শুরু হয়েছে। নামায আদায়ের প্রস্তুতি নিন। 🕌',
      );
    }
    if (offset >= 10) {
      return (
        title: '🌙 এশা',
        body: 'আর মাত্র $offset মিনিট পর এশার ওয়াক্ত শুরু হবে। ✨',
      );
    }
    if (offset > 0) {
      return (
        title: '🌙 এশা',
        body: 'এশার ওয়াক্ত শুরু হতে আর মাত্র $offset মিনিট বাকি। 🌸',
      );
    }
    return (
      title: '🌙 এশা',
      body: 'এশার ওয়াক্ত শুরু হয়েছে ${-offset} মিনিট আগে। নামায আদায় করুন। 🕌',
    );
  }

  // ─────────────────────────────────────────────
  // SEHRI END
  // ─────────────────────────────────────────────

  static ({String title, String body}) sehri(int offset) {
    if (offset <= 0) {
      return (
        title: '🌅 সেহরির সময় শেষ',
        body: 'সেহরির নির্ধারিত সময় শেষ হয়েছে। 🌙',
      );
    }
    if (offset >= 20) {
      return (
        title: '🥣 সেহরি শেষ',
        body:
            'সেহরির জন্য হাতে আছে আর মাত্র $offset মিনিট। সময়ের প্রতি খেয়াল রাখুন। 🌙',
      );
    }
    if (offset >= 15) {
      return (
        title: '🥣 সেহরি শেষ',
        body:
            'সেহরির সময় শেষ হতে আর মাত্র $offset মিনিট বাকি। দ্রুত সেহরি সম্পন্ন করুন। 🌙',
      );
    }
    return (
      title: '🥣 সেহরি শেষ',
      body: 'সেহরির সময় শেষ হতে আর মাত্র $offset মিনিট বাকি। ✨',
    );
  }

  // ─────────────────────────────────────────────
  // IFTAR
  // ─────────────────────────────────────────────

  static ({String title, String body}) iftar(int offset) {
    if (offset <= 0) {
      return (
        title: '🌙 ইফতারের সময়',
        body: 'ইফতারের সময় হয়েছে। আল্লাহ আপনার রোজা কবুল করুন। 🤍',
      );
    }
    if (offset >= 15) {
      return (
        title: '🌙 ইফতার',
        body: 'ইফতারের আর মাত্র $offset মিনিট বাকি। 🌸',
      );
    }
    if (offset >= 10) {
      return (
        title: '🌙 ইফতার',
        body:
            'ইফতারের সময় হতে আর মাত্র $offset মিনিট বাকি। প্রস্তুতি নিয়ে নিন। ✨',
      );
    }
    return (
      title: '🌙 ইফতার',
      body: 'আর মাত্র $offset মিনিট! ইফতারের প্রস্তুতি সম্পন্ন করুন। 🥣',
    );
  }

  // ─────────────────────────────────────────────
  // TAHAJJUD
  // ─────────────────────────────────────────────

  static ({String title, String body}) tahajjud(int offset) {
    if (offset <= 0) {
      return (
        title: '🌌 তাহাজ্জুদ',
        body:
            'রাতের শেষ তৃতীয়াংশ শুরু হয়েছে। তাহাজ্জুদ ও দুআর জন্য সময় বের করুন। ✨',
      );
    }
    if (offset >= 10) {
      return (
        title: '🌌 তাহাজ্জুদ',
        body: 'তাহাজ্জুদের সময় শুরু হতে আর মাত্র $offset মিনিট বাকি। 🌙',
      );
    }
    return (
      title: '🌌 তাহাজ্জুদ',
      body:
          'আর মাত্র $offset মিনিট পর তাহাজ্জুদের নির্ধারিত সময় শুরু হবে। 🕌',
    );
  }

  // ─────────────────────────────────────────────
  // LABELS (for settings UI)
  // ─────────────────────────────────────────────

  static String labelFor(String key) {
    switch (key) {
      case 'fajr':
        return 'ফজর';
      case 'dhuhr':
        return 'যোহর';
      case 'asr':
        return 'আসর';
      case 'maghrib':
        return 'মাগরিব';
      case 'isha':
        return 'এশা';
      case 'sehri':
        return 'সেহরি শেষ';
      case 'iftar':
        return 'ইফতার';
      case 'tahajjud':
        return 'তাহাজ্জুদ';
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
