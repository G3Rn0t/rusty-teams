#!/bin/sh
# Chromium's setuid sandbox helper is replaced under Flatpak; zypak owns the nested sandbox.
echo "stub sandbox ignoring: $*" >&2
exit 1
