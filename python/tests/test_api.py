"""
MediaHub v2 — pytest suite for the embedded Python runtime (Feature #5).

Authority: ADR-017 (testing strategy).

Phase 2 Feature #5: tests for `verify_runtime()` + the plugin sandbox
(`mediahub.plugins.sandbox`).
"""

from __future__ import annotations

import sys
import time

import pytest
from mediahub.api import ping, verify_runtime
from mediahub.errors import PythonRuntimeError
from mediahub.plugins.sandbox import (
    SandboxError,
    run_plugin,
)


class TestVerifyRuntime:
    """Phase 2 Feature #5: verify_runtime() contract."""

    def test_returns_python_version(self) -> None:
        result = verify_runtime()
        assert result["pythonVersion"] == sys.version.split(" ")[0]

    def test_returns_mediahub_version(self) -> None:
        result = verify_runtime()
        from mediahub import __version__ as expected
        assert result["mediahubVersion"] == expected

    def test_returns_timestamp_ms(self) -> None:
        before = int(time.time() * 1000)
        result = verify_runtime()
        after = int(time.time() * 1000)
        ts = result["timestampMs"]
        assert isinstance(ts, int)
        assert before <= ts <= after  # type: ignore[operator]

    def test_returns_dict_matching_pigeon_schema(self) -> None:
        result = verify_runtime()
        assert set(result.keys()) == {
            "pythonVersion",
            "mediahubVersion",
            "timestampMs",
        }


class TestPing:
    """Phase 0 smoke call — retained for regression."""

    def test_returns_pong_with_timestamp(self) -> None:
        before = int(time.time() * 1000)
        result = ping("hello")
        after = int(time.time() * 1000)
        assert result["message"] == "pong"
        assert isinstance(result["timestampMs"], int)
        assert before <= result["timestampMs"] <= after  # type: ignore[operator]

    def test_accepts_none(self) -> None:
        result = ping(None)
        assert result["message"] == "pong"

    def test_rejects_non_string(self) -> None:
        with pytest.raises(PythonRuntimeError):
            ping(42)  # type: ignore[arg-type]

    def test_rejects_dict(self) -> None:
        with pytest.raises(PythonRuntimeError):
            ping({"not": "a string"})  # type: ignore[arg-type]


class TestSandboxBlockedImports:
    """Phase 2 Feature #5: the sandbox blocks dangerous modules."""

    @pytest.mark.parametrize("module", [
        "os", "subprocess", "socket", "ctypes", "multiprocessing",
        "importlib", "builtins", "shutil", "tempfile", "pathlib",
    ])
    def test_blocked_module_raises_sandbox_error(self, module: str) -> None:
        code = f"import {module}"
        with pytest.raises(SandboxError, match=f"Module '{module}' is blocked"):
            run_plugin(code, "_entry")

    def test_run_plugin_executes_entry_point(self) -> None:
        code = """
def _entry(x, y):
    return x + y
"""
        result = run_plugin(code, "_entry", 2, 3)
        assert result == 5

    def test_run_plugin_raises_on_missing_entry(self) -> None:
        code = "x = 1"
        with pytest.raises(SandboxError, match="does not define a callable"):
            run_plugin(code, "missing_entry")

    def test_sandbox_allows_safe_builtins(self) -> None:
        code = """
def _entry():
    return sum([1, 2, 3]) + len([1, 2]) + max([4, 5, 6])
"""
        result = run_plugin(code, "_entry")
        assert result == 6 + 2 + 6

    def test_sandbox_blocks_os_via_from_import(self) -> None:
        code = "from os import path"
        with pytest.raises(SandboxError, match="Module 'os' is blocked"):
            run_plugin(code, "_entry")
