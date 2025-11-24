# Infrastructure Setup

This folder contains automation scripts used to prepare all cloud resources for **Project 05**.  
The scripts provision Google Cloud Storage, Virtual Machine infrastructure, MongoDB installation, and data restoration from dump files.

---

## 📦 Components

### **1. Google Cloud Storage**
- `1.gcs_setup.sh`  
  Creates two buckets:
  - `raw-de-nam-lab` (raw input data)
  - `de-nam-output` (processed output)

- `2.upload_file_gcs.sh`  
  Uploads local raw data to the GCS bucket:
  - dump
  - IP-COUNTRY-REGION-CITY.BIN
---

### **2. Compute Engine VM**
- `3.vm_setup.sh`  
  Creates VM `mongo-n2d` with:
  - `n2d-standard-4`, 100GB SSD  
  - Ubuntu 22.04  
  - Service account access to Storage  
  - Firewall tags: `ssh`, `mongodb`

---

### **3. MongoDB Setup**
- `4.mongo_install.sh`  
  Installs MongoDB 7.0 on the VM and enables the service.

---

### **4. Data Loading**
- `5.copy_file_gcs_to_vm.sh`  
  Creates `~/de-project/data/` and copies data from GCS to VM.

- `6.restore_mongo.sh`  
  Restores MongoDB database **countly** using BSON dump:

  ```
  summary.bson
  summary.metadata.json
  ```

---

## Usage Flow

### **Local Machine**
```bash
./01_gcs_setup.sh
./upload_glamira.sh
./02_create_vm.sh
```

### **On VM**
```bash
gcloud compute ssh mongo-n2d --zone=asia-southeast1-b
./03_install_mongo.sh
./create_and_download.sh
./restore_countly.sh     # if using BSON dump
# OR
./05_import_from_gcs.sh  # if importing JSON
```

---

## Notes
- All scripts use `set -e` to stop on error.
- VM service account has full GCS read/write access.
- Adjust folder paths as needed based on your local environment.
