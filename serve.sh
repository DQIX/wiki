#!/bin/sh
# Serve the wiki locally: ./serve.sh [port], then open http://localhost:8000/
cd "$(dirname "$0")" && exec python3 -m http.server "${1:-8000}" --bind 127.0.0.1
