source /preexecute/utils/check-env.sh

check_env "PGPASSWORD" "PGUSERNAME" "PGHOST" || { echo "Ignoring PGSQL backup"; return 0; }

echo "Creating $VOLUMERIZE_SOURCE folder if not exists"
mkdir -p $VOLUMERIZE_SOURCE/volumerize-pgsql/

FULL_BACKUP_QUERY="select datname from pg_database where not datistemplate and datallowconn $EXCLUDE_SCHEMA_ONLY_CLAUSE order by datname;"

for PGDATABASE in `psql -h ${PGHOST} -U "${PGUSERNAME}"  -At -c "$FULL_BACKUP_QUERY" postgres`; do
  echo "pg_dump -Fp starts " ${PGDATABASE}
  pg_dump -U "${PGUSERNAME}"  -h "${PGHOST}" "${PGDATABASE}" > ${VOLUMERIZE_SOURCE}/volumerize-pgsql/dump-${PGDATABASE}.sql || true
  
done
