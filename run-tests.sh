#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$ROOT_DIR/test-results"

rm -rf "$RESULTS_DIR"
mkdir -p "$RESULTS_DIR"

fail=0

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing dependency: $cmd" >&2
    return 1
  fi
}

run_back() {
  echo "Running backend tests..."

  if ! require_cmd java; then
    fail=1
    return
  fi

  if [ ! -x "$ROOT_DIR/back/gradlew" ]; then
    echo "Missing or non-executable Gradle wrapper at back/gradlew" >&2
    fail=1
    return
  fi

  if ! (cd "$ROOT_DIR/back" && ./gradlew clean test); then
    fail=1
  fi

  local src_dir="$ROOT_DIR/back/build/test-results/test"
  local dest_dir="$RESULTS_DIR/back"
  mkdir -p "$dest_dir"

  if [ -d "$src_dir" ]; then
    shopt -s nullglob
    local files=("$src_dir"/*.xml)
    if [ ${#files[@]} -gt 0 ]; then
      cp "$src_dir"/*.xml "$dest_dir"/
    else
      echo "No JUnit XML reports found in $src_dir" >&2
    fi
    shopt -u nullglob
  else
    echo "JUnit results directory not found: $src_dir" >&2
  fi
}

run_front() {
  echo "Running frontend tests..."

  if ! require_cmd node || ! require_cmd npm; then
    fail=1
    return
  fi

  rm -rf "$ROOT_DIR/front/reports"

  if [ -f "$ROOT_DIR/front/package-lock.json" ]; then
    if ! (cd "$ROOT_DIR/front" && npm ci --cache .npm --prefer-offline); then
      fail=1
      return
    fi
  else
    if ! (cd "$ROOT_DIR/front" && npm install); then
      fail=1
      return
    fi
  fi

  if ! (cd "$ROOT_DIR/front" && npm test); then
    fail=1
  fi

  local src_dir="$ROOT_DIR/front/reports"
  local dest_dir="$RESULTS_DIR/front"
  mkdir -p "$dest_dir"

  if [ -d "$src_dir" ]; then
    shopt -s nullglob
    local files=("$src_dir"/*.xml)
    if [ ${#files[@]} -gt 0 ]; then
      cp "$src_dir"/*.xml "$dest_dir"/
    else
      echo "No JUnit XML reports found in $src_dir" >&2
    fi
    shopt -u nullglob
  else
    echo "JUnit results directory not found: $src_dir" >&2
  fi
}

if [ -f "$ROOT_DIR/back/build.gradle" ]; then
  run_back
else
  echo "Backend not detected (back/build.gradle not found). Skipping."
fi

if [ -f "$ROOT_DIR/front/package.json" ]; then
  run_front
else
  echo "Frontend not detected (front/package.json not found). Skipping."
fi

exit $fail
