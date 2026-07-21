"""
MediaHub v2 — Python plugin protocol (Feature #5).

Authority: ADR-021 (Python plugin sandbox).

Phase 2 Feature #5: defines the ``Extractor`` and ``MetadataPlugin``
protocols that third-party Python plugins must implement. The sandbox
(:mod:`mediahub.plugins.sandbox`) enforces a restricted import surface
so plugins cannot import ``os``, ``subprocess``, ``socket``, etc.

A plugin is registered via::

    from mediahub.plugins import register_extractor, register_metadata_plugin

    class MyExtractor:
        name = "my-extractor"
        def can_handle(self, source: str) -> bool: ...
        def extract(self, source: str) -> dict[str, object]: ...

    register_extractor(MyExtractor())
"""

from __future__ import annotations

from typing import Protocol, runtime_checkable


@runtime_checkable
class Extractor(Protocol):
    """Protocol for media-source extractors.

    An extractor takes a source URI (local file path or remote URL) and
    returns a dict of media metadata (title, duration, etc.).
    """

    name: str

    def can_handle(self, source: str) -> bool: ...

    def extract(self, source: str) -> dict[str, object]: ...


@runtime_checkable
class MetadataPlugin(Protocol):
    """Protocol for metadata-enrichment plugins.

    A metadata plugin takes a media id and returns a dict of enriched
    metadata (transcript, tags, embedding, etc.).
    """

    name: str

    def enrich(self, media_id: str) -> dict[str, object]: ...
