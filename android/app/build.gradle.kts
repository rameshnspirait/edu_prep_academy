plugins {
    id("com.android.application")
    id("kotlin-android")

    // ✅ REQUIRED for Firebase (VERY IMPORTANT)
    id("com.google.gms.google-services")

    // Flutter plugin (must be last)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // ❗ MUST MATCH applicationId (lowercase only)
    namespace = "com.examsolving.eduprepacademy.android"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // ❗ LOWERCASE ONLY (Firebase requirement)
        applicationId = "com.examsolving.eduprepacademy.android"
        minSdk = flutter.minSdkVersion               // ✅ Firebase requires minSdk 21
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
