# ─────────────────────────────────────────────
# Flutter
# ─────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# ─────────────────────────────────────────────
# Play Core (deferred components)
# ─────────────────────────────────────────────
-dontwarn com.google.android.play.core.**

# ─────────────────────────────────────────────
# Flutter Local Notifications
# ─────────────────────────────────────────────
-keep class com.dexterous.** { *; }

# ─────────────────────────────────────────────
# sqflite
# ─────────────────────────────────────────────
-keep class com.tekartik.sqflite.** { *; }

# ─────────────────────────────────────────────
# Geolocator
# ─────────────────────────────────────────────
-keep class com.baseflow.geolocator.** { *; }

# ─────────────────────────────────────────────
# timezone
# ─────────────────────────────────────────────
-keep class org.threeten.bp.** { *; }

# ─────────────────────────────────────────────
# kotlinx
# ─────────────────────────────────────────────
-dontwarn kotlinx.**

# ─────────────────────────────────────────────
# Annotations
# ─────────────────────────────────────────────
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
