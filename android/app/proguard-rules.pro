# Flutter-specific ProGuard rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }

# Keep Gson/JSON serialization classes
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }

# Keep model classes used for JSON parsing (if any native models exist)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Prevent R8 from removing classes referenced via reflection
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**

# Keep Flutter secure storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }
