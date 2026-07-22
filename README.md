# herdr-url-picker

English | [日本語](README.ja.md)

A plugin for [Herdr](https://herdr.dev). It extracts URLs (`http://` / `https://`) from the content of the focused pane, shows them as a list, and opens the selected URL in your browser — the Herdr equivalent of tmux urlview-style plugins.

## Features

- Extracts URLs from the last 200 lines (unwrapped) of the focused pane
- Deduplicates while preserving the order of appearance
- Incremental-search selection UI with `fzf` when available, with a numbered-list fallback
- Opens the selected URL with `open` on macOS or `xdg-open` on Linux
- Launches as a session-modal popup, so it never disturbs your pane layout

## Requirements

- Herdr 0.7.5 or later (macOS / Linux)
- `jq` (required; used to parse the plugin context JSON)
- `fzf` (optional; provides a nicer selection UI)

## Installation

```bash
herdr plugin install chouxcreams/herdr-url-picker
```

For local development or trial, check out the repository and link it:

```bash
git clone https://github.com/chouxcreams/herdr-url-picker.git
herdr plugin link /path/to/herdr-url-picker
```

Verify the registration:

```bash
herdr plugin list
herdr plugin action list --plugin chouxcreams.url-picker
```

## Keybinding

Add the following to your Herdr config to open the picker with a single key:

```toml
[[keys.command]]
key = "prefix+u"
type = "plugin_action"
command = "chouxcreams.url-picker.pick"
description = "pick URL from focused pane"
```

## Usage

Press the keybinding (or run `herdr plugin action invoke chouxcreams.url-picker.pick`) to open a popup listing the URLs extracted from the focused pane. Selecting one opens it in your default browser. If no URLs are found, a message is shown and the popup exits.

## Running the script directly (for debugging)

`picker.sh` accepts a pane ID as the first argument:

```bash
# Find pane IDs
herdr pane list --workspace "$HERDR_WORKSPACE_ID"

# Inspect the extracted list and select non-interactively via stdin
echo 1 | URL_PICKER_PRINT_ONLY=1 bash picker.sh <pane_id>
```

Environment variables:

| Variable | Effect |
| --- | --- |
| `URL_PICKER_NO_FZF=1` | Use the numbered-list fallback even when fzf is available |
| `URL_PICKER_PRINT_ONLY=1` | Print the selected URL to stdout instead of opening it |
| `URL_PICKER_LINES` | Number of lines to read (default: 200) |

## Uninstall

```bash
herdr plugin uninstall chouxcreams.url-picker   # if installed
herdr plugin unlink chouxcreams.url-picker      # if linked
```
