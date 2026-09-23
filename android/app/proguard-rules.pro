# Flutter Wrapper Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase Rules
-dontwarn com.google.firebase.**
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Desugaring & Java 8+ APIs
-keep class java.time.** { *; }
-dontwarn java.time.**
-dontwarn sun.misc.Unsafe

# Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# OkHttp & HTTP client
-dontwarn okhttp3.**
-dontwarn okio.**

# Play Core & Deferred Components
-dontwarn com.google.android.play.core.**

# Shared Preferences & Storage
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Facebook Auth
-keep class com.facebook.** { *; }
-dontwarn com.facebook.**

# Google Sign In
-keep class com.google.android.gms.auth.api.signin.** { *; }

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

