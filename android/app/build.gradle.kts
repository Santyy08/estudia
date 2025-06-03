plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
// Carga las propiedades locales para acceder a flutter.sdk, etc.
val localProperties = java.util.Properties()
val localPropertiesFile = rootProject.file("local.properties") // Accede desde el proyecto raíz
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().buffered().use { localProperties.load(it) }
}

// Define las variables de Flutter o usa valores por defecto
val flutterVersionCode = localProperties.getProperty("flutter.versionCode")
val flutterVersionName = localProperties.getProperty("flutter.versionName")
val flutterMinSdkVersion = localProperties.getProperty("flutter.minSdkVersion")
val flutterTargetSdkVersion = localProperties.getProperty("flutter.targetSdkVersion")

android {
    namespace = "com.example.estudia"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

defaultConfig {
    applicationId = "com.tu.paquete" // Reemplaza com.tu.paquete con tu ID real
    minSdkVersion = flutterMinSdkVersion?.toIntOrNull() ?: 21 // Usa el valor de Flutter o 21 por defecto
    targetSdkVersion = flutterTargetSdkVersion?.toIntOrNull() ?: 34 // Usa el valor de Flutter o 34 por defecto
    versionCode = flutterVersionCode?.toIntOrNull() ?: 1
    versionName = flutterVersionName ?: "1.0"
}

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
