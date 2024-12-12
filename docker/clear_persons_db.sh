# delete all persons from the database
echo "Deleting all persons from the database..."
docker compose exec -it index-manager-db psql -U postgres -d gup_index_manager_dev -c 'TRUNCATE persons;'
