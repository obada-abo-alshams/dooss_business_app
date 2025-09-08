# Flutter-specific ProGuard rules for better performance and smaller APK size

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# Keep ExoPlayer classes for video playback
-keep class androidx.media3.** { *; }
-keep interface androidx.media3.** { *; }

# Keep Dio and network-related classes
-keep class dio.** { *; }
-keep class retrofit2.** { *; }

# Keep model classes for JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep WebSocket classes
-keep class org.java_websocket.** { *; }

# Keep location services
-keep class com.google.android.gms.location.** { *; }

# Keep Google Maps classes
-keep class com.google.android.gms.maps.** { *; }

# General optimizations
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Optimize for size
-repackageclasses ''
-allowaccessmodification