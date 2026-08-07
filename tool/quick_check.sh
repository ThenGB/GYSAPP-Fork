#!/usr/bin/env bash
# Quick verification loop — much faster than the full gate:
#
#   bash tool/quick_check.sh midi_controls      # analyze lib+test + one test file
#   bash tool/quick_check.sh                     # analyze lib+test + full suite
#   bash tool/quick_check.sh --fast midi_controls  # SKIP analyze, one test file (~20-30s)
#   bash tool/quick_check.sh --file lib/x.dart midi_controls  # analyze 1 file + 1 test file
#
# Full `flutter analyze` + the 251-test suite is the *final* gate before
# commit; use this during iteration to keep each cycle short.
set -euo pipefail
cd "$(dirname "$0")/.."

mode="normal"
test_filter=""
analyze_target=""
[[ "${1:-}" == "--fast" ]] && { mode="fast"; shift || true; }
if [[ "${1:-}" == "--file" ]]; then
  mode="file"
  shift || true
  analyze_target="${1:-}"
  [[ -n "$analyze_target" ]] && shift || true
fi
test_filter="${1:-}"

case "$mode" in
  fast)
    echo "== (fast) skipping analyze =="
    ;;
  file)
    echo "== dart analyze $analyze_target =="
    dart analyze "$analyze_target"
    ;;
  normal)
    echo "== dart analyze lib test =="
    dart analyze lib test
    ;;
esac

if [[ -n "$test_filter" ]]; then
  if [[ "$test_filter" == *.dart ]]; then
    echo "== flutter test $test_filter =="
    flutter test --no-pub "$test_filter"
  else
    matched=$(ls test/*"$test_filter"*_test.dart 2>/dev/null | head -1)
    if [[ -n "$matched" ]]; then
      echo "== flutter test $matched =="
      flutter test --no-pub "$matched"
    else
      echo "== flutter test (full suite, filter: $test_filter) =="
      flutter test --no-pub test --name "$test_filter"
    fi
  fi
else
  echo "== flutter test (full suite, -j 8 parallel) =="
  flutter test --no-pub test -j 8
fi

echo "== done =="
