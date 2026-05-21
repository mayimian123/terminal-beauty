#!/usr/bin/env python3
"""Generate Apple Terminal .terminal profiles from theme.md palettes."""

from __future__ import annotations

import plistlib
import re
from pathlib import Path

from AppKit import NSColor
from Foundation import NSKeyedArchiver


ROOT = Path(__file__).resolve().parents[1]
THEMES = ROOT / "themes"

PALETTE_KEYS = [
    ("black", "ANSIBlackColor"),
    ("red", "ANSIRedColor"),
    ("green", "ANSIGreenColor"),
    ("yellow", "ANSIYellowColor"),
    ("blue", "ANSIBlueColor"),
    ("magenta", "ANSIMagentaColor"),
    ("cyan", "ANSICyanColor"),
    ("white", "ANSIWhiteColor"),
    ("bright black", "ANSIBrightBlackColor"),
    ("bright red", "ANSIBrightRedColor"),
    ("bright green", "ANSIBrightGreenColor"),
    ("bright yellow", "ANSIBrightYellowColor"),
    ("bright blue", "ANSIBrightBlueColor"),
    ("bright magenta", "ANSIBrightMagentaColor"),
    ("bright cyan", "ANSIBrightCyanColor"),
    ("bright white", "ANSIBrightWhiteColor"),
]


def parse_theme(theme_md: Path) -> tuple[str, dict[str, str]]:
    title = None
    palette: dict[str, str] = {}

    for line in theme_md.read_text(encoding="utf-8").splitlines():
        if line.startswith("# ") and title is None:
            title = line[2:].strip()
            continue

        match = re.match(r"\|\s*([^|]+?)\s*\|\s*(#[0-9a-fA-F]{6})\s*\|", line)
        if match:
            palette[match.group(1).strip().lower()] = match.group(2).lower()

    if not title:
        raise ValueError(f"No title found in {theme_md}")

    required = {"bg", "fg", *(key for key, _ in PALETTE_KEYS)}
    missing = sorted(required - set(palette))
    if missing:
        raise ValueError(f"{theme_md} is missing palette keys: {', '.join(missing)}")

    return title, palette


def nscolor_data(hex_color: str) -> bytes:
    raw = hex_color.lstrip("#")
    red = int(raw[0:2], 16) / 255
    green = int(raw[2:4], 16) / 255
    blue = int(raw[4:6], 16) / 255
    color = NSColor.colorWithCalibratedRed_green_blue_alpha_(red, green, blue, 1.0)
    data, error = NSKeyedArchiver.archivedDataWithRootObject_requiringSecureCoding_error_(
        color, False, None
    )
    if error is not None:
        raise RuntimeError(f"Failed to archive NSColor {hex_color}: {error}")
    return bytes(data)


def build_profile(slug: str, title: str, palette: dict[str, str]) -> dict[str, object]:
    profile: dict[str, object] = {
        "name": f"Terminal Beauty - {title}",
        "type": "Window Settings",
        "ProfileCurrentVersion": 2.07,
        "BackgroundColor": nscolor_data(palette["bg"]),
        "TextColor": nscolor_data(palette["fg"]),
        "TextBoldColor": nscolor_data(palette["bright white"]),
        "CursorColor": nscolor_data(palette["fg"]),
        "SelectionColor": nscolor_data(palette["bright black"]),
        "CursorType": 0,
        "FontAntialias": True,
        "ShowWindowSettingsNameInTitle": False,
        "columnCount": 100,
        "rowCount": 32,
        "shellExitAction": 2,
    }

    for palette_key, terminal_key in PALETTE_KEYS:
        profile[terminal_key] = nscolor_data(palette[palette_key])

    return profile


def main() -> None:
    theme_dirs = [
        theme_dir
        for theme_dir in sorted(THEMES.iterdir())
        if theme_dir.is_dir() and not theme_dir.name.startswith("_")
    ]
    custom_root = THEMES / "_custom"
    if custom_root.exists():
        theme_dirs.extend(
            theme_dir for theme_dir in sorted(custom_root.iterdir()) if theme_dir.is_dir()
        )

    for theme_dir in theme_dirs:
        title, palette = parse_theme(theme_dir / "theme.md")
        profile = build_profile(theme_dir.name, title, palette)
        output = theme_dir / f"{theme_dir.name}.terminal"
        output.write_bytes(
            plistlib.dumps(profile, fmt=plistlib.FMT_XML, sort_keys=False)
        )
        print(output.relative_to(ROOT))


if __name__ == "__main__":
    main()
