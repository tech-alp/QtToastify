"""Exercise build_wasm.sh packaging with prepared linker outputs, without an SDK."""

import os
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "build_wasm.sh"
REQUIRED_PLUGINS = (
    "ToastifyPlugin", "Toastify_StylePlugin", "Merce_ThemePlugin",
    "Merce_FoundationPlugin", "Merce_StylePlugin", "Merce_ControlsPlugin",
    "Qt_labs_StyleKitPlugin",
)
OUTPUTS = ("QtToastifyPlayground.js", "QtToastifyPlayground.wasm",
           "qtloader.js", "qtlogo.svg")


class WasmPackagingTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="toastify wasm ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.build = self.root / "build"
        self.output = self.build / "playground"
        self.output.mkdir(parents=True)
        self.wasm = self.output / "QtToastifyPlayground.wasm"
        self.wasm.write_bytes(b"\0asm\n" + "\n".join(REQUIRED_PLUGINS).encode())
        for name in OUTPUTS:
            if name != self.wasm.name:
                (self.output / name).write_text("fixture " + name)
        (self.output / "QtToastifyPlayground.html").write_text(
            "<!doctype html>\n<html><head>\n</head><body>demo</body></html>\n")
        for name in ("emsdk/emsdk_env.sh", "qt/bin/qt-cmake",
                     "qt/lib/cmake/Qt6/qt.toolchain.cmake",
                     "host/lib/cmake/Qt6/Qt6Config.cmake"):
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(":\n")
        # Only stub compilation. Run the real script, plugin validation and
        # real CMake file operations on the prepared linker output fixtures.
        real_cmake = shutil.which("cmake")
        self.assertIsNotNone(real_cmake, "CMake is required for packaging tests")
        tools = self.root / "bin"
        tools.mkdir()
        wrapper = tools / "cmake"
        wrapper.write_text('#!/bin/sh\nif [ "$1" = "--build" ]; then exit 0; fi\n'
                           + "exec " + shlex.quote(real_cmake) + ' "$@"\n')
        wrapper.chmod(0o755)
        self.env = dict(os.environ, EMSDK_ROOT=str(self.root / "emsdk"),
                        QT_WASM_PATH=str(self.root / "qt"),
                        QT_HOST_PATH=str(self.root / "host"),
                        BUILD_DIR=str(self.build),
                        PATH=str(tools) + os.pathsep + os.environ["PATH"])

    def run_packaging(self):
        return subprocess.run(["bash", str(SCRIPT)], env=self.env,
                              capture_output=True, text=True, timeout=30)

    def test_packages_without_unused_vector_image_plugins(self):
        result = self.run_packaging()
        self.assertEqual(result.returncode, 0, result.stderr)
        site = self.build / "site"
        self.assertIn('rel="icon" href="qtlogo.svg"', (site / "index.html").read_text())
        for name in OUTPUTS:
            self.assertEqual((site / name).read_bytes(), (self.output / name).read_bytes())

    def test_rejects_each_missing_required_plugin(self):
        for missing in REQUIRED_PLUGINS:
            with self.subTest(plugin=missing):
                self.wasm.write_text("\n".join(p for p in REQUIRED_PLUGINS if p != missing))
                result = self.run_packaging()
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("Missing static QML plugin in WebAssembly output: " + missing,
                              result.stderr)
                self.assertFalse((self.build / "site").exists())

    def test_rejects_missing_output(self):
        (self.output / "qtloader.js").unlink()
        result = self.run_packaging()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Missing WebAssembly output:", result.stderr)
        self.assertFalse((self.build / "site").exists())

    def test_rejects_empty_output(self):
        self.wasm.write_bytes(b"")
        result = self.run_packaging()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Missing WebAssembly output:", result.stderr)
        self.assertFalse((self.build / "site").exists())


if __name__ == "__main__":
    unittest.main()
