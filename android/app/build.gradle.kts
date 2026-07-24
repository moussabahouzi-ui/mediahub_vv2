// =============================================================================
// MediaHub v2 — Android :app build.gradle.kts (FIXED)
// Authority: ADR-007 (Chaquopy), ADR-012 (SDK matrix), ADR-013 (versions),
//            ADR-014 (reproducibility), ADR-016 (release/signing)
// =============================================================================
// FIX 1: Chaquopy lines commented out (Phase 0) — prevents "plugin not found"
// FIX 2: Release signing falls back to debug when key.properties absent (CI)

import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    alias(libs.plugins.ksp)
}

// ── Chaquopy (ADR-007) — DISABLED in Phase 0 ────────────────────────────────
// Phase 1: Uncomment these two lines when Python modules are ready.
// apply(plugin = "com.chaquo.python")
// apply(from = "chaquopy-config.gradle")
// NOTE: chaquopy-config.gradle must exist before uncommenting.

android {
    namespace = "com.mediahub.v2"
    compileSdk = 35

    ndkVersion = "26.3.11579264"

    defaultConfig {
        applicationId = "com.mediahub.v2"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "0.0.1"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
            isDebuggable = true
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // ── FIX 2: CI-friendly signing ──────────────────────────────
            // If key.properties exists (local dev or CI with secrets),
            // use it. Otherwise fall back to debug signing (Phase 0 CI).
            val keyProps = loadKeyProperties()
            signingConfig = if (keyProps != null) {
                signingConfigs.create("release").apply {
                    keyAlias = keyProps.getProperty("keyAlias")
                    keyPassword = keyProps.getProperty("keyPassword")
                    storeFile = file(keyProps.getProperty("storeFile"))
                    storePassword = keyProps.getProperty("storePassword")
                }
            } else {
                println("⚠️ key.properties not found — using debug signing (Phase 0 CI)")
                signingConfigs.getByName("debug")
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = false
    }

    kotlinOptions {
        jvmTarget = "17"
        freeCompilerArgs = listOf(
            "-Xjvm-default=all",
            "-opt-in=kotlin.RequiresOptIn"
        )
    }

    buildFeatures {
        buildConfig = true
    }

    packaging {
        resources {
            excludes += setOf(
                "META-INF/AL2.0",
                "META-INF/LGPL2.1",
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE*",
                "META-INF/NOTICE*",
                "META-INF/*.kotlin_module"
            )
        }
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            isReturnDefaultValues = true
        }
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.lifecycle.runtime)
    implementation(libs.androidx.work.runtime)
    implementation(libs.androidx.multidex)

    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
}

fun loadKeyProperties(): Properties? {
    val f = rootProject.file("key.properties")
    return if (f.exists()) {
        Properties().apply { f.inputStream().use { load(it) } }
    } else {
        null
    }
}
