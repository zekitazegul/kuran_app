import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
}

val keys = Properties().apply { rootProject.file("key.properties").inputStream().use { load(it) } }

android {
    namespace = "com.zekitazegul.kuran_installer"
    compileSdk = 36
    defaultConfig {
        applicationId = "com.zekitazegul.kuran_installer"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
        buildConfigField("String", "MANIFEST_URL", "\"https://github.com/zekitazegul/kuran_app/releases/latest/download/update.json\"")
    }
    buildFeatures { buildConfig = true }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    signingConfigs {
        create("release") {
            keyAlias = keys["keyAlias"] as String
            keyPassword = keys["keyPassword"] as String
            storeFile = project(":app").file(keys["storeFile"] as String)
            storePassword = keys["storePassword"] as String
        }
    }
    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("release")
            val testUrl = providers.gradleProperty("installerTestManifestUrl").orNull
            if (testUrl != null) {
                require(testUrl.matches(Regex("http://127\\.0\\.0\\.1:[0-9]+/update\\.json")))
                buildConfigField("String", "MANIFEST_URL", "\"$testUrl\"")
            }
        }
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
        }
    }
}
