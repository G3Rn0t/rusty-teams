#!/bin/bash
# Launch the Flatpak extra-data Chrome through zypak so Chromium keeps its
# nested sandbox. Arguments from rusty-teams (debug port, profile, URLs) pass through.
set -euo pipefail
export CHROME_VERSION_EXTRA=stable
exec zypak-wrapper /app/extra/chrome "$@"
