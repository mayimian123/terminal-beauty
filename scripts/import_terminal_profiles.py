#!/usr/bin/env python3
"""Import Terminal Beauty profiles into Apple Terminal preferences."""

from __future__ import annotations

import argparse
import plistlib
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
THEMES = ROOT / "themes"


def curated_profiles() -> dict[str, dict[str, object]]:
    profiles: dict[str, dict[str, object]] = {}
    for theme_dir in sorted(THEMES.iterdir()):
        if not theme_dir.is_dir() or theme_dir.name.startswith("_"):
            continue
        profile_path = theme_dir / f"{theme_dir.name}.terminal"
        if not profile_path.exists():
            continue
        profile = plistlib.loads(profile_path.read_bytes())
        profile["name"] = theme_dir.name
        profiles[theme_dir.name] = profile
    return profiles


def load_preferences(path: Path | None) -> dict[str, object]:
    if path is not None:
        if path.exists():
            return plistlib.loads(path.read_bytes())
        return {}

    with tempfile.NamedTemporaryFile(suffix=".plist") as exported:
        subprocess.run(
            ["defaults", "export", "com.apple.Terminal", exported.name],
            check=True,
            stdout=subprocess.DEVNULL,
        )
        return plistlib.loads(Path(exported.name).read_bytes())


def save_preferences(preferences: dict[str, object], path: Path | None) -> None:
    data = plistlib.dumps(preferences, fmt=plistlib.FMT_XML, sort_keys=False)
    if path is not None:
        path.write_bytes(data)
        return

    with tempfile.NamedTemporaryFile(suffix=".plist") as updated:
        Path(updated.name).write_bytes(data)
        subprocess.run(
            ["defaults", "import", "com.apple.Terminal", updated.name],
            check=True,
            stdout=subprocess.DEVNULL,
        )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--set-default", metavar="THEME")
    parser.add_argument("--prefs-plist", type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()

    profiles = curated_profiles()
    if not profiles:
        raise SystemExit("No Apple Terminal profiles found under themes/")

    if args.set_default and args.set_default not in profiles:
        raise SystemExit(f"Unknown Apple Terminal profile: {args.set_default}")

    preferences = load_preferences(args.prefs_plist)
    window_settings = preferences.setdefault("Window Settings", {})
    if not isinstance(window_settings, dict):
        raise SystemExit("Invalid Apple Terminal preferences: Window Settings is not a dict")

    for name, profile in profiles.items():
        window_settings[name] = profile

    if args.set_default:
        preferences["Default Window Settings"] = args.set_default
        preferences["Startup Window Settings"] = args.set_default

    save_preferences(preferences, args.prefs_plist)

    print("Imported Apple Terminal profiles:")
    for name in sorted(profiles):
        marker = " (default)" if name == args.set_default else ""
        print(f"  - {name}{marker}")


if __name__ == "__main__":
    main()
