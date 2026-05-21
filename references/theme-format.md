# Theme directory format

Every theme is a directory under `themes/<name>/` with exactly six files.

## theme.md
Human-readable metadata. Sections:
- `# <Display Name>` heading
- One-paragraph style description (mood, who it suits)
- A `## Palette` section listing 18 hex colors as a markdown table:
  bg, fg, then ansi 0-15 (black, red, green, yellow, blue, magenta, cyan,
  white, bright variants in the same order).

## zsh.sh
A snippet sourced from `.zshrc`. Sets `LSCOLORS`/`LS_COLORS` and, if the
`zsh-syntax-highlighting` plugin is present, palette-matched highlight
colors. Sources Starship if installed. Must be idempotent.

## starship.toml
A complete Starship configuration using the theme palette for prompt
module colors. Drop-in replacement for `~/.config/starship.toml`.

## iterm.itermcolors
An iTerm2 color preset (plist XML). Contains `Ansi 0 Color` .. `Ansi 15
Color`, plus `Background Color`, `Foreground Color`, `Cursor Color`,
`Cursor Text Color`, `Selection Color`, `Selected Text Color`, `Bold
Color`, `Link Color`. Each is a dict of `Red/Green/Blue Component` floats.

### Hex to plist float conversion
For hex `#RRGGBB`: each component float = decimal(channel) / 255.
Example: `#1a1b26` -> R=26/255=0.10196, G=27/255=0.10588, B=38/255=0.14902.
Use at least 5 decimal places.

## <theme-slug>.terminal
An Apple Terminal profile (plist XML). Contains `ANSIBlackColor`,
`ANSIRedColor`, `ANSIGreenColor`, `ANSIYellowColor`, `ANSIBlueColor`,
`ANSIMagentaColor`, `ANSICyanColor`, `ANSIWhiteColor`, their bright variants,
plus `BackgroundColor`, `TextColor`, `TextBoldColor`, `CursorColor`, and
`SelectionColor`.

Generate these profiles with `scripts/generate_terminal_profiles.py` so the
color values are valid macOS archived `NSColor` data.

The filename must include the theme slug, such as `catppuccin.terminal`.
Apple Terminal may use the imported filename as the visible profile name.

## fish.fish
A snippet for `~/.config/fish/conf.d/`. Sets fish color variables
(`fish_color_*`) from the palette and sources Starship if installed.
