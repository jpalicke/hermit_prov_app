import java.io.File
import java.io.FileInputStream
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasKeystore = keystorePropertiesFile.exists()
if (hasKeystore) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

fun Properties.require(key: String): String =
    getProperty(key) ?: throw GradleException("key.properties is missing required key: $key")

android {
    namespace = "com.hermitprov.hermit_prov_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hermitprov.hermit_prov_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasKeystore) {
            create("release") {
                keyAlias = keystoreProperties.require("keyAlias")
                keyPassword = keystoreProperties.require("keyPassword")
                val storeFilePath = keystoreProperties.require("storeFile")
                if (!File(storeFilePath).isAbsolute) {
                    throw GradleException("key.properties storeFile must be an absolute path, got: $storeFilePath")
                }
                storeFile = file(storeFilePath)
                storePassword = keystoreProperties.require("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Uses release signing when key.properties is present; falls back to the
            // AGP-implicit debug config otherwise so CI and fresh clones build without error.
            signingConfig = if (hasKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
