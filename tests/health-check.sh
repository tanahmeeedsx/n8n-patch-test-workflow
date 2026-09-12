#!/bin/bash
set -e
docker compose exec postgres pg_isready -U n8n
echo "PASS: PostgreSQL is healthy"
curl -fsS http://localhost:5678/healthz
echo "PASS: n8n health endpoint returned status ok"
