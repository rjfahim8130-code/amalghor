class PrayerTimesModel {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime? solarNoon;
  final DateTime? suhoorEnd; // Usually same as fajr
  final DateTime? iftar; // Usually same as maghrib
  final DateTime? ishraq;
  final DateTime? tahajjudStart;
  final DateTime? lastThirdOfNight;

  PrayerTimesModel({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.solarNoon,
    this.suhoorEnd,
    this.iftar,
    this.ishraq,
    this.tahajjudStart,
    this.lastThirdOfNight,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'fajr': fajr.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'dhuhr': dhuhr.toIso8601String(),
      'asr': asr.toIso8601String(),
      'maghrib': maghrib.toIso8601String(),
      'isha': isha.toIso8601String(),
      'solarNoon': solarNoon?.toIso8601String(),
      'suhoorEnd': suhoorEnd?.toIso8601String(),
      'iftar': iftar?.toIso8601String(),
      'ishraq': ishraq?.toIso8601String(),
      'tahajjudStart': tahajjudStart?.toIso8601String(),
      'lastThirdOfNight': lastThirdOfNight?.toIso8601String(),
    };
  }

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    return PrayerTimesModel(
      date: DateTime.parse(json['date']),
      fajr: DateTime.parse(json['fajr']),
      sunrise: DateTime.parse(json['sunrise']),
      dhuhr: DateTime.parse(json['dhuhr']),
      asr: DateTime.parse(json['asr']),
      maghrib: DateTime.parse(json['maghrib']),
      isha: DateTime.parse(json['isha']),
      solarNoon: json['solarNoon'] != null ? DateTime.parse(json['solarNoon']) : null,
      suhoorEnd: json['suhoorEnd'] != null ? DateTime.parse(json['suhoorEnd']) : null,
      iftar: json['iftar'] != null ? DateTime.parse(json['iftar']) : null,
      ishraq: json['ishraq'] != null ? DateTime.parse(json['ishraq']) : null,
      tahajjudStart: json['tahajjudStart'] != null ? DateTime.parse(json['tahajjudStart']) : null,
      lastThirdOfNight: json['lastThirdOfNight'] != null ? DateTime.parse(json['lastThirdOfNight']) : null,
    );
  }
}

enum PrayerName {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
  solarNoon,
  suhoor,
  iftar,
}

extension PrayerNameExtension on PrayerName {
  String get bn {
    switch (this) {
      case PrayerName.fajr:
        return 'ফজর';
      case PrayerName.sunrise:
        return 'সূর্যোদয়';
      case PrayerName.dhuhr:
        return 'যোহর';
      case PrayerName.asr:
        return 'আসর';
      case PrayerName.maghrib:
        return 'মাগরিব';
      case PrayerName.isha:
        return 'এশা';
      case PrayerName.solarNoon:
        return 'মধ্য আকাশ';
      case PrayerName.suhoor:
        return 'সেহরি';
      case PrayerName.iftar:
        return 'ইফতার';
    }
  }

  String get en {
    switch (this) {
      case PrayerName.fajr:
        return 'Fajr';
      case PrayerName.sunrise:
        return 'Sunrise';
      case PrayerName.dhuhr:
        return 'Dhuhr';
      case PrayerName.asr:
        return 'Asr';
      case PrayerName.maghrib:
        return 'Maghrib';
      case PrayerName.isha:
        return 'Isha';
      case PrayerName.solarNoon:
        return 'Solar Noon';
      case PrayerName.suhoor:
        return 'Suhoor';
      case PrayerName.iftar:
        return 'Iftar';
    }
  }
}

class CurrentPrayerStatus {
  final PrayerName? currentPrayer;
  final PrayerName nextPrayer;
  final DateTime? currentEndTime;
  final DateTime nextStartTime;
  final Duration remaining;
  final bool isPrayerTime;
  final String statusBn;
  final String statusEn;

  CurrentPrayerStatus({
    this.currentPrayer,
    required this.nextPrayer,
    this.currentEndTime,
    required this.nextStartTime,
    required this.remaining,
    required this.isPrayerTime,
    required this.statusBn,
    required this.statusEn,
  });
}
