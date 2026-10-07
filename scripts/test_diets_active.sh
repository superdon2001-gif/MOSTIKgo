#!/usr/bin/env bash
# Quick smoke test for GET /api/diets/active after v5.3.23 deploy.
# Usage:
#   BASE=https://mostikik.netlify.app EMAIL=demo.owner@mostik.local PASS=demo123 ./scripts/test_diets_active.sh
set -euo pipefail
BASE="${BASE:-http://localhost:8888}"
EMAIL="${EMAIL:-demo.owner@mostik.local}"
PASS="${PASS:-demo123}"
ANIMAL="${ANIMAL:-demo-animal-baikal}"
COOKIE_JAR="$(mktemp)"
trap 'rm -f "$COOKIE_JAR"' EXIT

echo "== health =="
curl -sS "$BASE/api/health" | head -c 400; echo

echo "== login =="
curl -sS -c "$COOKIE_JAR" -X POST "$BASE/api/auth/login" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\"}" | head -c 400; echo

echo "== diets/active animal=$ANIMAL =="
CODE=$(curl -sS -o /tmp/diets_active_body.json -w '%{http_code}' -b "$COOKIE_JAR" \
  "$BASE/api/diets/active?animal_id=$ANIMAL")
echo "HTTP $CODE"
head -c 800 /tmp/diets_active_body.json; echo
if [ "$CODE" != "200" ]; then
  echo "FAIL: expected 200, got $CODE" >&2
  exit 1
fi
echo "OK"
