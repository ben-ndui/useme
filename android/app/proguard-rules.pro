# Stripe Push Provisioning (optional feature, ignore missing classes)
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.reactnativestripesdk.pushprovisioning.**

# Keep Stripe classes
-keep class com.stripe.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.maps.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Keep Gson/JSON serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
