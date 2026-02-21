# --------------------
# STRIPE SDK KEEP RULES
# --------------------

-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Push Provisioning (Google Pay / Wallet)
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# Stripe React Native bridge (even if Flutter, dependency pulls this)
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

# Kotlin metadata (Stripe uses Kotlin heavily)
-keep class kotlin.Metadata { *; }

# Prevent removal of reflection-used classes
-keepattributes *Annotation*
