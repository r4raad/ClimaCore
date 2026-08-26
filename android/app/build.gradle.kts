import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.climacore"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.climacore"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val localProperties = Properties()
        val localPropertiesFile = rootProject.file("local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use { localProperties.load(it) }
        }

        val envProperties = Properties()
        val envFile = rootProject.file("../.env")
        if (envFile.exists()) {
            envFile.inputStream().use { envProperties.load(it) }
        }

        val googleMapsApiKey = System.getenv("GOOGLE_MAPS_API_KEY")
            ?: envProperties.getProperty("GOOGLE_MAPS_API_KEY")
            ?: localProperties.getProperty("MAPS_API_KEY")
            ?: localProperties.getProperty("GOOGLE_MAPS_API_KEY")
            ?: ""

        if (googleMapsApiKey.isNotEmpty()) {
            manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
        } else {
            manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = "YOUR_GOOGLE_MAPS_API_KEY_HERE"
        }
    }

    // ✅ keystore 설정 (Kotlin 방식)
    signingConfigs {
        create("release") {
            val keystoreProperties = Properties().apply {
                val keystoreFile = rootProject.file("key.properties")
                if (keystoreFile.exists()) {
                    load(keystoreFile.inputStream())
                }
            }

            storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}