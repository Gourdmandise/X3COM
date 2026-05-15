#!/usr/bin/env bash
set -euo pipefail

# Supabase database transfer helper
# Usage:
#   OLD_DB_URL='postgresql://...' NEW_DB_URL='postgresql://...' ./transfer_supabase.sh
#
# Optional variables:
#   DUMP_DIR=./backups
#   DUMP_FILE=./backups/supabase_transfer_YYYYmmdd_HHMMSS.sql
#   CLEAN_TARGET=true   # WARNING: drops existing objects in target before restore

if ! command -v pg_dump >/dev/null 2>&1; then
  echo "Erreur: pg_dump est introuvable. Installe PostgreSQL client tools."
  exit 1
fi

if ! command -v psql >/dev/null 2>&1; then
  echo "Erreur: psql est introuvable. Installe PostgreSQL client tools."
  exit 1
fi

OLD_DB_URL="${OLD_DB_URL:-}"
NEW_DB_URL="${NEW_DB_URL:-}"
CLEAN_TARGET="${CLEAN_TARGET:-false}"
DUMP_DIR="${DUMP_DIR:-./backups}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
DUMP_FILE="${DUMP_FILE:-${DUMP_DIR}/supabase_transfer_${TIMESTAMP}.sql}"

if [[ -z "${OLD_DB_URL}" || -z "${NEW_DB_URL}" ]]; then
  cat <<'EOF'
Erreur: variables manquantes.

Renseigne les 2 variables ci-dessous:
  OLD_DB_URL=postgresql://postgres:<OLD_PASSWORD>@db.<old-ref>.supabase.co:5432/postgres
  NEW_DB_URL=postgresql://postgres:<NEW_PASSWORD>@db.<new-ref>.supabase.co:5432/postgres

Exemple:
  OLD_DB_URL='postgresql://postgres:xxx@db.aaaa.supabase.co:5432/postgres' \
  NEW_DB_URL='postgresql://postgres:yyy@db.bbbb.supabase.co:5432/postgres' \
  ./transfer_supabase.sh
EOF
  exit 1
fi

mkdir -p "${DUMP_DIR}"

echo "[1/5] Test connexion base source..."
psql "${OLD_DB_URL}" -v ON_ERROR_STOP=1 -c 'SELECT 1;' >/dev/null

echo "[2/5] Test connexion base cible..."
psql "${NEW_DB_URL}" -v ON_ERROR_STOP=1 -c 'SELECT 1;' >/dev/null

echo "[3/5] Export schema public + donnees depuis la source"
DUMP_ARGS=(
  "${OLD_DB_URL}"
  --schema=public
  --no-owner
  --no-privileges
  --encoding=UTF8
  --format=plain
)

if [[ "${CLEAN_TARGET}" == "true" ]]; then
  DUMP_ARGS+=(--clean --if-exists)
fi

pg_dump "${DUMP_ARGS[@]}" > "${DUMP_FILE}"

echo "Dump cree: ${DUMP_FILE}"

echo "[4/5] Import dans la base cible..."
psql "${NEW_DB_URL}" -v ON_ERROR_STOP=1 -f "${DUMP_FILE}" >/dev/null

echo "[5/5] Verification rapide"
psql "${NEW_DB_URL}" -v ON_ERROR_STOP=1 <<'SQL'
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
SQL

echo
echo "Transfert termine avec succes."
