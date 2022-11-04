#!/bin/bash
# ----------------------------------------
# Header
# ----------------------------------------
echo "*** matrix_server cron started"

# ----------------------------------------
# Main
# ----------------------------------------
# certbot
echo "*** certbot - start"
/usr/bin/certbot renew --quiet
echo "*** certbot - end"

sleep 30

# Purge old media
if [[ $(date +%u) -eq 5 ]]; then # only on Friday - save transactions (and $$$) to file server
	echo "*** Purging old media - start"
	# https://github.com/matrix-org/synapse/issues/2315
	#find /var/lib/matrix-synapse/media -type f -size +5M -mtime +120 -exec rm -rv {} \; # size >5MB, older than 120 days
	find /mount/storagematrixregev/matrixmedia/media -type f -size +5M -mtime +120 -exec rm -rv {} \; # size >5MB, older than 120 days
	echo "*** Purging old media - end"
fi

# ----------------------------------------
# Footer
# ----------------------------------------
echo "*** matrix_server cron done"
