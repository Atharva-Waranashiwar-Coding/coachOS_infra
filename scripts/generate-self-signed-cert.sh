#!/bin/sh
set -eu

root_dir=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
domain=${1:-localhost}
tls_dir="$root_dir/nginx/tls"
mkdir -p "$tls_dir"

openssl req -x509 -nodes -newkey rsa:4096 -sha256 -days 30 \
  -keyout "$tls_dir/privkey.pem" \
  -out "$tls_dir/fullchain.pem" \
  -subj "/CN=$domain" \
  -addext "subjectAltName=DNS:$domain,DNS:localhost,IP:127.0.0.1"

chmod 0600 "$tls_dir/privkey.pem"
chmod 0644 "$tls_dir/fullchain.pem"
