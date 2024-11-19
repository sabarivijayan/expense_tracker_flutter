# Keep Isar classes
-keep class isar.** { *; }
-keep class io.isar.** { *; }
-keepclassmembers class io.isar.** { *; }
-keepattributes *Annotation*

# Required if you're using Flutter
-keep class androidx.lifecycle.** { *; }
-keep class io.flutter.** { *; }