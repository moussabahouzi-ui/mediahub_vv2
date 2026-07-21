// =============================================================================
// MediaHub v2 — Android settings.gradle.kts
// Authority: ADR-013 (version matrix), ADR-014 (reproducibility),
//            ADR-001 (Flutter Gradle plugin via composite build)
// =============================================================================
// The Flutter Gradle plugin is loaded via `includeBuild` of the Flutter SDK's
// `packages/flutter_tools/gradle` directory (inside pluginManagement, so the
// `plugins {}` block can resolve `dev.flutter.flutter-plugin-loader`).
//
// AGP + Kotlin versions are inline (settings-script `plugins {}` runs before
// the version catalog is parsed). Chaquopy/KSP/detekt versions come from the
// version catalog (applied at :app level).

pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
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
    // Flutter plugin loader — auto-discovers Flutter plugins declared in pubspec.
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // AGP + Kotlin versions are INLINE here (Gradle's settings-script
    // `plugins {}` block runs before the version catalog is parsed).
    // The version-matrix verifier (ADR-013) checks these literals match
    // libs.versions.toml's `agp` and `kotlin` entries.
    id("com.android.application")        version "8.7.3"   apply false
    id("org.jetbrains.kotlin.android")   version "2.0.21" apply false
    // Chaquopy (embedded Python, ADR-007) is NOT applied in Phase 0.
    // It needs the legacy `buildscript { classpath() }` mechanism which
    // conflicts with the modern Flutter plugins DSL. Phase 1 will add it
    // via the legacy block when there are real Python modules to embed.
    // The Python contract tests run on the host (pytest) instead.
    // KSP / detekt are applied at :app level where the catalog is accessible.
}

dependencyResolutionManagement {
    // PREFER_SETTINGS (not FAIL_ON_PROJECT_REPOS) because the Flutter Gradle
    // plugin itself adds a `maven` repository at runtime (for its engine
    // artifacts). FAIL_ON_PROJECT_REPOS would break the Flutter plugin.
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Chaquopy Maven repo (hosted on their own server) — ADR-007
        maven { url = uri("https://chaquo.com/maven") }
    }
}

rootProject.name = "mediahub_v2"
include(":app")
