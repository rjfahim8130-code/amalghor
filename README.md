# আমলঘর (Amalghor) v1.0

**Live Islamic Time Dashboard + Location-Based Prayer Calendar PDF Generator**

## Features (V1)

- Live Home Dashboard with real-time prayer status & countdown
- Accurate prayer times using Adhan library (all 4 Madhhabs)
- Solar Noon support
- Bangla + English + Hijri dates
- One-Click Full Year PDF Calendar (3 modes)
- Quran (basic structure)
- Amal Tracker
- Ramadan special status
- Fully offline, no backend, maximum privacy
- Bangla & English language support
- Dark AMOLED Islamic design

## Getting Started

### 1. Prerequisites
- Flutter SDK >= 3.2.0
- Android Studio / VS Code

### 2. Setup

```bash
git clone <your-repo-url>
cd amalghor
flutter pub get
```

### 3. Fonts (Important)

Download and place these fonts in `assets/fonts/`:

- `Kalpurush.ttf` (Bangla)
- `SolaimanLipi.ttf` (Bangla alternative)
- `Amiri-Regular.ttf` & `Amiri-Bold.ttf` (Arabic)

You can download:
- Kalpurush: from Google or free Bangla font sites
- Amiri: from Google Fonts

If fonts are missing, the app will still run using system/Google fonts fallback.

### 4. Run

```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   ├── models/
│   ├── services/      # Prayer calculation, Location, Settings
│   ├── theme/
│   └── utils/         # Bangla date converter
├── features/
│   ├── home/
│   ├── prayer/
│   ├── quran/
│   ├── ramadan/
│   ├── amal/
│   ├── settings/
│   └── pdf/
└── shared/
```

## Next Steps (to complete V1)

1. Full PDF generation with grouping algorithm (1min / 30sec)
2. Complete 114 Surahs + Bangla translation (JSON)
3. Notification system
4. App icon & splash screen
5. Better Bangla calendar accuracy

## Tech Stack

- Flutter
- Provider (state management)
- Adhan (prayer calculation)
- Geolocator
- SharedPreferences
- pdf + printing packages

---

Made with ❤️ for the Ummah
