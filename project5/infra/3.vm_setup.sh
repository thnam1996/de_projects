#!/usr/bin/env bash

# lƯU Ý: Chạy ở local
# 02_create_vm.sh
# Tạo VM mongo-n2d với quyền full Cloud Platform

set -e

PROJECT_ID="de-nam-lab"
ZONE="asia-southeast1-b"
VM_NAME="mongo-n2d"

SERVICE_ACCOUNT="de-nam@de-nam-lab.iam.gserviceaccount.com"

echo "[INFO] Set project..."
gcloud config set project "$PROJECT_ID"

echo "[INFO] Tạo VM $VM_NAME ..."
gcloud compute instances create "$VM_NAME" \
  --zone="$ZONE" \
  --machine-type="n2d-standard-4" \
  --image-family="ubuntu-2204-lts" \
  --image-project="ubuntu-os-cloud" \
  --boot-disk-size="100GB" \
  --boot-disk-type="pd-ssd" \
  --service-account="$SERVICE_ACCOUNT" \
  --scopes="https://www.googleapis.com/auth/cloud-platform" \
  --metadata=enable-oslogin=TRUE \
  --tags=ssh,mongodb

echo "[DONE] Đã tạo VM $VM_NAME."
echo "SSH vào bằng:"
echo "  gcloud compute ssh $VM_NAME --zone $ZONE"
