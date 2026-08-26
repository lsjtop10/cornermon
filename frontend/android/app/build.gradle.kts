import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { input ->
        keystoreProperties.load(input)
    }
}

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.cornermon.cornermon"
    // flutter_secure_storage 11.x가 SDK 37 컴파일을 요구 (#259) — Flutter 기본값(36)보다 명시적으로 높여야 함
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    flavorDimensions.add("app")

    productFlavors {
        create("admin") {
            dimension = "app"
            applicationIdSuffix = ".admin"
            manifestPlaceholders["appName"] = "코너학습 관리자"
        }
        create("facilitator") {
            dimension = "app"
            applicationIdSuffix = ".facilitator"
            manifestPlaceholders["appName"] = "코너학습 진행자"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.cornermon.cornermon"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
 // 기존 디버그 서명 대신 생성한 release 서명을 할당합니다.
            signingConfig = signingConfigs.getByName("release")

            optimization {
                enable = false // R8 코드 및 리소스 축소 최적화 끄기
            }
            
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
