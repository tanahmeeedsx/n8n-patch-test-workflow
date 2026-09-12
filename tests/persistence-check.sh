#!/bin/bash
set -e
docker compose restart
sleep 5
curl -fsS http://localhost:5678/healthz > /dev/null && echo "PASS: data persisted after service restart"

docker compose down
docker compose up -d
sleep 10
curl -fsS http://localhost:5678/healthz > /dev/null && echo "PASS: data persisted after container recreation"
