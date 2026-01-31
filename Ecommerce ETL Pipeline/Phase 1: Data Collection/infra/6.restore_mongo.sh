#!/usr/bin/env bash

# SSH vào VM (gcloud compute ssh mongo-n2d --zone=asia-southeast1-b)
# 6. restore vào mongodb từ file dump glamira


set -e

# === Cấu hình theo folder bạn gửi ===
DUMP_DIR="/home/de-engineer/data/dump_glamira/dump/countly"
MONGO_DB="countly"
MONGO_URI="mongodb://localhost:27017"
# ====================================

echo "[INFO] Kiểm tra thư mục dump..."
if [ ! -d "$DUMP_DIR" ]; then
    echo "[ERROR] Không tìm thấy thư mục dump: $DUMP_DIR"
    exit 1
fi

echo "[INFO] Restore database '$MONGO_DB' từ dump:"
echo "       $DUMP_DIR"
echo ""

# Restore mongodump
mongorestore \
  --uri="$MONGO_URI" \
  --drop \
  --db="$MONGO_DB" \
  "$DUMP_DIR"

echo "[DONE] Restore xong!"
echo "Kiểm tra bằng:"
echo "  mongosh"
echo "  use $MONGO_DB"
echo "  show collections"
echo "  db.summary.count()"