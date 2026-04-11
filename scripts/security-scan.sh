#!/usr/bin/env bash
# security-scan.sh — Lightweight security scan for the Institutional Replit OS workspace.
# Checks for common secrets, insecure patterns, and policy violations.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXIT_CODE=0

echo "============================================"
echo " Institutional Replit OS — Security Scan"
echo "============================================"
echo ""

# ── 1. Check for hardcoded secrets ──────────────────────────────────────────
echo "[1/4] Scanning for hardcoded secrets..."

SECRET_PATTERNS=(
  'password\s*=\s*["\x27][^"\x27]{8,}'
  'secret\s*=\s*["\x27][^"\x27]{8,}'
  'api_key\s*=\s*["\x27][^"\x27]{8,}'
  'token\s*=\s*["\x27][^"\x27]{8,}'
  'AKIA[0-9A-Z]{16}'
  'ghp_[0-9A-Za-z]{36}'
  'glpat-[0-9A-Za-z\-]{20}'
)

EXCLUDE_DIRS=".git node_modules vendor dist build"
EXCLUDE_ARGS=()
for dir in $EXCLUDE_DIRS; do
  EXCLUDE_ARGS+=(--exclude-dir="$dir")
done

FOUND_SECRETS=0
for pattern in "${SECRET_PATTERNS[@]}"; do
  if grep -rEi "${EXCLUDE_ARGS[@]}" --include="*.json" --include="*.js" \
       --include="*.ts" --include="*.py" --include="*.go" --include="*.sh" \
       --include="*.yaml" --include="*.yml" --include="*.env" \
       "$pattern" "$REPO_ROOT" 2>/dev/null | grep -v "security-scan.sh"; then
    FOUND_SECRETS=1
  fi
done

if [ "$FOUND_SECRETS" -eq 1 ]; then
  echo "  [FAIL] Potential hardcoded secrets detected. Review the matches above."
  EXIT_CODE=1
else
  echo "  [PASS] No hardcoded secrets found."
fi

echo ""

# ── 2. Check for .env files committed to the repo ───────────────────────────
echo "[2/4] Checking for committed .env files..."

ENV_FILES=$(find "$REPO_ROOT" -name ".env" -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null || true)
if [ -n "$ENV_FILES" ]; then
  echo "  [WARN] The following .env files are present in the repository:"
  echo "$ENV_FILES"
  echo "  Ensure these do not contain real credentials and are listed in .gitignore."
else
  echo "  [PASS] No .env files found in repository."
fi

echo ""

# ── 3. Verify governance.json integrity ─────────────────────────────────────
echo "[3/4] Validating governance.json..."

GOVERNANCE_FILE="$REPO_ROOT/governance.json"
if [ ! -f "$GOVERNANCE_FILE" ]; then
  echo "  [FAIL] governance.json not found at repo root."
  EXIT_CODE=1
else
  if python3 -c "import json; json.load(open('$GOVERNANCE_FILE'))" 2>/dev/null; then
    echo "  [PASS] governance.json is valid JSON."
  else
    echo "  [FAIL] governance.json contains invalid JSON."
    EXIT_CODE=1
  fi

  # Verify that deploy-to-production is in restricted_actions
  python3 - "$GOVERNANCE_FILE" <<'EOF'
import json, sys
gov = json.load(open(sys.argv[1]))
restricted = gov.get("autonomy", {}).get("restricted_actions", [])
if "deploy_to_production" not in restricted:
    print("  [WARN] 'deploy_to_production' is not in restricted_actions — review governance policy.")
else:
    print("  [PASS] 'deploy_to_production' is correctly restricted.")
EOF
fi

echo ""

# ── 4. Check file permissions ────────────────────────────────────────────────
echo "[4/4] Checking for overly permissive file permissions..."

WORLD_WRITABLE=$(find "$REPO_ROOT" -not -path "*/.git/*" -perm -o+w -type f 2>/dev/null || true)
if [ -n "$WORLD_WRITABLE" ]; then
  echo "  [WARN] World-writable files detected:"
  echo "$WORLD_WRITABLE"
else
  echo "  [PASS] No world-writable files found."
fi

echo ""
echo "============================================"
if [ "$EXIT_CODE" -eq 0 ]; then
  echo " Security scan completed — no blocking issues."
else
  echo " Security scan completed — FAILURES detected. Review output above."
fi
echo "============================================"

exit "$EXIT_CODE"
