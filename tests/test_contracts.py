from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read_text(rel_path: str) -> str:
    return (ROOT / rel_path).read_text(encoding="utf-8")


def gd_functions(gd_text: str) -> set[str]:
    return set(re.findall(r"^\s*func\s+([A-Za-z0-9_]+)\s*\(", gd_text, flags=re.MULTILINE))


def parse_connections(tscn_text: str) -> list[dict[str, str]]:
    rows = []
    pattern = re.compile(
        r'^\[connection\s+signal="(?P<signal>[^"]+)"\s+from="(?P<from>[^"]+)"\s+to="(?P<to>[^"]+)"\s+method="(?P<method>[^"]+)"\]$',
        flags=re.MULTILINE,
    )
    for match in pattern.finditer(tscn_text):
        rows.append(match.groupdict())
    return rows


class TestMainSceneContracts(unittest.TestCase):
    def test_main_scene_has_required_nodes(self) -> None:
        tscn = read_text("scenes/main/Main.tscn")
        required = [
            'name="Main"',
            'name="Player"',
            'name="HUD"',
            'name="Menu"',
            'name="SpawnTimer"',
            'name="Asteroids"',
            'name="Bullets"',
            'name="Pickups"',
            'name="SpawnController"',
            'name="SaveSystem"',
        ]
        for marker in required:
            self.assertIn(marker, tscn, f"Missing scene node marker: {marker}")

    def test_main_scene_connections_target_existing_handlers(self) -> None:
        tscn = read_text("scenes/main/Main.tscn")
        main_funcs = gd_functions(read_text("scripts/main.gd"))
        hud_funcs = gd_functions(read_text("scripts/hud.gd"))

        conns = parse_connections(tscn)
        self.assertGreaterEqual(len(conns), 4, "Expected core signal wiring in Main.tscn")

        for conn in conns:
            if conn["to"] == ".":
                self.assertIn(
                    conn["method"],
                    main_funcs,
                    f'Missing main handler for connection: {conn}',
                )
            elif conn["to"] == "HUD":
                self.assertIn(
                    conn["method"],
                    hud_funcs,
                    f'Missing HUD handler for connection: {conn}',
                )


class TestGameplayConfigContracts(unittest.TestCase):
    def test_save_system_uses_user_path(self) -> None:
        save_gd = read_text("scripts/systems/save_system.gd")
        self.assertIn('const SAVE_PATH := "user://save.cfg"', save_gd)
        self.assertNotIn("res://data/save.cfg", save_gd)

    def test_spawn_constants_sane(self) -> None:
        globals_gd = read_text("scripts/globals.gd")

        def const(name: str) -> float:
            match = re.search(rf"const\s+{name}\s*:=\s*([0-9.]+)", globals_gd)
            self.assertIsNotNone(match, f"Missing constant: {name}")
            return float(match.group(1))  # type: ignore[arg-type]

        start = const("SPAWN_INTERVAL_START")
        minimum = const("SPAWN_INTERVAL_MIN")
        step = const("SPAWN_INTERVAL_STEP")
        score_step = const("SCORE_PER_RAMP_STEP")

        self.assertGreater(start, 0.0)
        self.assertGreater(minimum, 0.0)
        self.assertGreaterEqual(start, minimum)
        self.assertGreater(step, 0.0)
        self.assertGreater(score_step, 0.0)

    def test_split_logic_has_terminal_tier_guard(self) -> None:
        main_gd = read_text("scripts/main.gd")
        self.assertIn("func _spawn_split_asteroids", main_gd)
        self.assertIn("if size_tier >= 2:", main_gd)
        self.assertIn("for i in split_count:", main_gd)


if __name__ == "__main__":
    unittest.main(verbosity=2)
