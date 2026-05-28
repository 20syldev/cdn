# mn - Personal Dynamic Manual

An interactive terminal menu for managing SSH connections, GitHub repositories, Bash aliases, shell functions, and personal documentation — all in one place.

## Installation

### Via curl (recommended)

```bash
curl -fsSL https://cdn.sylvain.sh/bash/mn@latest/install.sh | sh
```

### Manual installation

```bash
./install.sh
```

### Update from local repo

```bash
./update.sh
```

Or manually:

```bash
cp -r mn lib/ modules/ lang/ ~/.config/mn/ && chmod +x ~/.config/mn/mn
```

## Usage

### Open main menu

```bash
mn
```

### Direct module access

```bash
mn conn        # SSH/Custom connections
mn repos       # GitHub repositories
mn alias       # Bash aliases
mn funcs       # Shell functions
mn docs        # Internal documentation
mn config      # Configuration
mn help        # Help
```

Short aliases are also supported: `mn r` (repos), `mn a` (alias), `mn f` (funcs), `mn d` (docs), `mn c` (config), `mn h` (help).

## Navigation

| Key        | Action                  |
| ---------- | ----------------------- |
| `↑` / `k` | Move up                 |
| `↓` / `j` | Move down               |
| `←` / `→` | Previous / next page    |
| `Enter`    | Select / execute        |
| `e`        | Edit selected entry     |
| `d`        | Delete selected entry   |
| `v`        | View details            |
| `r`        | Return to main menu     |
| `q`        | Quit                    |

## Features

- **SSH/Custom connections** — store servers with label, IP, connection type (SSH or custom command) and optional password, connect in one keystroke
- **GitHub repos** — create aliases to local directories and open them in your configured editor
- **Bash aliases** — add, edit, delete aliases with automatic sync to `~/.bash_aliases`
- **Shell functions** — manage Bash functions with sync to `~/.bash_functions`
- **Documentation** — read Markdown files directly in the terminal
- **Configuration** — edit config files and reload your environment on the fly

## File structure

```
~/.config/mn/
├── mn              # Main entry point
├── lib/
│   ├── core.sh        # Config, colors, utilities
│   ├── crud.sh        # Generic CRUD engine
│   ├── ui.sh          # Menu rendering and input handling
│   ├── module.sh      # Module registry
│   └── dat.sh         # Data file helpers
├── modules/
│   ├── connexions.sh  # SSH module
│   ├── repos.sh       # Repos module
│   ├── alias.sh       # Alias module
│   ├── funcs.sh       # Functions module
│   ├── docs.sh        # Documentation module
│   └── config.sh      # Configuration module
├── data/
│   ├── connexions.dat
│   ├── repos.dat
│   ├── aliases.dat
│   └── functions.dat
└── docs/              # Internal Markdown documentation
```

## Data format

All data is stored in `.dat` files using `:::` as separator. Files are sorted alphabetically and can be edited manually.

**connexions.dat**
```
label:::ip:::description:::type:::password:::cmd
prod:::user@192.168.1.10:::Production server:::ssh:::
backup:::user@192.168.1.20:::Backup server:::custom::::rsync -avz user@192.168.1.20:/data/ ~/backups/
```

**repos.dat**
```
name:::path:::description
myapp:::~/Projects/myapp:::Main application
api:::~/Projects/api:::REST API
```

**aliases.dat**
```
name:::command:::description
c:::clear:::Clear terminal
ll:::ls -lah:::Detailed listing
```

**functions.dat**
```
name:::code:::description
mkcd:::mkdir -p "$1" && cd "$1";:::Create directory and move into it
```

## Customization

### Change default editor

Choose at install, or via `mn config` → **Change editor**. Presets: `vi`, `vim`, `nano`, `zed`, `code -n` or any custom command. Setting stored in `~/.config/mn/.editor`.

### Modify colors

Colors are defined in `~/.config/mn/lib/core.sh`.

### Add internal documentation

Drop a Markdown file into `~/.config/mn/docs/` — it will appear automatically in the `docs` module.

## Prerequisites

- `bash` (>= 4.0)
- `curl` (for installation)
- Internet connection