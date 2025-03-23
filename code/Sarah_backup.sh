#!/bin/bash

# Set variables
DATE=$(date +%Y-%m-%d)
BACKUP_DIR="/backups"
#APACHE_CONFIG="/etc/httpd"
#As in some linux dist apache2 will be installed.
APACHE_CONFIG="/etc/apache2"
APACHE_DOCROOT="/var/www/html"
BACKUP_FILE="${BACKUP_DIR}/apache_backup_${DATE}.tar.gz"

# Create the backup
tar -czvf "${BACKUP_FILE}" "${APACHE_CONFIG}" "${APACHE_DOCROOT}"

# Verify the backup
echo "Contents of ${BACKUP_FILE}:"
tar -tzvf "${BACKUP_FILE}"

# Optional: Log the verification (append to a log file)
echo "$(date) - Apache backup created and verified: ${BACKUP_FILE}" >> /var/log/backup_log_APACHE2.txt

echo "Apache Backup Completed"