#!/usr/bin/env bash

# 2_upload_glamira.sh
# Upload dump_ glamira và IP-COUNTRY-REGION-CITY.BIN từ thư mục local lên Google Cloud Storage

set -e

PROJECT_ID="de-nam-lab"
RAW_BUCKET="raw-de-nam-lab"

DUMP_LOCAL_DIR="/home/thien-nam/data_engineer/GCP/dump_glamira"
IP_DB_LOCAL="/home/thien-nam/data_engineer/GCP/IP-COUNTRY-REGION-CITY.BIN"

gcloud config set project "$PROJECT_ID"

echo "Upload dump_glamira..."
gsutil -m cp -r "$DUMP_LOCAL_DIR" gs://$RAW_BUCKET/

echo "Upload IP DB..."
gsutil cp "$IP_DB_LOCAL" gs://$RAW_BUCKET/
echo "Xong."
