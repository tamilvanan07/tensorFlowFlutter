
plugins {
    id("com.android.application")
    kotlin("android") version "2.0.0" // or match your version
    id("io.objectbox") // Apply last
    id("com.google.devtools.ksp") version "2.0.0-1.0.24"
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}


android {
    namespace = "com.example.tensor_flow_project"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.tensor_flow_project"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled =  true
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = "key0"
            storeFile = file("/Users/admin/StudioProjects/tensor_flow_project/android/app/tamilkey.jks")
            keyPassword = "123456"
            storePassword = "123456"
        }
    }

    buildTypes {

        getByName("release") {

            signingConfig = signingConfigs.getByName("release")

            isMinifyEnabled = false
            isShrinkResources = false
                proguardFiles(
                    getDefaultProguardFile("proguard-android-optimize.txt"),
                    "proguard-rules.pro"
                )
        }
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
    applicationVariants.configureEach {
        kotlin.sourceSets {
            getByName(name) {
                kotlin.srcDir("build/generated/ksp/$name/kotlin")
            }
        }
    }
}



flutter {
    source = "../.."
}

dependencies {
    ///kotlin core
    implementation ("androidx.core:core-ktx:1.16.0")
    implementation ("androidx.appcompat:appcompat:1.7.0")
    implementation( "com.google.android.material:material:1.12.0")
    implementation("androidx.core:core-ktx:1.16.0")
    implementation ("androidx.constraintlayout:constraintlayout:2.2.1")

    ///tensor flow lite dependency
    implementation( "org.tensorflow:tensorflow-lite:2.12.0")  // ✅ Update to latest version
    implementation("org.tensorflow:tensorflow-lite-support:0.4.2")
    implementation ("org.tensorflow:tensorflow-lite-api:2.12.0")
    implementation("com.google.code.gson:gson:2.10.1")
    ///camera X dependency
    implementation ("androidx.camera:camera-core:1.4.2")
    implementation ("androidx.camera:camera-lifecycle:1.4.2")
    implementation ("androidx.camera:camera-view:1.4.2")

    //ml kit face detection
    implementation ("com.google.mlkit:face-detection:16.1.7")

    //android lifecycle runtime
    implementation ("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")

    //guava
    implementation ("com.google.guava:guava:33.4.0-android")

    implementation("com.google.mediapipe:tasks-vision:0.20230731") {
        exclude(group = "com.google.auto.value", module = "auto-value-annotations")
        exclude(group = "com.squareup", module = "javapoet")
    }
    implementation("androidx.multidex:multidex:2.0.1")

}
apply(plugin = "io.objectbox")