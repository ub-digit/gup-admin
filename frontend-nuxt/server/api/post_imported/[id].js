export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig();
    const query = getQuery(event);
    const id = event.context.params.id;
    const res = [
        { "first": { "value": 319932}, "diff": false, "display_type": "string", "visibility": "never", "display_label": "publication_id"  },
        { "first": { "value": "gup:319932" }, "diff": false, "display_type": "string", "visibility": "never", "display_label": "id" },
        { "first": { "value": { "title": "Cluelessness and rational choice: the case of effective altruism", "url": null} }, "diff": false, "display_type": "title", "visibility": "always", "display_label": "title" },
  
        { "first": { "value": {"attended": {"value": false, "display_label": "attended"}, "created_at": {"value": '2022-11-14T22:42:32.030Z', "display_label": "created_at"}, "version_created_by": {"value": "xherli", "display_label": "version_created_by"}, "updated_at": {"value": "2022-11-18T13:31:28.143Z", "display_label": "updated_at" }, "version_updated_by": {"value": "xrewkl", "display_label": "version_updated_by"}, "source": {"value": "gup", "display_label": "source" } }}, "display_type": "meta", "visibility": "always"
        },
        { "first": { "value": "Artikel i vetenskaplig tidskrift"}, "diff": false, "display_type": "string", "visibility": "always", "display_label": "publication_type_label"},
        { "first": { "value": "Ethical Perspectives"}, "diff": false, "display_type": "string", "visibility": "always", "display_label": "sourcetitle" },
        { "first": { "value": 2019}, "diff": false, "display_type": "string", "visibility": "always", "display_label": "pubyear"  },
  
        { "first": {"value": {"sourcevolume": "26", "sourceissue": "2", "sourcepages": "401-426"}},
          "diff": false, 
          "display_type": "sourceissue_sourcepages_sourcevolume",
          "visibility": "always",
          "display_label": "sourceissue_sourcepages_sourcevolume"
          },
          { "first": { "value": [
            {
              "id": 1090495,
              "name": "Anders Herlitz",
              "x-account": "xherli"
            },
            {
            "id": 1090422295,
            "name": "Anders Herlitz 1",
            "x-account": "xherli"
            },
            {
            "id": 144090495,
            "name": "Anders Herlitz 3",
            "x-account": "xherli"
            },
            {
            "id": 10555590495,
            "name": "Anders Herlitz 4",
            "x-account": "xherli"
            }
          ]
        }, 
          "diff": false, 
          "display_type": "authors",
          "visibility": "always",
          "display_label": "authors"
        },
        { "first": { "value": {"url": "http://https://www.scopus.com/record/display.uri?eid=2-s2.0-${value}&origin=resultslist", "display_title": "85128514182"}}, "diff": false, "display_type": "url", "visibility": "always", "display_label": "scopus"},
        { "first": { "value": {"url": "http://https://www.scopus.com/record/display.uri?eid=2-s2.0-${value}&origin=resultslist", "display_title": "85128514182"}}, "diff": false, "display_type": "url", "visibility": "always", "display_label": "isiid"},
        { "first": { "value": {"url": "http://https://www.scopus.com/record/display.uri?eid=2-s2.0-${value}&origin=resultslist", "display_title": "85128514182"}}, "diff": false, "display_type": "url", "visibility": "always", "display_label": "doi"},
  
      ]
      // await $fetch(`${config.API_BASE_URL}/publications/${id}`);
    return res;
})