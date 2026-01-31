#!/usr/bin/env bash

# lƯU Ý: Chạy ở local
# 01_gcs_setup.sh
# Tạo 2 bucket: raw-de-nam-lab & de-nam-output

set -e

PROJECT_ID="de-nam-lab"
LOCATION="asia-southeast1"

RAW_BUCKET="raw-de-nam-lab"
OUTPUT_BUCKET="de-nam-output"

echo "[INFO] Set project..."
gcloud config set project "$PROJECT_ID"

echo "[INFO] Tạo bucket raw: gs://$RAW_BUCKET"
gsutil mb -p "$PROJECT_ID" -l "$LOCATION" "gs://$RAW_BUCKET"

echo "[INFO] Tạo bucket output (nếu chưa có): gs://$OUTPUT_BUCKET"
gsutil mb -p "$PROJECT_ID" -l "$LOCATION" "gs://$OUTPUT_BUCKET"

echo "[DONE] Buckets:"
gsutil ls
