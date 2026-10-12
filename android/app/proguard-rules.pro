# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# sqflite
-keep class com.tekartik.sqflite.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# timezone
-keep class org.threeten.bp.** { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses

# kotlinx
-dontwarn kotlinx.**
