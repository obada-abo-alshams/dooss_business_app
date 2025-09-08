# Flutter and common rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class androidx.** { *; }

# Keep Gson models if used
-keep class com.google.gson.stream.** { *; }
-keep class com.google.gson.** { *; }

# OkHttp/Okio/Dio
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }

# Keep classes used by reflection (Dio interceptors, etc.)
-keep class ** extends java.lang.annotation.Annotation { *; }

# Media3
-dontwarn androidx.media3.**
-keep class androidx.media3.** { *; }