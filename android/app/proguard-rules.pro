# =============================================================================
# MediaHub v2 — R8 / ProGuard rules
# Authority: ADR-011 (security), ADR-013 (R8 config in VCS), ADR-016 (release)
# =============================================================================
# Phase 0: minimal rules. Feature phases add module-specific keep rules via
# this file (NOT per-developer).

# ── General ─────────────────────────────────────────────────────────────────
-dontpreverify
-optimizationpasses 5
-allowaccessmodification
-overloadaggressively
-mergeinterfacesaggressively

# Print usage / mapping for verification
-printusage
-printconfiguration

# ── Flutter / Dart ───────────────────────────────────────────────────────────
# Flutter ships its own rules; we keep io.flutter.** and the FlutterApplication.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# ── Chaquopy (embedded Python) — ADR-007 ─────────────────────────────────────
# Critical: Chaquopy's runtime uses reflection heavily.
-keep class com.chaquo.python.** { *; }
-keep class com.chaquo.python.**.* { *; }
-dontwarn com.chaquo.python.**
-keep class com.chaquo.python_pyobject.** { *; }

# Python's native lib and .so files are loaded by name.
-keepclasseswithmembernames class * {
    native <methods>;
}

# ── PythonApiHost (Pigeon adapter) — ADR-008 ────────────────────────────────
# The Kotlin adapter is called via reflection from the Pigeon-generated
# PythonApi.setUp() method. Keep all public methods.
-keep class com.mediahub.v2.python.** { *; }
-keepclassmembers class com.mediahub.v2.python.PythonApiHost {
    public *;
}

# ── SQLite / SQLCipher (Drift) — ADR-005/011 ─────────────────────────────────
-keep class io.sqlite4a.** { *; }
-keep class net.sqlcipher.** { *; }
-dontwarn net.sqlcipher.**

# ── Riverpod (state mgmt) — ADR-003 ───────────────────────────────────────────
-keep class org.jetbrains.annotations.** { *; }
-keep @org.jetbrains.annotations.Nullable class *
-keep @org.jetbrains.annotations.NotNull class *

# ── Sentry (observability) — ADR-010 ─────────────────────────────────────────
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**
-keepattributes SourceFile,LineNumberTable
-dontwarn org.slf4j.impl.**

# ── Pigeon-generated bindings — ADR-008 ──────────────────────────────────────
-keep class com.mediahub.v2.**Pigeon.** { *; }
-keep class com.mediahub.v2.**.*Pigeon { *; }

# ── Kotlin metadata ───────────────────────────────────────────────────────────
-keep class kotlin.Metadata { *; }
-keepattributes RuntimeVisibleAnnotations,RuntimeVisibleParameterAnnotations
