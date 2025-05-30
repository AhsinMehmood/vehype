# Required by Scanbot SDK
-keep class io.scanbot.sdk.** { *; }
-dontwarn io.scanbot.sdk.**

# Required for dependencies used internally by Scanbot SDK
-keep class org.opencv.** { *; }
-dontwarn org.opencv.**
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# Required for Kotlin metadata
-keep class kotlin.Metadata { *; }
-keep class kotlin.jvm.internal.** { *; }

# Keep native libraries (if you use them)
-keep class org.libsdl.** { *; }
-dontwarn org.libsdl.**
