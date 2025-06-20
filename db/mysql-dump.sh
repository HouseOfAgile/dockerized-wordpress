#!/bin/sh
set -eu

# === Configuration ===
TIMESTAMP=$(date +"%Y-%m-%dT%H-%M-%S")
DUMP_PATH="/backup/db-backup-${TIMESTAMP}.sql"
LOG_PATH="/backup/db-backup-${TIMESTAMP}.log"

: "${MYSQL_HOST:=db}"
: "${MYSQL_USER:=root}"
: "${MYSQL_PASSWORD:=}"
: "${MYSQL_DATABASE:=wordpress}"

MAX_RETRIES=10
RETRY_DELAY=5

echo "[INFO] 🕒 Starting MySQL backup at $TIMESTAMP" | tee -a "$LOG_PATH"
echo "[INFO] Target DB: $MYSQL_DATABASE on host $MYSQL_HOST" | tee -a "$LOG_PATH"
echo "[INFO] Dump file will be saved to: $DUMP_PATH" | tee -a "$LOG_PATH"
echo "[DEBUG] MYSQL_HOST=$MYSQL_HOST" >> "$LOG_PATH"
echo "[DEBUG] MYSQL_USER=$MYSQL_USER" >> "$LOG_PATH"
echo "[DEBUG] MYSQL_DATABASE=$MYSQL_DATABASE" >> "$LOG_PATH"


echo "[INFO] 🔍 Waiting for MySQL..." | tee -a "$LOG_PATH"
for i in $(seq 1 10); do mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent && break || sleep 2; done || { echo "[ERROR] ❌ Could not connect."; exit 1; }
    


# === Check if database exists ===
if ! mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "USE \`$MYSQL_DATABASE\`;" 2>/dev/null; then
  echo "[ERROR] ❌ Database '$MYSQL_DATABASE' does not exist or is not yet initialized." | tee -a "$LOG_PATH"
  exit 2
fi

# === Perform mysqldump ===
echo "[INFO] 🔄 Dumping database..." | tee -a "$LOG_PATH"

if mysqldump --single-transaction --quick --lock-tables=false \
  -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" > "$DUMP_PATH" 2>> "$LOG_PATH"; then
  echo "[INFO] ✅ MySQL dump completed successfully." | tee -a "$LOG_PATH"
else
  echo "[ERROR] ❌ mysqldump failed. See log for details." | tee -a "$LOG_PATH"
  exit 3
fi

# === Final log ===
echo "[INFO] ✅ Backup finished. Dump and log stored in /backup/" | tee -a "$LOG_PATH"
