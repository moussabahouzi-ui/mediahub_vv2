// =============================================================================
// MediaHub v2 — Android :app build.gradle.kts
// Authority: ADR-007 (Chaquopy), ADR-012 (SDK matrix), ADR-013 (versions),
//            ADR-014 (reproducibility), ADR-016 (release/signing)
// =============================================================================
// All versions come from libs.versions.toml. No literals.

import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin
    // Gradle plugins (ADR-001). Loaded via includeBuild in settings.gradle.kts.
    id("dev.flutter.flutter-gradle-plugin")
    alias(libs.plugins.ksp)
}

// Chaquopy (ADR-007) — activated in Phase 2 Feature #5.
// Loaded via legacy buildscript classpath in android/build.gradle.kts.
// MUST be applied OUTSIDE the plugins {} block in Kotlin DSL — the
// `apply(plugin = ...)` syntax is not valid inside the plugins block.
// The chaquopy { ... } configuration is in chaquopy-config.gradle (Groovy
// script) because the Kotlin DSL compiler doesn't generate type-safe
// accessors for legacy-applied plugin extensions.
apply(plugin = "com.chaquo.python")
apply(from = "chaquopy-config.gradle")

android {
    namespace = "com.mediahub.v2"
    compileSdk = 35  // ADR-012

    // NDK pinned for Chaquopy native libs (ADR-007 + ADR-014).
    // Chaquopy 16.x recommends NDK r26.
    ndkVersion = "26.3.11579264"

    defaultConfig {
        applicationId = "com.mediahub.v2"
        minSdk = 26      // ADR-012
        targetSdk = 35   // ADR-012
        versionCode = 1
        versionName = "0.0.1"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        // ABI targeting (ADR-012 + ADR-007 — Chaquopy requires ndk.abiFilters).
        // arm64-v8a = primary (modern devices)
        // armeabi-v7a = legacy (32-bit ARM)
        // x86_64 = emulator testing
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
            // ADR-016: CI-only signing; local builds use debug key.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Signing config loaded from android/key.properties (git-ignored).
            // CI injects via GitHub secrets; see release workflow.
            signingConfig = signingConfigs.create("release")
            val keyProps = loadKeyProperties()
            if (keyProps != null) {
                signingConfigs.getByName("release").apply {
                    keyAlias = keyProps.getProperty("keyAlias")
                    keyPassword = keyProps.getProperty("keyPassword")
                    storeFile = file(keyProps.getProperty("storeFile"))
                    storePassword = keyProps.getProperty("storePassword")
                }
            }
        }
    }

    // Note: ABI splits (per-arch APKs) are disabled in Phase 2. Chaquopy
    // requires ndk.abiFilters (above), which conflicts with splits.abi.
    // Phase 3 may re-enable splits for release builds if APK size is a concern.

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Desugaring — required for some Java 8+ APIs on minSdk 26
        isCoreLibraryDesugaringEnabled = false  // not needed at minSdk 26
    }

    kotlinOptions {
        jvmTarget = "17"
        freeCompilerArgs = listOf(
            "-Xjvm-default=all",
            "-opt-in=kotlin.RequiresOptIn"
        )
    }

    buildFeatures {
        buildConfig = true   // need BuildConfig for Sentry DSN
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

// ── Chaquopy (ADR-007) — configuration is in chaquopy-config.gradle ──────────
// (applied above via `apply(from = "chaquopy-config.gradle")`)

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

// ── Reproducibility: deterministic APK output name (ADR-014) ────────────────
// Phase 0: the default AGP output name (e.g. `app-debug.apk`) is accepted.
// Phase 1 will use the proper VariantOutput API to override it once the
// AGP API surface is finalised for our target version.
// (The previous attempt used `outputFileName` which is not on the public
// VariantOutput interface in AGP 8.7; it's on VariantOutputImpl which is
// an internal class. See DEVIATIONS.md.)

// Helper: load android/key.properties (git-ignored; CI-provided).
fun loadKeyProperties(): Properties? {
    val f = rootProject.file("key.properties")
    if (!f.exists()) return null
    return Properties().apply { f.inputStream().use { load(it) } }
}
