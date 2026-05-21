# Changelog

## v1.0.0-beta.1

First beta release of Terminal Beauty.

### Added

- Visual gallery for 8 curated terminal themes.
- Interactive custom style brief builder in the gallery.
- macOS Apple Terminal as the default supported path.
- Starship prompt configuration for each theme.
- zsh, fish, iTerm2, and Apple Terminal theme assets.
- Apple Terminal profile auto-import and default profile setup.
- Safe timestamped backups before every install.
- Rollback script for restoring backed-up config.
- `doctor.sh` for checking local Terminal Beauty status.
- Tests for backup, rollback, install, Apple Terminal profiles, custom theme lookup, and theme assets.

### Notes

- Apple Terminal windows that are already open may keep their old profile.
  Open a new window, or quit and reopen Terminal, to see the selected profile.
- Starship is recommended for the full prompt effect.
  Apple Terminal profiles control window colors; Starship controls the prompt.
