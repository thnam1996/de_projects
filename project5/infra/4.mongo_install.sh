#!/usr/bin/env bash

# SSH vào VM (gcloud compute ssh mongo-n2d --zone=asia-southeast1-b)
# 03_install_mongo.sh
# Cài MongoDB Community 7.0 trên Ubuntu 22.04

set -e

echo "[INFO] Update APT..."
sudo apt update

echo "[INFO] Cài tool cần thiết..."
sudo apt install -y wget gnupg curl

echo "[INFO] Thêm GPG key MongoDB..."
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
  sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

echo "[INFO] Thêm repo MongoDB 7.0..."
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
  sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

echo "[INFO] Update lại APT..."
sudo apt update

echo "[INFO] Cài mongodb-org..."
sudo apt install -y mongodb-org

echo "[INFO] Start + enable mongod..."
sudo systemctl start mongod
sudo systemctl enable mongod

echo "[INFO] Trạng thái mongod:"
sudo systemctl status mongod --no-pager || true

echo "[DONE] MongoDB đã chạy trên VM."
