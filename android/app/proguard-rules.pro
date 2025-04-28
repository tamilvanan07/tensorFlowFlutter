# ML Kit / Firebase Vision
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }

# TensorFlow Lite
-keep class org.tensorflow.** { *; }

# Prevent removal of classes accessed via reflection
-keepattributes *Annotation*
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}
-keepclasseswithmembers class * {
    native <methods>;
}

# Ignore compiler-only annotation classes
-dontwarn javax.lang.**
-dontwarn com.squareup.javapoet.**
-dontwarn com.google.auto.value.**

-keep class org.tensorflow.lite.gpu.** { *; }
# Keep TFLite classes and annotations
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }
-keepclassmembers class * {
    @org.tensorflow.lite.schema.** <fields>;
}

-keep class io.objectbox.** { *; }
-keep class your.package.name.model.** { *; }
-keepclassmembers class * {
    @io.objectbox.annotation.* <methods>;
}

# Common JSON model mapping protection (if needed)
-keep class * implements java.io.Serializable {
    *;
}