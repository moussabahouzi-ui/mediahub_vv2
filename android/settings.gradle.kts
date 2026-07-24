// =============================================================================
// MediaHub v2 — Android settings.gradle.kts (FIXED)
// Authority: ADR-013 (version matrix), ADR-014 (reproducibility),
//            ADR-001 (Flutter Gradle plugin via composite build)
// =============================================================================
// FIX: Added FLUTTER_ROOT fallback for CI environments where local.properties
// does not exist (GitHub Actions runners).

pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localProps = file("local.properties")
        if (localProps.exists()) {
            localProps.inputStream().use { properties.load(it) }
            properties.getProperty("flutter.sdk")
        } else {
            // CI fallback: flutter-action sets FLUTTER_ROOT / FLUTTER_HOME
            System.getenv("FLUTTER_ROOT")
                ?: System.getenv("FLUTTER_HOME")
                ?: throw GradleException(
                    "Flutter SDK not found. " +
                    "Set flutter.sdk in local.properties or FLUTTER_ROOT env var."
                )
        }
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application")        version "8.7.3"   apply false
    id("org.jetbrains.kotlin.android")   version "2.0.21" apply false
    // Chaquopy disabled in Phase 0 — see build.gradle.kts
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Chaquopy Maven repo — ready for Phase 1 (ADR-007)
        maven { url = uri("https://chaquo.com/maven") }
    }
}

rootProject.name = "mediahub_v2"
include(":app")
