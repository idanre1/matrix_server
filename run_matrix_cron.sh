#!/bin/bash
# ----------------------------------------
# Header
# ----------------------------------------
echo "*** matrix_server cron started"

# ----------------------------------------
# Main
# ----------------------------------------

# Purge old media
# https://github.com/matrix-org/synapse/issues/2315
find /var/lib/matrix-synapse/media -type f -size +5M -mtime +120 -exec rm -iv {} \; # size >5MB, older than 120 days

# ----------------------------------------
# Footer
# ----------------------------------------
echo "*** matrix_server cron done"
