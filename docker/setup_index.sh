#!/bin/bash

if [[ "$1" == "all" ]]; then
    docker-compose exec index-manager-backend mix run -e "GupIndexManager.Maintenance.setup_indexes() |> IO.inspect()"
elif [[ "$1" == "departments" ]]; then
    docker-compose exec index-manager-backend mix run -e "GupIndexManager.Maintenance.setup_index("departments") |> IO.inspect()"
elif [[ "$1" == "publications" ]]; then
    docker-compose exec index-manager-backend mix run -e "GupIndexManager.Maintenance.setup_index("publications") |> IO.inspect()"
elif [[ "$1" == "persons" ]]; then
    docker-compose exec index-manager-backend mix run -e "GupIndexManager.Maintenance.setup_index("persons") |> IO.inspect()"
fi









