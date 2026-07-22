#!/usr/bin/env bash
# URL Picker: extract URLs from a Herdr pane and open the selected one.
#
# Usage: picker.sh [pane_id]
#   pane_id  Target pane to read. When omitted, the focused pane is
#            resolved from HERDR_PLUGIN_CONTEXT_JSON (requires jq).
#
# Environment:
#   URL_PICKER_NO_FZF=1      Force the numbered-list fallback UI.
#   URL_PICKER_PRINT_ONLY=1  Print the selected URL instead of opening it.
set -euo pipefail

herdr_bin="${HERDR_BIN_PATH:-herdr}"
lines="${URL_PICKER_LINES:-200}"

# Keep the popup readable before it closes on exit.
pause_if_tty() {
  if [[ -t 0 && -t 1 ]]; then
    printf 'Press any key to close...'
    read -rsn1 || true
  fi
}

die() {
  printf 'url-picker: %s\n' "$1" >&2
  pause_if_tty
  exit 1
}

# --- Resolve the target pane -------------------------------------------------
pane_id="${1:-}"

if [[ -z "$pane_id" && -n "${HERDR_PLUGIN_CONTEXT_JSON:-}" ]]; then
  command -v jq >/dev/null 2>&1 || die "jq is required to read the plugin context"
  pane_id="$(jq -r '(.pane.id // .focused_pane.id // .pane_id // .focused_pane_id // empty)' \
    <<<"$HERDR_PLUGIN_CONTEXT_JSON")"
fi

if [[ -z "$pane_id" ]]; then
  pane_id="${HERDR_PANE_ID:-}"
fi

[[ -n "$pane_id" ]] || die "could not determine the target pane id"

# --- Extract URLs ------------------------------------------------------------
content="$("$herdr_bin" pane read "$pane_id" --source recent-unwrapped --lines "$lines")" ||
  die "failed to read pane $pane_id"

# Match http(s) URLs, trim common trailing punctuation, list newest first,
# dedupe keeping the most recent occurrence.
urls="$(printf '%s\n' "$content" |
  grep -Eo 'https?://[^[:space:]<>"'\''`]+' |
  sed -E 's/[]}),.;:!?]+$//' |
  awk 'NF { lines[++n] = $0 } END { for (i = n; i >= 1; i--) if (!seen[lines[i]]++) print lines[i] }')" || true

if [[ -z "$urls" ]]; then
  printf 'No URLs found in pane %s.\n' "$pane_id"
  pause_if_tty
  exit 0
fi

# --- Select a URL ------------------------------------------------------------
selected=""
if [[ -z "${URL_PICKER_NO_FZF:-}" && -t 0 ]] && command -v fzf >/dev/null 2>&1; then
  selected="$(printf '%s\n' "$urls" | fzf --prompt='url> ' --no-multi)" || {
    # Cancelled (Esc / ctrl-c inside fzf).
    exit 0
  }
else
  i=1
  while IFS= read -r url; do
    printf '%3d) %s\n' "$i" "$url"
    i=$((i + 1))
  done <<<"$urls"
  total=$((i - 1))
  printf 'Select a URL [1-%d] (empty to cancel): ' "$total"
  read -r choice || choice=""
  [[ -n "$choice" ]] || exit 0
  [[ "$choice" =~ ^[0-9]+$ ]] || die "invalid selection: $choice"
  ((choice >= 1 && choice <= total)) || die "selection out of range: $choice"
  selected="$(printf '%s\n' "$urls" | sed -n "${choice}p")"
fi

[[ -n "$selected" ]] || exit 0

# --- Open the URL ------------------------------------------------------------
if [[ -n "${URL_PICKER_PRINT_ONLY:-}" ]]; then
  printf '%s\n' "$selected"
  exit 0
fi

case "$(uname -s)" in
  Darwin) open "$selected" ;;
  Linux) xdg-open "$selected" >/dev/null 2>&1 ;;
  *) die "unsupported platform: $(uname -s)" ;;
esac
