// =============================================================================
// MediaHub v2 — Android root build.gradle.kts
// Authority: ADR-013 (version matrix), ADR-014 (reproducibility),
//            ADR-007 (Chaquopy — activated in Phase 2 Feature #5)
// =============================================================================
// Plugin versions for AGP + Kotlin are declared in settings.gradle.kts
// (inline, because the settings-script plugins{} block runs before the
// version catalog is parsed).
//
// Chaquopy (ADR-007) is loaded via the LEGACY buildscript mechanism because
// its 16.x line cannot be applied via the modern plugins DSL — it requires
// AGP on the buildscript classpath, which the plugins DSL doesn't populate.
// See DEVIATIONS.md D-4 (resolved in Phase 2 Feature #5) + ADR-007 amendment.

buildscript {
    repositories {
        google()
        mavenCentral()
        // Chaquopy Maven repo (hosted on their own server) — ADR-007
        maven { url = uri("https://chaquo.com/maven") }
    }
    dependencies {
        // AGP must be on the buildscript classpath for Chaquopy to find it.
        // Chaquopy's plugin applies AGP via project.apply(plugin = "com.android.application")
        // which requires AGP on the buildscript classpath — not the modern plugins{} DSL.
        // Version matches libs.versions.toml's `agp` entry (verifier cross-checks).
        classpath("com.android.tools.build:gradle:8.7.3")
        // Chaquopy Gradle plugin — version matches libs.versions.toml's `chaquopy` entry.
        classpath("com.chaquo.python:gradle:16.1.0")
    }
}

// ── Reproducibility (ADR-014) ─────────────────────────────────────────────────
allprojects {
    if (!hasProperty("sourceDateEpoch")) {
        extra["sourceDateEpoch"] = "1700000000"
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.layout.buildDirectory)
}
