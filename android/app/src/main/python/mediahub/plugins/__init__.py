"""
MediaHub v2 — Python plugins package (Feature #5).

Authority: ADR-021 (Python plugin sandbox).

Exports the ``Extractor`` + ``MetadataPlugin`` protocols and the sandbox
utilities. Plugin authors register their implementations via the
``register_extractor`` / ``register_metadata_plugin`` helpers (added in
Phase 3 when the plugin marketplace is built).
"""

from __future__ import annotations

from .protocol import Extractor, MetadataPlugin
from .sandbox import SandboxError, create_sandbox_namespace, run_plugin

__all__ = [
    "Extractor",
    "MetadataPlugin",
    "SandboxError",
    "create_sandbox_namespace",
    "run_plugin",
]
