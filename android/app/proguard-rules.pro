# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Strip Flutter / dart:developer log calls from release builds.
# The companion `kDebugMode` guard is in Dart code, so this is a
# belt-and-suspenders optimisation for the JVM side.
-assumenosideeffects class io.flutter.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** w(...);
    public static *** e(...);
}
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
    public static *** wtf(...);
}
-assumenosideeffects class java.util.logging.Level {
    public static *** w(...);
    public static *** d(...);
    public static *** v(...);
}
-assumenosideeffects class java.util.logging.Logger {
    public static *** w(...);
    public static *** d(...);
    public static *** v(...);
}
-assumenosideeffects class org.slf4j.Logger {
    public *** trace(...);
    public *** debug(...);
    public *** info(...);
    public *** warn(...);
    public *** error(...);
}

# Native PDF / MIDI libraries — these need full names for JNI.
-keep class com.shersoft.** { *; }
-keep class com.ravergames.** { *; }
-keep class com.igrek.** { *; }

# Retrofit / OkHttp
-keepattributes Signature
-keepattributes Exceptions
-dontwarn okhttp3.**
-keep class okhttp3.**{ *; }
-keep interface okhttp3.**{ *; }

# File Picker
-keep class com.mr.flutter.plugin.**  { *; }

# SQFlite
-keep class com.tekartik.sqflite.**  { *; }

# Google Sign-In
-keep class com.google.android.gms.** { *; }
-keep class com.google.api.client.** { *; }
-keep class com.google.auth.** { *; }

# Attributes that we DO want to keep.
-keepattributes *Annotation*
-keepattributes SourceFile, LineNumberTable
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Suppress warnings for split-install APIs (we don't use them).
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Aggressive optimisation flags.
-optimizationpasses 5
-allowaccessmodification
-repackageclasses ''

# Remove java.lang.Class.getClassLoader() and similar reflection helpers
# that are unused in release builds; the Flutter engine handles its own.
-assumenosideeffects class java.lang.Class {
    public static *** getClassLoader(...);
    public static *** forName(...);
}