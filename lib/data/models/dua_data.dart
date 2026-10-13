import 'dua_models.dart';

/// Static catalogue of duas organized by category.
class DuaData {
  DuaData._();

  // ─────────────────────────────────────────────
  // CATEGORIES
  // ─────────────────────────────────────────────

  static const List<DuaCategory> categories = [
    DuaCategory(
      id: 'morning',
      titleEn: 'Morning',
      titleBn: 'সকালের দুআ',
      titleAr: 'الصباح',
      emoji: '🌅',
      colorValue: 0xFFF59E0B,
    ),
    DuaCategory(
      id: 'evening',
      titleEn: 'Evening',
      titleBn: 'সন্ধ্যার দুআ',
      titleAr: 'المساء',
      emoji: '🌙',
      colorValue: 0xFF3B82F6,
    ),
    DuaCategory(
      id: 'sleep',
      titleEn: 'Before Sleep',
      titleBn: 'ঘুমানোর আগে',
      titleAr: 'قبل النوم',
      emoji: '🛏️',
      colorValue: 0xFF8B5CF6,
    ),
    DuaCategory(
      id: 'wake',
      titleEn: 'On Waking',
      titleBn: 'ঘুম থেকে উঠে',
      titleAr: 'عند الاستيقاظ',
      emoji: '☀️',
      colorValue: 0xFF06B6D4,
    ),
    DuaCategory(
      id: 'food',
      titleEn: 'Eating',
      titleBn: 'খাবার',
      titleAr: 'الطعام',
      emoji: '🍽️',
      colorValue: 0xFF10B981,
    ),
    DuaCategory(
      id: 'travel',
      titleEn: 'Travel',
      titleBn: 'ভ্রমণ',
      titleAr: 'السفر',
      emoji: '✈️',
      colorValue: 0xFFEF4444,
    ),
    DuaCategory(
      id: 'distress',
      titleEn: 'Distress',
      titleBn: 'বিপদে',
      titleAr: 'الكرب',
      emoji: '🤲',
      colorValue: 0xFFA855F7,
    ),
  ];

  // ─────────────────────────────────────────────
  // DUAS
  // ─────────────────────────────────────────────

  static const List<Dua> all = [
    // ═══════════════ MORNING ═══════════════
    Dua(
      id: 'morning_1',
      categoryId: 'morning',
      titleEn: 'When you wake up',
      titleBn: 'ঘুম থেকে উঠে',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      transliteration:
          'Alhamdulillahil-ladhi ahyana ba\'da ma amatana wa ilayhin-nushur',
      meaningEn:
          'All praise is for Allah who gave us life after having taken it from us, and unto Him is the resurrection.',
      meaningBn:
          'সমস্ত প্রশংসা আল্লাহর, যিনি আমাদের মৃত্যুর পর জীবিত করেছেন এবং তাঁর কাছেই ফিরে যেতে হবে।',
      reference: 'Bukhari',
    ),
    Dua(
      id: 'morning_2',
      categoryId: 'morning',
      titleEn: 'Morning remembrance',
      titleBn: 'সকালের যিকির',
      arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ',
      transliteration: 'Asbahna wa asbahal-mulku lillah, wal-hamdulillah',
      meaningEn:
          'We have entered the morning, and the dominion belongs to Allah, and all praise is for Allah.',
      meaningBn:
          'আমরা সকালে প্রবেশ করলাম এবং সমস্ত রাজত্ব আল্লাহর, সমস্ত প্রশংসা আল্লাহর।',
      reference: 'Muslim',
    ),
    Dua(
      id: 'morning_3',
      categoryId: 'morning',
      titleEn: 'Protection in the morning',
      titleBn: 'সকালের হেফাজত',
      arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      transliteration:
          'Bismillahil-ladhi la yadurru ma\'asmihi shay\'un fil-ardi wa la fis-sama\'i wa huwas-sami\'ul-\'alim',
      meaningEn:
          'In the name of Allah, with whose name nothing on earth or in heaven can cause harm. And He is the All-Hearing, All-Knowing.',
      meaningBn:
          'আল্লাহর নামে, যাঁর নামে কিছুই পৃথিবীতে বা আসমানে ক্ষতি করতে পারে না। তিনি সর্বশ্রোতা, সর্বজ্ঞ।',
      reference: 'Abu Dawud, Tirmidhi',
    ),

    // ═══════════════ EVENING ═══════════════
    Dua(
      id: 'evening_1',
      categoryId: 'evening',
      titleEn: 'Evening remembrance',
      titleBn: 'সন্ধ্যার যিকির',
      arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ',
      transliteration: 'Amsayna wa amsal-mulku lillah, wal-hamdulillah',
      meaningEn:
          'We have entered the evening, and the dominion belongs to Allah, and all praise is for Allah.',
      meaningBn:
          'আমরা সন্ধ্যায় প্রবেশ করলাম এবং সমস্ত রাজত্ব আল্লাহর, সমস্ত প্রশংসা আল্লাহর।',
      reference: 'Muslim',
    ),
    Dua(
      id: 'evening_2',
      categoryId: 'evening',
      titleEn: 'Seeking refuge in Allah',
      titleBn: 'আল্লাহর আশ্রয় প্রার্থনা',
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      transliteration: 'A\'udhu bikalimatillahit-tammati min sharri ma khalaq',
      meaningEn:
          'I seek refuge in the perfect words of Allah from the evil of what He has created.',
      meaningBn:
          'আমি আল্লাহর পূর্ণ কালেমাসমূহের মাধ্যমে তাঁর সৃষ্টির অনিষ্ট থেকে আশ্রয় চাই।',
      reference: 'Muslim',
    ),

        // ═══════════════ SLEEP ═══════════════
    Dua(
      id: 'sleep_1',
      categoryId: 'sleep',
      titleEn: 'Before going to sleep',
      titleBn: 'ঘুমানোর আগে',
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      transliteration: 'Bismika Allahumma amutu wa ahya',
      meaningEn: 'In Your name, O Allah, I die and I live.',
      meaningBn: 'হে আল্লাহ, আপনার নামেই আমি মরি এবং জীবিত হই।',
      reference: 'Bukhari',
    ),
    Dua(
      id: 'sleep_2',
      categoryId: 'sleep',
      titleEn: 'Ayat al-Kursi before sleep',
      titleBn: 'ঘুমানোর আগে আয়াতুল কুরসি',
      arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ',
      transliteration:
          'Allahu la ilaha illa huwal-hayyul-qayyum, la ta\'khudhuhu sinatun wa la nawm',
      meaningEn:
          'Allah — there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep.',
      meaningBn:
          'আল্লাহ, তিনি ছাড়া কোনো ইলাহ নেই। তিনি চিরঞ্জীব, সবকিছুর ধারক। তন্দ্রা বা নিদ্রা তাঁকে স্পর্শ করে না।',
      reference: 'Quran 2:255',
    ),

    // ═══════════════ WAKE ═══════════════
    Dua(
      id: 'wake_1',
      categoryId: 'wake',
      titleEn: 'On waking up',
      titleBn: 'ঘুম থেকে উঠে',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      transliteration:
          'Alhamdulillahil-ladhi ahyana ba\'da ma amatana wa ilayhin-nushur',
      meaningEn:
          'All praise is for Allah who gave us life after having taken it from us, and unto Him is the return.',
      meaningBn:
          'সমস্ত প্রশংসা আল্লাহর, যিনি আমাদের মৃত্যুর পর জীবিত করেছেন এবং তাঁর কাছেই ফিরে যেতে হবে।',
      reference: 'Bukhari',
    ),

    // ═══════════════ FOOD ═══════════════
    Dua(
      id: 'food_before',
      categoryId: 'food',
      titleEn: 'Before eating',
      titleBn: 'খাওয়ার আগে',
      arabic: 'بِسْمِ اللَّهِ',
      transliteration: 'Bismillah',
      meaningEn: 'In the name of Allah.',
      meaningBn: 'আল্লাহর নামে।',
      reference: 'Abu Dawud, Tirmidhi',
    ),
    Dua(
      id: 'food_after',
      categoryId: 'food',
      titleEn: 'After eating',
      titleBn: 'খাওয়ার পরে',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
      transliteration:
          'Alhamdulillahil-ladhi at\'amana wa saqana wa ja\'alana muslimin',
      meaningEn:
          'All praise is for Allah who fed us, gave us drink, and made us Muslims.',
      meaningBn:
          'সমস্ত প্রশংসা আল্লাহর, যিনি আমাদের খাওয়ালেন, পান করালেন এবং মুসলিম বানালেন।',
      reference: 'Abu Dawud, Tirmidhi',
    ),

    // ═══════════════ TRAVEL ═══════════════
    Dua(
      id: 'travel_1',
      categoryId: 'travel',
      titleEn: 'Before starting a journey',
      titleBn: 'সফরের শুরুতে',
      arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
      transliteration:
          'Subhanal-ladhi sakhkhara lana hadha wa ma kunna lahu muqrinin, wa inna ila Rabbina lamunqalibun',
      meaningEn:
          'Glory to Him who has subjected this to us, and we could never have it by our efforts. And indeed, to our Lord we will return.',
      meaningBn:
          'পবিত্র সেই সত্তা, যিনি এটাকে আমাদের বশীভূত করে দিয়েছেন, অথচ আমরা এটাকে বশীভূত করতে সক্ষম ছিলাম না। আর নিশ্চয়ই আমরা আমাদের প্রতিপালকের কাছে ফিরে যাব।',
      reference: 'Quran 43:13-14, Muslim',
    ),
    Dua(
      id: 'travel_2',
      categoryId: 'travel',
      titleEn: 'Entering a town',
      titleBn: 'শহরে প্রবেশের সময়',
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَهَا وَخَيْرَ أَهْلِهَا وَخَيْرَ مَا فِيهَا، وَأَعُوذُ بِكَ مِنْ شَرِّهَا وَشَرِّ أَهْلِهَا وَشَرِّ مَا فِيهَا',
      transliteration:
          'Allahumma inni as\'aluka khayraha wa khayra ahliha wa khayra ma fiha, wa a\'udhu bika min sharriha wa sharri ahliha wa sharri ma fiha',
      meaningEn:
          'O Allah, I ask You for its good, the good of its people, and the good in it. And I seek refuge in You from its evil, the evil of its people, and the evil in it.',
      meaningBn:
          'হে আল্লাহ, আমি আপনার কাছে এর কল্যাণ, এর অধিবাসীদের কল্যাণ এবং এতে যা আছে তার কল্যাণ প্রার্থনা করি। আর আমি আপনার কাছে এর অনিষ্ট, এর অধিবাসীদের অনিষ্ট এবং এতে যা আছে তার অনিষ্ট থেকে আশ্রয় চাই।',
      reference: 'Hakim',
    ),

    // ═══════════════ DISTRESS ═══════════════
    Dua(
      id: 'distress_1',
      categoryId: 'distress',
      titleEn: 'When in distress',
      titleBn: 'বিপদে পড়লে',
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَٰهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ',
      transliteration:
          'La ilaha illallahul-\'Azimul-Halim, la ilaha illallahu Rabbul-\'Arshil-\'Azim',
      meaningEn:
          'There is no deity except Allah, the Mighty, the Forbearing. There is no deity except Allah, Lord of the Magnificent Throne.',
      meaningBn:
          'আল্লাহ ছাড়া কোনো ইলাহ নেই, যিনি মহান, সহনশীল। আল্লাহ ছাড়া কোনো ইলাহ নেই, যিনি মহান আরশের প্রতিপালক।',
      reference: 'Bukhari, Muslim',
    ),
    Dua(
      id: 'distress_2',
      categoryId: 'distress',
      titleEn: 'For anxiety and sorrow',
      titleBn: 'দুশ্চিন্তা ও দুঃখে',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ',
      transliteration:
          'Allahumma inni a\'udhu bika minal-hammi wal-hazan, wal-\'ajzi wal-kasal',
      meaningEn:
          'O Allah, I seek refuge in You from anxiety and sorrow, from weakness and laziness.',
      meaningBn:
          'হে আল্লাহ, আমি আপনার কাছে দুশ্চিন্তা ও দুঃখ, অক্ষমতা ও অলসতা থেকে আশ্রয় চাই।',
      reference: 'Bukhari',
    ),
    Dua(
      id: 'distress_3',
      categoryId: 'distress',
      titleEn: 'Seeking forgiveness abundantly',
      titleBn: 'বেশি বেশি ক্ষমা প্রার্থনা',
      arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      transliteration: 'Astaghfirullaha wa atubu ilayh',
      meaningEn: 'I seek forgiveness from Allah and turn to Him in repentance.',
      meaningBn: 'আমি আল্লাহর কাছে ক্ষমা চাই এবং তাঁর কাছে তাওবা করি।',
      reference: 'Bukhari, Muslim',
    ),
  ];
}
