"""
MediaHub v2 — Python plugin sandbox (Feature #5).

Authority: ADR-021 (Python plugin sandbox).

Phase 2 Feature #5: enforces a restricted import surface for third-party
Python plugins. The sandbox intercepts ``__import__`` and blocks a
configurable deny-list of modules that pose a security risk:

    - ``os``, ``subprocess``, ``socket``, ``ctypes``, ``multiprocessing``
      (filesystem + process + network access)
    - ``importlib`` (could be used to bypass the sandbox)
    - ``builtins`` direct access (could re-enable ``__import__``)

Plugins are loaded via :func:`run_plugin`, which executes plugin code in
a namespace with the restricted ``__import__`` installed.

NOTE: this is a defence-in-depth measure, not a complete sandbox. A
determined attacker with knowledge of CPython internals may still escape.
For fully untrusted plugins, consider running them in a separate process
or a seccomp sandbox. Phase 3 may revisit this.
"""

from __future__ import annotations

from typing import Any

# Modules blocked in the plugin sandbox.
_BLOCKED_MODULES: frozenset[str] = frozenset({
    "os",
    "subprocess",
    "socket",
    "ctypes",
    "multiprocessing",
    "importlib",
    "builtins",
    "shutil",
    "tempfile",
    "pathlib",
    "glob",
    "fcntl",
    "resource",
    "signal",
    "_thread",
    "threading",
})


class SandboxError(Exception):
    """Raised when a plugin attempts to import a blocked module."""


def _restricted_import(
    name: str,
    globals: dict[str, Any] | None = None,
    locals: dict[str, Any] | None = None,
    fromlist: tuple[str, ...] = (),
    level: int = 0,
) -> Any:
    """A restricted ``__import__`` that blocks dangerous modules.

    Args:
        name: the module name being imported.
        globals: the caller's globals (ignored).
        locals: the caller's locals (ignored).
        fromlist: the ``from X import Y`` list.
        level: relative import level (0 = absolute).

    Raises:
        SandboxError: if the top-level module is in ``_BLOCKED_MODULES``.
    """
    top = name.split(".")[0]
    if top in _BLOCKED_MODULES:
        raise SandboxError(
            f"Module '{top}' is blocked in the plugin sandbox "
            f"(ADR-021). Plugin code cannot import it."
        )
    # Delegate to the real __import__ for allowed modules.
    import builtins
    return builtins.__import__(name, globals, locals, fromlist, level)


def create_sandbox_namespace() -> dict[str, Any]:
    """Create a namespace for plugin code execution.

    The namespace has a restricted ``__import__`` that blocks dangerous
    modules. All other builtins are available (so plugins can use ``len``,
    ``range``, ``dict``, etc.).
    """
    import builtins

    namespace: dict[str, Any] = {
        "__builtins__": {
            # The restricted import.
            "__import__": _restricted_import,
            # Common builtins that plugins need.
            "abs": abs,
            "all": all,
            "any": any,
            "bool": bool,
            "bytes": bytes,
            "callable": callable,
            "chr": chr,
            "dict": dict,
            "dir": dir,
            "divmod": divmod,
            "enumerate": enumerate,
            "filter": filter,
            "float": float,
            "format": format,
            "frozenset": frozenset,
            "getattr": getattr,
            "hasattr": hasattr,
            "hash": hash,
            "hex": hex,
            "id": id,
            "int": int,
            "isinstance": isinstance,
            "issubclass": issubclass,
            "iter": iter,
            "len": len,
            "list": list,
            "map": map,
            "max": max,
            "min": min,
            "next": next,
            "object": object,
            "oct": oct,
            "ord": ord,
            "pow": pow,
            "print": print,
            "property": property,
            "range": range,
            "repr": repr,
            "reversed": reversed,
            "round": round,
            "set": set,
            "setattr": setattr,
            "slice": slice,
            "sorted": sorted,
            "staticmethod": staticmethod,
            "str": str,
            "sum": sum,
            "super": super,
            "tuple": tuple,
            "type": type,
            "vars": vars,
            "zip": zip,
            "True": True,
            "False": False,
            "None": None,
            "Exception": Exception,
            "ValueError": ValueError,
            "TypeError": TypeError,
            "KeyError": KeyError,
            "IndexError": IndexError,
            "AttributeError": AttributeError,
            "RuntimeError": RuntimeError,
            "NotImplementedError": NotImplementedError,
            "StopIteration": StopIteration,
        },
    }
    # Allow access to the real builtins module for the restricted import only.
    namespace["_builtins"] = builtins
    return namespace


def run_plugin(plugin_code: str, entry: str, *args: Any) -> Any:
    """Execute plugin code in a sandboxed namespace and call an entry point.

    Args:
        plugin_code: the Python source code of the plugin.
        entry: the name of the entry-point function in the plugin.
        *args: positional arguments to pass to the entry point.

    Returns:
        The return value of the entry-point function.

    Raises:
        SandboxError: if the plugin attempts to import a blocked module.
        Exception: any exception raised by the plugin code.
    """
    namespace = create_sandbox_namespace()
    exec(compile(plugin_code, "<plugin>", "exec"), namespace)
    entry_fn = namespace.get(entry)
    if entry_fn is None or not callable(entry_fn):
        raise SandboxError(f"Plugin does not define a callable '{entry}'")
    return entry_fn(*args)
