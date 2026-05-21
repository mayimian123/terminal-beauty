# Security and Local Config Safety

Terminal Beauty modifies local terminal configuration. It is designed to be
reversible, but beta users should understand what changes before running it.

## What May Be Modified

- `~/.zshrc`
- `~/.config/starship.toml`
- `~/.config/fish/conf.d/terminal-beauty.fish`
- Apple Terminal preferences: `com.apple.Terminal`
- iTerm2 preferences when iTerm2 is present: `com.googlecode.iterm2`
- `~/.terminal-beauty/`, where selected theme files are copied

## Backup Policy

Every install run creates a timestamped backup first:

```bash
~/.terminal-beauty-backups/<timestamp>/
```

Backups are never deleted by Terminal Beauty.

## Rollback

List backups:

```bash
scripts/rollback.sh
```

Restore one backup:

```bash
scripts/rollback.sh ~/.terminal-beauty-backups/<timestamp>
```

## Tool Installation

Terminal Beauty may recommend Starship for the full prompt effect:

```bash
brew install starship
```

It should not install tools without explicit user consent.

## Reporting Issues

For beta testing, please report:

- macOS version
- Terminal app used
- selected theme
- command run
- backup path printed by the installer
- what looked wrong or confusing
