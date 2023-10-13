#!/bin/sh

set -e

mkdir -p /sh-root/logs/php-fpm

exec "$@"