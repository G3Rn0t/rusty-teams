#!/bin/sh
# Extract Google Chrome from the downloaded .deb into /app/extra (Flatpak extra-data).
set -e
bsdtar -Oxf chrome.deb data.tar.xz |
  bsdtar -xf - \
    --strip-components=4 \
    --exclude='./opt/google/chrome/nacl*' \
    ./opt/google/chrome
rm -f chrome.deb
install -Dm755 /app/bin/stub_sandbox chrome-sandbox
