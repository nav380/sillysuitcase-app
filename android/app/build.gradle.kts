plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin
}

android {
    namespace = "com.sillysuitcase.app"
    compileSdk = 35
    

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.sillysuitcase.app" // Play Store package
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    signingConfigs {
        create("release") {
            storeFile = file("key/sillysuitcase-release-key.jks")
            storePassword = "Naveen9877@"
            keyAlias = "sillysuitcase"
            keyPassword = "Naveen9877@"
        }
    }

    buildTypes {
        getByName("release") {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = false
        isShrinkResources = false
        isDebuggable = false
    }

        getByName("debug") {
    isDebuggable = true
}

    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.0")
}