# 🕌 আমলঘর (Amalghor)

**Offline Islamic Time Dashboard — Prayer Times, Tri-Calendar, Quran & Ramadan Tracker**

একটি সম্পূর্ণ অফলাইন, ব্যাকএন্ড-মুক্ত, প্রাইভেসি-সুরক্ষিত ইসলামিক অ্যাপ। কোনো সার্ভার নেই, কোনো লগইন নেই, কোনো ট্র্যাকিং নেই।

---

## ✨ বৈশিষ্ট্য

- 🕌 **Live Prayer Dashboard** — ১৩টি অ্যাস্ট্রোনমিক্যাল ইভেন্ট সহ
- ⏱️ **Live Clock** — প্রতি সেকেন্ডে আপডেট
- 📅 **Tri-Calendar** — ইংরেজি + বাংলা + হিজরি একসাথে
- 📄 **PDF Generator** — পুরো বছরের নামাযের সময়সূচি ক্লাস্টার করে
- 📖 **Quran Module** — ১১৪ সূরার ক্যাটালগ
- 🌙 **Ramadan Tracker** — সেহরি/ইফতার কাউন্টডাউন
- 🤲 **Daily Amol Tracker** — তাসবীহ, দুআ, যিকির
- 🌍 **3 Languages** — English / বাংলা / العربية
- 🔋 **AMOLED Dark Theme** — ব্যাটারি সাশ্রয়ী
- 📴 **100% Offline** — ইন্টারনেট ছাড়াই চলে

---

## 📦 যা যা লাগবে

| জিনিস | ভার্সন | কেন লাগবে |
|---|---|---|
| Flutter SDK | 3.24+ | অ্যাপ build করতে |
| Java JDK | 17 | Android compile |
| Git | যেকোনো | কোড push |
| GitHub Account | ফ্রি | Actions-এ build |
| Text Editor | VS Code / Cursor | কোড এডিট |

---

## 🚀 ধাপে ধাপে সেটআপ (বাংলায়)

### ধাপ ১: GitHub-এ Repository তৈরি

১. https://github.com/new এ যান
২. Repository name: **amalghor**
৩. **Public** রাখুন (Actions ফ্রি থাকবে)
৪. **Create repository** ক্লিক করুন

### ধাপ ২: ফাইলগুলো লোড করুন

**সহজ পথ (Web UI):**
১. Repository-তে **Add file → Upload files** ক্লিক করুন
২. সব ফাইল/ফোল্ডার drag-and-drop করুন (ফোল্ডার structure ঠিক রাখুন)
৩. Commit message: `Initial commit`
৪. **Commit changes** ক্লিক করুন

**Advanced পথ (Git CLI):**
```bash
git clone https://github.com/YOUR_USERNAME/amalghor.git
cd amalghor
# সব ফাইল এখানে রাখুন
git add .
git commit -m "Initial commit"
git push origin main
```

### ধাপ ৩: Fonts ডাউনলোড করুন

`assets/fonts/` ফোল্ডারে নিচের ফন্টগুলো রাখতে হবে:

| ফাইল | সোর্স |
|---|---|
| `Inter-Regular.ttf` | https://fonts.google.com/specimen/Inter |
| `Inter-SemiBold.ttf` | একই |
| `Inter-Bold.ttf` | একই |
| `Kalpurush.ttf` | https://www.omicronlab.com/bangla-fonts.html |
| `NotoNaskhArabic-Regular.ttf` | https://fonts.google.com/noto/specimen/Noto+Naskh+Arabic |
| `NotoNaskhArabic-Bold.ttf` | একই |
| `NotoSansBengali-Regular.ttf` | https://fonts.google.com/noto/specimen/Noto+Sans+Bengali |
| `NotoSansBengali-Bold.ttf` | একই |

### ধাপ ৪: GitHub Actions-এ Build

১. Repository-তে **Actions** tab-এ যান
২. প্রথমবার: **I understand my workflows, go ahead and enable them** ক্লিক করুন
৩. **Build Amalghor Release APK** workflow select করুন
৪. **Run workflow** → **Run workflow** ক্লিক করুন
৫. ৫-৭ মিনিট wait করুন (সবুজ ✅ আসবে)

### ধাপ ৫: APK Download ও Install

১. Workflow run-এ ক্লিক করুন
২. নিচে **Artifacts** সেকশনে **amalghor-apks** ডাউনলোড করুন
৩. `.zip` extract করুন — ৩টি APK পাবেন:
   - `app-arm64-v8a-release.apk` ← **এটা ফোনে use করুন**
   - `app-armeabi-v7a-release.apk` (পুরনো ফোন)
   - `app-x86_64-release.apk` (emulator)
৪. ফোনে APK transfer করে install করুন

---

## 🔐 Production Signing (Play Store-এর জন্য)

### ধাপ ১: Keystore তৈরি

আপনার কম্পিউটারে (একবারই করতে হবে):

```bash
keytool -genkey -v -keystore ~/amalghor.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias amalghor
```

একটা password সেট করুন এবং **অবশ্যই সংরক্ষণ করুন** — হারালে আর কখনো update push করতে পারবেন না।

### ধাপ ২: Base64 এনকোড

```bash
# Linux/Mac
base64 -i ~/amalghor.jks -o keystore.txt

# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$HOME\amalghor.jks")) > keystore.txt
```

### ধাপ ৩: GitHub Secrets যোগ করুন

Repository → **Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Value |
|---|---|
| `KEYSTORE_BASE64` | keystore.txt এর পুরো content |
| `KEYSTORE_PASSWORD` | আপনার keystore password |
| `KEY_PASSWORD` | আপনার key password |
| `KEY_ALIAS` | `amalghor` |

### ধাপ ৪: আবার Build চালান

এবার signed release APK পাবেন। Play Store-এ আপলোড করার জন্য ready।

---

## 📁 প্রজেক্ট স্ট্রাকচার

```
lib/
├── main.dart
├── app.dart
├── core/               # Theme, constants, router, date utils
├── l10n/               # ৩ ভাষার translations
├── data/
│   ├── models/         # Domain models
│   ├── database/       # SQLite wrapper
│   └── repositories/   # Data access layer
├── services/           # Adhan, location, notifications
├── providers/          # Riverpod state
└── features/           # UI screens
    ├── shell/
    ├── home/
    ├── prayer/
    ├── quran/
    ├── ramadan/
    ├── amol/
    └── settings/
```

---

## 🧪 Local Development

```bash
# 1. Clone
git clone https://github.com/YOUR_USERNAME/amalghor.git
cd amalghor

# 2. Dependencies
flutter pub get

# 3. Generate localizations
flutter gen-l10n

# 4. Run on device
flutter run
```

---

## ❓ সমস্যা হলে

### `flutter gen-l10n` error দিলে
```bash
flutter clean
flutter pub get
flutter gen-l10n
```

### Font missing error
`assets/fonts/` ফোল্ডারে সব ৮টি ফন্ট ঠিক নামে রাখুন। `pubspec.yaml`-এ নাম মিলিয়ে দেখুন।

### Gradle build fail
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --debug
```

### Location permission চায় না
Android Settings → Apps → Amalghor → Permissions → Location → Allow

---

## 📜 লাইসেন্স

এই প্রজেক্টটি MIT License-এর অধীনে। ব্যবহার, পরিবর্তন ও বিতরণ স্বাধীন।

---

## 🤲 দুআ

আল্লাহ এই অ্যাপটিকে মুসলিম উম্মাহর জন্য উপকারী করুন। আমিন।

---

**Version:** 1.0.0  
**Platform:** Android (Flutter)  
**Build:** GitHub Actions  
**License:** MIT  
**Ad-Free:** ✅
