#!/usr/bin/env bash
set -euo pipefail

DROP="$HOME/Downloads"
REPO_ZIP="${REPO_ZIP:-https://github.com/ElijahDaw/Gui/archive/refs/heads/main.zip}"
REPO_URL="${REPO_URL:-https://github.com/ElijahDaw/Gui.git}"
NODE_VERSION="v22.11.0"

TMP="$(mktemp -d "${TMPDIR:-/tmp}/cbb-build.XXXX")"
ZIP="$TMP/src.zip"

cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

# Ensure Node/npm available (download portable Node to temp if missing)
if ! command -v node >/dev/null 2>&1; then
  case "$(uname -s)" in
    Linux) NODE_TAR="node-${NODE_VERSION}-linux-x64.tar.xz" ;;
    Darwin) NODE_TAR="node-${NODE_VERSION}-darwin-x64.tar.xz" ;;
    *) echo "Unsupported OS for auto Node download"; exit 1 ;;
  esac
  NODE_URL="https://nodejs.org/dist/${NODE_VERSION}/${NODE_TAR}"
  NODE_DIR="$TMP/node"
  mkdir -p "$NODE_DIR"
  curl -L "$NODE_URL" -o "$TMP/node.tar.xz"
  tar -xJf "$TMP/node.tar.xz" -C "$NODE_DIR" --strip-components=1
  export PATH="$NODE_DIR/bin:$PATH"
fi

auth_args=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  auth_args+=( -H "Authorization: Bearer $GITHUB_TOKEN" )
fi

if ! curl -fL "${auth_args[@]}" "$REPO_ZIP" -o "$ZIP"; then
  echo "Zip download failed from $REPO_ZIP; trying git clone from $REPO_URL"
  git clone --depth 1 "$REPO_URL" "$TMP/repo"
  ROOT="$TMP/repo"
else
  if ! unzip -q "$ZIP" -d "$TMP"; then
    echo "Unzip failed for $ZIP"; exit 1
  fi
  ROOT="$(find "$TMP" -maxdepth 1 -type d ! -path "$TMP" | head -n 1)"
fi

# If repo root contains CuratedBuilder subdir, use it
if [ -d "$ROOT/CuratedBuilder" ]; then
  cd "$ROOT/CuratedBuilder"
else
  cd "$ROOT"
fi

npm install
npm run build:win

EXE="$(find dist -maxdepth 1 -type f -name '*.exe' | head -n 1)"
cp "$EXE" "$DROP/"

echo "Done: $DROP/$(basename "$EXE")"
