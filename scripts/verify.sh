#!/bin/sh
# Reproduce every claim in the README with one command.
# Requires: Daml SDK 3.4.x (damlc on PATH) + Java 17.
# Usage: sh scripts/verify.sh
set -e
cd "$(dirname "$0")/.."

DAMLC="${DAMLC:-damlc}"

echo "==> Building PolicyGate package..."
"$DAMLC" build --package-root .

echo "==> Running proof suite (6 scripted claims)..."
"$DAMLC" test --package-root .

echo ""
echo "Every claim held."
