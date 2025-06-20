#!/bin/bash
set -e

echo "🚀 Starting NGINX with pre-generated SSL cert..."
exec nginx -g "daemon off;"
