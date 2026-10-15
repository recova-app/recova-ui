#!/usr/bin/env bash
set -euo pipefail

# Normalize working directory to repository root
cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "==> 1. Resolving dependencies..."
flutter pub get

echo "==> 2. Checking code formatting..."
dart format --output=none --set-exit-if-changed .

echo "==> 3. Running static analysis..."
flutter analyze

echo "==> 4. Running automated unit tests..."
flutter test

echo "==> All local quality gates passed successfully!"
