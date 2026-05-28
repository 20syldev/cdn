# gft - GitHub Fetch Tool

A lightweight command-line tool to fetch release information, list binary assets, and download from any GitHub project — without authentication.

## Installation

### Via curl (recommended)

```bash
curl -fsSL https://cdn.sylvain.sh/bash/gft@latest/install.sh | sh
```

### Manual installation

```bash
# Download and run the installer
./install.sh

# Or manually:
cp gft /usr/local/bin/
chmod +x /usr/local/bin/gft
```

## Usage

### Basic syntax

```bash
gft <user/repo> [tag] [options]
```

### Quick examples

```bash
# Get latest release info
gft cli/cli

# Get a specific version
gft nodejs/node v22.0.0

# List all releases
gft cli/cli --releases

# List all binary assets
gft cli/cli --assets

# Auto-detect the right binary for your OS
gft cli/cli --detect

# Download a specific asset
gft cli/cli --get "linux-amd64.deb"

# Download and verify checksum
gft cli/cli --get "linux-amd64.deb" --checksum

# Download, extract and install binary to PATH
gft cli/cli --install

# Get just the version number (for scripts)
VERSION=$(gft nodejs/node -q)

# Show release notes
gft cli/cli --notes

# JSON output
gft cli/cli --json

# Compare two releases
gft cli/cli v2.40.0..v2.50.0

# Include pre-releases when resolving latest
gft cli/cli --pre

# Open release page in browser
gft cli/cli --open
```

### Self-management

```bash
# Upgrade gft to the latest version
gft update

# Uninstall gft
gft delete

# Check if a newer version is available
gft --check-update
```

### Stash management

```bash
# List stashes in the current repo
gft stash list

# Show the diff of stash 1
gft stash show 1

# Drop stash 0 (with confirmation)
gft stash drop 0

# Delete all stashes without confirmation
gft stash clean -y
```

## Alias

`gfv` is available as an alias for `gft`.

## Features

- Automatic latest release detection
- Binary asset listing (`--assets`)
- Platform auto-detection (`--detect`) — finds the right binary for your OS/arch
- Direct asset download by pattern (`--get`)
- Checksum verification after download (`--checksum`)
- Binary install to PATH (`--install`)
- Release notes display (`--notes`)
- JSON output for scripting (`--json`)
- Quiet mode — just the version string (`-q`)
- Version comparison (`v1.0..v2.0`)
- All releases listing (`--releases`)
- Pre-release support (`--pre`)
- Open release page in browser (`--open`)
- Source archive download (`--source zip|tar`)
- Response cache with configurable TTL (`GFT_CACHE_TTL`)
- Self-update (`gft update`) and uninstall (`gft delete`)
- Git stash management (`gft stash list|show|drop|clean`)
- Works without GitHub authentication
- Transparent `gh` CLI fallback for private repos (when available)
- Respects `NO_COLOR` convention and pipe detection
- Bash and Zsh completion
- Manpage (`man gft`)

## How it works

gft scrapes GitHub release pages directly, so it:

- Requires **no authentication** (no token setup)
- Has **no API rate limit** issues (scraping, not API)
- Works on any machine with `curl` and `bash`

When `gh` CLI is installed and authenticated, gft uses it transparently as a fallback for private repositories and richer JSON output.

## Commands

| Command                  | Description                          |
| ------------------------ | ------------------------------------ |
| `gft update`             | Upgrade gft to the latest version    |
| `gft delete`             | Uninstall gft                        |
| `gft stash [action]`     | Manage git stashes (list, show, drop, clean) |

## Options

| Option                  | Description                                    |
| ----------------------- | ---------------------------------------------- |
| `-h, --help`            | Show help                                      |
| `-v, --version`         | Show version                                   |
| `--check-update`        | Check if a newer version of gft is available   |
| `--upgrade`             | Upgrade gft to the latest version              |
| `--releases, --list`    | List all available releases                    |
| `--assets`              | List release binary assets                     |
| `--detect`              | Auto-detect OS/arch, highlight matching assets |
| `--get <pattern>`       | Download asset matching pattern                |
| `--checksum, --verify`  | Verify SHA256 checksum after `--get`           |
| `--install`             | Download, extract and install binary to PATH   |
| `--notes`               | Show release notes                             |
| `--json`                | Output as JSON                                 |
| `-q, --quiet`           | Output version tag only                        |
| `--pre, --prerelease`   | Include pre-releases when resolving latest     |
| `--source zip\|tar`     | Download source archive non-interactively      |
| `--open`                | Open release page in browser                   |
| `--no-color`            | Disable colored output                         |
| `--no-cache`            | Bypass response cache                          |
| `--clear-cache`         | Clear all cached responses                     |

## Environment variables

| Variable        | Description                                           |
| --------------- | ----------------------------------------------------- |
| `NO_COLOR`      | Set to any value to disable colors                    |
| `GITHUB_TOKEN`  | Set for higher API rate limits (5000/hour vs 60/hour) |
| `GFT_CACHE_TTL` | Cache TTL in seconds (default: 300)                   |

## Output example

```
→ Looking up user/repo (latest)...

✓ Latest release: vX.Y.Z

- Repository:  user/repo
- Tag:         vX.Y.Z

> Links
  ├─ Repository:   https://github.com/user/repo
  ├─ Releases:     https://github.com/user/repo/releases
  └─ This release: https://github.com/user/repo/releases/tag/vX.Y.Z

> Source Archives
  ├─ ZIP:    https://github.com/user/repo/archive/refs/tags/vX.Y.Z.zip
  └─ TAR.GZ: https://github.com/user/repo/archive/refs/tags/vX.Y.Z.tar.gz

> Quick Commands
  ├─ curl -LO "https://github.com/user/repo/archive/refs/tags/vX.Y.Z.zip"
  ├─ curl -LO "https://github.com/user/repo/archive/refs/tags/vX.Y.Z.tar.gz"
  └─ git clone --depth 1 --branch vX.Y.Z https://github.com/user/repo.git

→ Download? (z)ip, (t)ar.gz, (n)o [n]:
```

## Why gft over gh cli?

|                         | gft                  | gh cli                            |
| ----------------------- | -------------------- | --------------------------------- |
| Authentication required | No                   | Yes                               |
| Setup needed            | None                 | `gh auth login`                   |
| Binary asset listing    | `--assets` (no auth) | `gh release view` (auth required) |
| Platform auto-detect    | `--detect`           | Not available                     |
| Pattern download        | `--get pattern`      | Manual URL                        |
| Dependencies            | curl, bash           | Go binary (~50MB)                 |
| Size                    | ~15KB                | ~50MB                             |

## Prerequisites

- `curl` (for HTTP requests)
- `bash` (>= 4.0)
- Internet connection
- Optional: `gh` CLI for private repos and richer data

## Troubleshooting

### Repository not found

- Check the spelling of username and repository
- Make sure the repository is public (or use `gh auth login` for private repos)

### No release found

- The repository may not have any releases
- Visit `https://github.com/username/repository/releases` to verify

### Download error

- Check your internet connection
- The specified tag may not exist
