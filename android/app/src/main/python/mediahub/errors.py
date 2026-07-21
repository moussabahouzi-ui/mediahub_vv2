"""
MediaHub v2 — Python runtime error hierarchy.

Authority: ADR-008 (typed IPC; Python errors caught at the boundary and
mapped to typed Dart Failures), ADR-009 (Failure as value).
"""

from __future__ import annotations


class PythonRuntimeError(Exception):
    """Base class for any error raised by the embedded Python runtime.

    The Kotlin adapter catches this (and any other ``Exception``) and
    maps it to a ``PythonRuntimeFailure`` on the Dart side (ADR-008/009).
    """


class InvalidInputError(PythonRuntimeError):
    """Raised when a Pigeon-bound function receives invalid input."""


class PipelineError(PythonRuntimeError):
    """Raised when an ML pipeline (transcription, tagging, embedding) fails.

    Phase 1+: concrete subclasses per pipeline.
    """
