#!/bin/sh
set -e

echo "Starting php-fpm..."
php-fpm -D

echo "Starting nginx..."
nginx -g "daemon off;"
