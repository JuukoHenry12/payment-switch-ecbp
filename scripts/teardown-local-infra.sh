#!/usr/bin/env bash
set -e
docker compose -f docker-compose-infra.yml down -v
echo "Local infra torn down."
