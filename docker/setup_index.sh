#!/bin/bash
docker compose exec index-manager-backend mix run -e "GupIndexManager.Maintenance.setup_indexes() |> IO.inspect()"







