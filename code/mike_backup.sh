#!/bin/bash

# Set variables
DATE=$(date +%Y-%m-%d)
BACKUP_DIR="/backups"
NGINX_CONFIG="/etc/nginx"
NGINX_DOCROOT="/usr/share/nginx/html"
BACKUP_FILE="${BACKUP_DIR}/nginx_backup_${DATE}.tar.gz"

# Create the backup
tar -czvf "${BACKUP_FILE}" "${NGINX_CONFIG}" "${NGINX_DOCROOT}"

# Verify the backup
echo "Contents of ${BACKUP_FILE}:"
tar -tzvf "${BACKUP_FILE}"

# Optional: Log the verification (append to a log file)
echo "$(date) - Nginx backup created and verified: ${BACKUP_FILE}" >> /var/log/backup_log_NGINX.txt

echo "Nginx Backup Completed"