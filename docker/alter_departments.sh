
alter_sql="ALTER TABLE departments
            ADD COLUMN IF NOT EXISTS is_faculty BOOLEAN DEFAULT FALSE,
            ADD COLUMN IF NOT EXISTS parent_id INT;"

docker compose exec index-manager-db psql -d gup_index_manager_dev -U postgres -c "$alter_sql"


