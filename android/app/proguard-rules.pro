# =============================================================================
# Flutter engine
# =============================================================================
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# =============================================================================
# Firebase (core + messaging + analytics)
# =============================================================================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# =============================================================================
# OkHttp & Okio  (used internally by Dio's native HTTP client)
# =============================================================================
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }
# Silence warnings from OkHttp's optional Kotlin extension types
-dontwarn org.codehaus.mojo.animal_sniffer.*
-dontwarn javax.annotation.**

# =============================================================================
# Retrofit (used via the retrofit Dart-code generator; the generated .g.dart
# files call Dio directly, but keep annotations so R8 does not strip them)
# =============================================================================
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keep class retrofit2.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

# =============================================================================
# json_serializable / json_annotation
# (Dart-generated fromJson/toJson run in the Dart VM, but these guards
#  protect any JNI-boundary reflection that the Flutter embedding may use)
# =============================================================================
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# =============================================================================
# socket.io-client (used for real-time incident updates)
# =============================================================================
-keep class io.socket.** { *; }
-dontwarn io.socket.**
# Engine.IO transport classes are loaded reflectively
-keep class io.socket.engineio.** { *; }
-keep class io.socket.client.** { *; }

# =============================================================================
# Kotlin coroutines & stdlib
# =============================================================================
-dontwarn kotlinx.coroutines.**
-keep class kotlinx.coroutines.** { *; }
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# =============================================================================
# flutter_secure_storage (uses Android Keystore via reflection)
# =============================================================================
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# =============================================================================
# geolocator (uses location services via reflection on some Android versions)
# =============================================================================
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# =============================================================================
# audioplayers  (used by AlarmService for proximity alerts)
# =============================================================================
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# =============================================================================
# Suppress common third-party warnings that do not affect runtime correctness
# =============================================================================
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
-dontwarn com.sun.jna.**
