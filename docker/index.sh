docker-compose exec gup-backend bash -c 'bundle exec rake gup_admin:index_all LIMIT=1000 OFFSET=0'
docker-compose exec gup-imports bash -c 'python3 /data/scripts/put-scopus-docs.py -d /data/files/scopus-normalised/testdata -u $GUP_ADMIN_BASE_URL -a $GUP_ADMIN_API_KEY'
docker-compose exec index-manager-backend mix run -e "GupIndexManager.Resource.Departments.initialize |> IO.inspect()" 
rm -rf venv 
python3 -m venv venv
source venv/bin/activate
pip install requests
python3 person_index.py
rm -rf venv 