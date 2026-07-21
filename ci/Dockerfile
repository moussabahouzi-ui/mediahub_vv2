# =============================================================================
# MediaHub v2 — pinned build image (ADR-014 reproducible builds)
# =============================================================================
# This Dockerfile builds the image used by GitHub Actions release workflow.
# The image is tagged with the git commit SHA; the release workflow uses
# the SHA tag, NEVER 'latest'.
#
# Phase 0: image builds Flutter, JDK, Android SDK, Python, and Chaquopy's
# wheel-builder. It does NOT include app sources — those are mounted at
# runtime via actions/checkout.
# =============================================================================

FROM ubuntu:22.04

# ── APT layer ─────────────────────────────────────────────────────────────────
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        unzip \
        xz-utils \
        git \
        openssh-client \
        build-essential \
        libsqlite3-dev \
        libssl-dev \
        zlib1g-dev \
        && rm -rf /var/lib/apt/lists/*

# ── JDK 17 (Temurin) ─────────────────────────────────────────────────────────
ARG JDK_VERSION=17
RUN curl -fsSL "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_x64_linux_hotspot_17.0.13_11.tar.gz" \
        -o /tmp/jdk.tgz \
    && mkdir -p /opt/jdk \
    && tar -xzf /tmp/jdk.tgz -C /opt/jdk --strip-components=1 \
    && rm /tmp/jdk.tgz
ENV JAVA_HOME=/opt/jdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# ── Android SDK (cmdline-tools + platform + build-tools) ─────────────────────
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && curl -fsSL "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -o /tmp/cmdline.zip \
    && unzip -q /tmp/cmdline.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cmdline.zip \
    && yes | sdkmanager --licenses > /dev/null 2>&1 \
    && sdkmanager \
        "platform-tools" \
        "platforms;android-35" \
        "build-tools;35.0.0" \
        "ndk;26.3.11579264"

# ── Flutter SDK (fvm-managed, pinned to 3.29.3 stable) ──────────────────────
ENV FLUTTER_VERSION=3.29.3
RUN git clone --depth 1 --branch ${FLUTTER_VERSION}-stable \
        https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"
RUN flutter --version && flutter precache --android

# ── Python 3.11 + Chaquopy wheel-builder ──────────────────────────────────────
ARG PYTHON_VERSION=3.11
RUN apt-get update && apt-get install -y --no-install-recommends \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-venv \
        python3-pip \
        && rm -rf /var/lib/apt/lists/*
RUN python3 -m pip install --no-cache-dir \
        "pip>=24.0" \
        "wheel>=0.42" \
        "setuptools>=68.0" \
        "pip-audit>=2.7,<3.0" \
        "pytest>=8.0,<9.0" \
        "ruff>=0.6.0,<0.7.0" \
        "mypy>=1.11,<2.0"

# ── Default working dir ───────────────────────────────────────────────────────
WORKDIR /workspace

# Smoke check that everything resolves
RUN flutter --version \
    && java -version \
    && python3 --version
