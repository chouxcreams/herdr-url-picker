#!/usr/bin/env bash
# Entry point for the "pick" action: opens the picker popup.
set -euo pipefail

exec "${HERDR_BIN_PATH:?HERDR_BIN_PATH is not set}" plugin pane open \
  --plugin chouxcreams.url-picker \
  --entrypoint picker
