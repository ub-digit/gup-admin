export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig();
    const query = getQuery(event);
    const data = [{
		"id": "1",
		"title": "Publikationstitel 1 (gup)",
		"doi": "http://doi.org/10.1",
		"creator": "xljoha",
		"authors": [{
			"id": "333",
			"name": "LångePär",
			"x-account": "xlpero"
		}],
		"gup_id": "1",
		"scopus_id": "1",
		"date": "2021",
		"pubtype": "Artikel i vetenskaplig tidskrift, refereegranskad",
		"number_of_authors": "5"
	},
	{
		"id": "2",
		"title": "Publikationstitel 2 (gup)",
		"doi": "http://doi.org/10.2",
		"creator": "xljoha",
		"authors": [{
			"id": "333",
			"name": "LångePär",
			"x-account": "xlpero"
		}],
		"gup_id": "2",
		"scopus_id": "2",
		"date": "2022",
		"pubtype": "Artikel i vetenskaplig tidskrift, refereegranskad",
		"number_of_authors": "2"
	}];
	let res = null;
	if (query.id) {
		res = data.find(post => {
			if (post.id === query.id) {
				return post;
			}
		})
	}
	else {
		res = data;
	}
    return res;
})

