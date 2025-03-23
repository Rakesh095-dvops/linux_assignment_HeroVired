#!/bin/bash

# Script Name: system_monitor.sh
# Author: Rakesh Choudhury 
# Date Created: 2025-03-17
# Last Modified: 2025-03-17
# Version: 1.0
# Usage: Executable script to monitor system health status and provide disk usage statistics of mount point as input . 
#        Be careful while providing mount point as script uses df and du .
# example: 
#   - sudo ./system_monitor.sh "/home/dmdevops/codebase" "/home/sunil/codebase"
# Dependencies: top,df,du,free,vmstat,free
# Notes: 
#   - This script will run again with MONITOR_INTERVAL as long as it is terminated forcefully

# -----------------------------------------------------------------------------
# Main script code starts here
# -----------------------------------------------------------------------------


# Configuration
LOG_DIR="/var/log/system_monitor"
LOG_FILE_NAME="system_monitor"  #Centralized log location (needs appropriate permissions)
TOP_PROCESS_COUNT=5  # Number of top processes to display
MONITOR_INTERVAL=60  # Seconds between monitoring intervals
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S) #Add date and time
HOSTNAME=$(hostname)
OLD_LOG_EXTENSION="log.old"
SLEEP_COUNTER=10

# Check for mount point argument
if [ -z "$1" ]; then
  echo "Usage: $0 <mount_point1> <mount_point2> ... "
  exit 1
fi

# Parse mount points from arguments
MOUNT_POINTS=("$@")

#Ensure logging directory exists
mkdir -p "$LOG_DIR"

# Generate full log file path
LOG_FILE="$LOG_DIR/${LOG_FILE_NAME}_${HOSTNAME}.log"

# Functions to log message
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Function to rename old log file
rotate_log() {
  if [ -f "$LOG_FILE" ]; then
    OLD_LOG_FILE="${LOG_DIR}/${LOG_FILE_NAME}_${HOSTNAME}_${TIMESTAMP}.${OLD_LOG_EXTENSION}"
    mv -f "$LOG_FILE" "$OLD_LOG_FILE"
    log_message "Rotated log file to $OLD_LOG_FILE"
  fi
}

#get top processes
get_top_processes() {
  ps -eo pid,pcpu,pmem,rss,vsize,args --sort=-%cpu | head -n "$((TOP_PROCESS_COUNT + 1))"
}

# Main Monitoring Loop
rotate_log
while true;
do
  echo "Starting script..."

  log_message "--- System Monitoring Report ($TIMESTAMP) ---"
  
  echo "--- CPU and Memory Usage --- started"  
  # CPU and Memory Usage 
  #log_message "--- CPU and Memory (vmstat 1 2) ---"
  #vmstat 1 2 >> "$LOG_FILE"  # 1-second intervals, 2 samples (first is average)

  # Alternative CPU Usage (top -bn1)
  log_message "--- CPU Usage (top -bn1) ---"
  top -bn1 | head -n 15 >> "$LOG_FILE"

  # Memory Usage (free -m)
  log_message "--- Memory Usage (free -m) ---"
  free -m >> "$LOG_FILE" # show memory in MB
  
  sleep $SLEEP_COUNTER
  echo "--- CPU and Memory Usage  --- completed"  

  # Disk Usage (df) & Top directories by disk usage (du)
  echo "--- Disk Usage analysis--- started"  
 
  for mount_point in "${MOUNT_POINTS[@]}"; 
  do
    if [ -d "$mount_point" ]; then
        log_message "--- Disk Usage for mount point: $mount_point (df -h) ---"
        df -h "$mount_point" >> "$LOG_FILE" # Disk usage per mount point
        #get_top_directories "$mount_point"
        log_message "--- Top 5 directories by disk usage $mount_point (du -sh) ---"
        du -sh  "$mount_point" | sort -hr | head -n $SLEEP_COUNTER >> "$LOG_FILE"
    else
        log_message "Mount point $mount_point not found"
    fi
  done

  sleep $SLEEP_COUNTER
  echo "--- Disk Usage anaysis --- completed"  

  # Resource-Intensive Processes
  echo "--- Resource-Intensive Processes analysis --- started"  
  log_message "--- Top $TOP_PROCESS_COUNT Resource-Intensive Processes ---"
  get_top_processes >> "$LOG_FILE"  

  sleep $SLEEP_COUNTER  
  echo "--- Resource-Intensive Processes analysis --- completed"  

  log_message "--- End of Report ($TIMESTAMP) ---"

  echo "---starting another iteration press Ctrl+C to terminate the script"

  sleep "$MONITOR_INTERVAL"
done
