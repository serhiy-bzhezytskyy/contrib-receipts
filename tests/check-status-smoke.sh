#!/usr/bin/env bash
# Smoke test for tools/check-status.sh — offline, no network.
# Verifies the script parses and its two embedded python3 heredocs compile.
# It does NOT hit gh / curl / JIRA (those need creds + network); it proves the
# script is syntactically runnable, which is the failure mode a smoke test guards.
# Usage: bash tests/check-status-smoke.sh   (exit 0 = pass)
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$HERE/../tools/check-status.sh"
fail=0

pass(){ printf 'ok   - %s\n' "$1"; }
bad(){  printf 'FAIL - %s\n' "$1"; fail=1; }

# 1. the script exists
[ -f "$SCRIPT" ] && pass "check-status.sh exists" || { bad "check-status.sh missing"; exit 1; }

# 2. bash parses it (catches unbalanced quotes / heredocs / syntax)
if bash -n "$SCRIPT" 2>/tmp/cs_bash_err; then
  pass "bash -n parses check-status.sh"
else
  bad "bash -n failed:"; cat /tmp/cs_bash_err
fi

# 3. each embedded python3 heredoc compiles (extract PYEOF blocks, compile each)
if command -v python3 >/dev/null 2>&1; then
  if python3 - "$SCRIPT" <<'PYCHECK'
import re, sys, py_compile, tempfile, os
src = open(sys.argv[1]).read()
blocks = re.findall(r"<<'PYEOF'\n(.*?)\nPYEOF", src, re.DOTALL)
if len(blocks) < 2:
    print("FAIL - expected >=2 python heredocs, found %d" % len(blocks)); sys.exit(1)
rc = 0
for i, b in enumerate(blocks, 1):
    fd, p = tempfile.mkstemp(suffix=".py"); os.write(fd, b.encode()); os.close(fd)
    try:
        py_compile.compile(p, doraise=True)
        print("ok   - embedded python heredoc #%d compiles" % i)
    except py_compile.PyCompileError as e:
        print("FAIL - embedded python heredoc #%d does not compile: %s" % (i, e)); rc = 1
    finally:
        os.remove(p)
sys.exit(rc)
PYCHECK
  then :; else bad "embedded python heredoc check failed"; fi
else
  printf 'skip - python3 not on PATH; heredoc compile check skipped\n'
fi

# 4. tools/house-shape.py (the match-the-house-shape receipt) compiles
HS="$HERE/../tools/house-shape.py"
if [ -f "$HS" ]; then
  if command -v python3 >/dev/null 2>&1; then
    if python3 -m py_compile "$HS" 2>/tmp/hs_err; then
      pass "house-shape.py compiles"
    else
      bad "house-shape.py does not compile:"; cat /tmp/hs_err
    fi
  else
    printf 'skip - python3 not on PATH; house-shape.py compile check skipped\n'
  fi
else
  bad "house-shape.py missing"
fi

# 5. the skills themselves satisfy the invariants this repo promises about them
VS="$HERE/../tools/validate-skills.sh"
if [ -f "$VS" ]; then
  if bash "$VS" >/tmp/vs_out 2>&1; then
    pass "validate-skills.sh: all skill invariants hold"
  else
    bad "validate-skills.sh reported failures:"; grep '^FAIL' /tmp/vs_out | sed 's/^/       /'
  fi
else
  bad "validate-skills.sh missing"
fi

echo "----"
if [ "$fail" -eq 0 ]; then echo "PASS"; else echo "FAILED"; fi
exit "$fail"
