"""
MediaHub v2 — Python API surface (mirrors the Pigeon schema).

Authority: ADR-007 (embedded Python), ADR-008 (typed IPC).

Phase 0: a single ``ping`` function.
Phase 2 Feature #5: added ``verify_runtime`` — verifies the embedded Python
  runtime is alive and the ``mediahub`` module is importable.
Phase 2 Feature #9: will add transcribe/embed/tag pipeline functions.

DEFENSIVE INPUT VALIDATION (ADR-008): every public function must validate
its inputs at the boundary. Inputs are untrusted even though the caller is
the Kotlin adapter — defensive programming at the edge is mandatory.
"""

from __future__ import annotations

import sys
import time
from typing import Final

from . import __version__ as _MEDIAHUB_VERSION
from .errors import PythonRuntimeError

__all__ = ["ping", "verify_runtime"]


_PONG: Final[str] = "pong"


def ping(message: str | None) -> dict[str, object]:
    """Phase 0 smoke call.

    Args:
        message: the ping payload from Flutter (may be ``None``).

    Returns:
        A dict matching the Pigeon ``PingResponse`` schema::

            {"message": "pong", "timestampMs": <int>}

    Raises:
        PythonRuntimeError: if the input is invalid (defensive boundary).
    """
    # ── Defensive input validation (ADR-008) ──────────────────────────────
    if message is not None and not isinstance(message, str):
        raise PythonRuntimeError(
            f"ping.message must be a str or None, got {type(message).__name__}"
        )

    return {
        "message": _PONG,
        "timestampMs": int(time.time() * 1000),
    }


def verify_runtime() -> dict[str, object]:
    """Phase 2 Feature #5: verify the embedded Python runtime is alive.

    Returns:
        A dict matching the Pigeon ``VerifyRuntimeResponse`` schema::

            {"pythonVersion": "3.11.x", "mediahubVersion": "0.0.1",
             "timestampMs": <int>}

    Raises:
        PythonRuntimeError: never under normal operation; the function has
            no inputs. Any failure to import sys/platform indicates a
            broken Python install, which Chaquopy would surface as a
            boot-time error before this function is callable.
    """
    return {
        "pythonVersion": sys.version.split(" ")[0],
        "mediahubVersion": _MEDIAHUB_VERSION,
        "timestampMs": int(time.time() * 1000),
    }
