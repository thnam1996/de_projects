#!/usr/bin/env bash

# SSH vào VM (gcloud compute ssh mongo-n2d --zone=asia-southeast1-b)
# 5.copy file gcs to vm
# Mục tiêu:
# 1. Tạo thư mục ~/de-project/data
# 2. Copy toàn bộ file từ bucket GCS về thư mục đó

set -e

# ==== Config ====
GCS_BUCKET="raw-de-nam-lab"           # bucket chứa file raw
GCS_PATH="glamira/raw"                # thư mục trong bucket
LOCAL_DIR="$HOME/de-project/data"     # nơi lưu file trên VM
# ==========================================

echo "[INFO] Tạo thư mục local: $LOCAL_DIR"
mkdir -p "$LOCAL_DIR"

echo "[INFO] Copy file từ GCS về VM..."
gsutil -m cp -r "gs://$GCS_BUCKET/$GCS_PATH/*" "$LOCAL_DIR/"

echo "[DONE] Copy hoàn tất!"
echo "Kiểm tra thư mục:"
ls -lh "$LOCAL_DIR"
