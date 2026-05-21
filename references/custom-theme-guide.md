# Generating a custom theme

Use this when the user wants a look not covered by the curated library
(e.g. "warm retro", "high-contrast neon", "matches my brand colors").

## Steps

1. **Clarify the brief.** Ask for: light or dark, overall mood, any
   must-have colors. Keep it to one or two questions.

2. **Design an 18-colour palette.** Produce hex values for: bg, fg, and
   ansi 0-15 (black, red, green, yellow, blue, magenta, cyan, white, then
   the eight bright variants).
   - Background and foreground must meet at least a 7:1 contrast ratio.
   - The six accent colours (red/green/yellow/blue/magenta/cyan) must each
     be clearly distinguishable from one another and readable on bg.
   - Bright variants are lighter/more saturated versions of the base.

3. **Create the theme directory.** Write the six files into
   `themes/_custom/<slug>/`, following `references/theme-format.md`
   exactly — the same structure as `themes/tokyo-night/`.

4. **Generate Apple Terminal profile data.** Run
   `scripts/generate_terminal_profiles.py` after writing `theme.md` so the
   custom directory gets `<slug>.terminal`.

5. **Apply it** through the normal workflow in SKILL.md (backup first).

## Notes
- `themes/_custom/` is git-ignored and may be overwritten freely.
- If the user later likes a custom theme enough to keep, they can move
  the directory out of `_custom/` and rename it.
