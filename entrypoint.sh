#!/bin/bash
# 'set -e' makes the script exit immediately if any command fails
set -e

# 1. Start PHP-FPM (FastCGI Process Manager) in the background (&)
echo "Starting PHP-FPM..."
php-fpm -F &
PHP_PID=$! # Save the process ID of PHP-FPM so we can track it

# 2. Pause for 2 seconds to give PHP-FPM enough time to boot up safely
echo "Waiting for PHP-FPM to start..."
sleep 2

# 3. Start Nginx web server in the foreground (daemon off)
# This keeps the Docker container running actively
echo "Starting Nginx..."
nginx -g "daemon off;"

# 4. If PHP-FPM dies or stops, exit the entire script
wait $PHP_PID