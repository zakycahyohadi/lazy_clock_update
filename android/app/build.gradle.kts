plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lazy_clock"
    compileSdk = flutter.compileSdkVersion

    // ✅ Gunakan versi NDK yang kompatibel dengan semua plugin
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Ubah applicationId dengan nama unik kamu
        applicationId = "com.example.lazy_clock"

        // ⚙️ Gunakan konfigurasi Flutter default
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 🔐 Signing configuration (biar bisa upload ke Play Store)
    signingConfigs {
        create("release") {
            // Ganti path dan password sesuai file .jks kamu
            storeFile = file("../app-release-key.jks")
            storePassword = "your-store-password"
            keyAlias = "your-key-alias"
            keyPassword = "your-key-password"
        }
    }

    buildTypes {
        release {
            // Gunakan keystore release untuk build final
            signingConfig = signingConfigs.getByName("release")

            // 🔧 Aktifkan minify untuk optimasi ukuran APK
            isMinifyEnabled = true
            isShrinkResources = true

            // File proguard (jaga performa dan keamanan)
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        debug {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
