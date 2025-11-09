#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(pwd)
CEDEV_DIR="$ROOT_DIR/CEdev"
BIN_DIR="$CEDEV_DIR/bin"

mkdir -p "$BIN_DIR"

EZ80_URL="https://github.com/CE-Programming/llvm-project/releases/download/nightly/ez80-clang-link_ubuntu_nightly.zip"
rm -f /tmp/ez80.zip && curl -L "$EZ80_URL" -o /tmp/ez80.zip
7z x -o"$BIN_DIR" /tmp/ez80.zip > /dev/null

FASMG_DL_PAGE="https://flatassembler.net/download.php"
HTML=$(curl -fsSL "$FASMG_DL_PAGE")
HREF=$(echo "$HTML" | grep -oE 'href="[^"]*"' | sed 's/href=\"//;s/\"//' | grep -E '^flat_(.*)\.zip$' | head -n1)
if [[ -z "${HREF:-}" ]]; then
  exit 1
fi
FASMG_URL="https://flatassembler.net/${HREF}"
curl -fsSL "$FASMG_URL" -o /tmp/fasmg.zip
7z x -o"$ROOT_DIR/fasmg" /tmp/fasmg.zip > /dev/null
cp "$ROOT_DIR/fasmg/source/linux/x64/fasmg" "$BIN_DIR/fasmg"
chmod +x "$BIN_DIR/fasmg"

make -j"$(nproc)" V=1
make -j"$(nproc)" libs V=1
make -j"$(nproc)" libs-zip V=1

make -j"$(nproc)" -C "$ROOT_DIR" install V=1 PREFIX="$ROOT_DIR" DESTDIR="$ROOT_DIR"

cd "$ROOT_DIR"
zip -r9 CEdev-local.zip CEdev >/dev/null
echo "$ROOT_DIR/CEdev-local.zip"
