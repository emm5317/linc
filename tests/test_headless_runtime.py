from __future__ import annotations

import os
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def find_godot() -> str | None:
    env_bin = os.environ.get("GODOT_BIN")
    if env_bin and Path(env_bin).exists():
        return env_bin

    candidates = [
        Path(r"C:\Users\Admin\Downloads\Godot_v4.6-stable_win64.exe\Godot_v4.6-stable_win64_console.exe"),
        Path(r"C:\Users\Admin\Downloads\Godot_v4.6-stable_win64.exe"),
        Path(r"C:\Users\Admin\Downloads\Godot_v4.6-stable_win64.exe\Godot_v4.6-stable_win64.exe"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return str(candidate)
    return None


class TestHeadlessRuntimeSmoke(unittest.TestCase):
    def test_headless_project_boot(self) -> None:
        project_file = ROOT / "project.godot"
        if not project_file.exists():
            self.skipTest("project.godot not found; runtime smoke test unavailable")

        godot = find_godot()
        if not godot:
            self.skipTest("Godot executable not found; set GODOT_BIN to run runtime smoke")

        result = subprocess.run(
            [godot, "--headless", "--path", str(ROOT), "--quit"],
            capture_output=True,
            text=True,
            timeout=30,
        )
        self.assertEqual(
            result.returncode,
            0,
            msg=f"Godot headless boot failed.\nSTDOUT:\n{result.stdout}\nSTDERR:\n{result.stderr}",
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
