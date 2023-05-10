import { defineStore } from 'pinia'

export const useLocaleStore = defineStore('locale', {
  state: () => {
    let data = {
      defaultLocale: "sv",
      localeURLname: "lang",
      isWatched: false,
      en: {
        "locale.other_lang": "Svenska",
        "locale.other_locale_code": "sv",
      },
      sv:{
        "seo.application_title": 'Göteborgs universitetsbibliotek - GUP-ADMIN',
        "appheader.logo_link": "http://gu.se/",
        "appheader.header_level1_link": "http://www.ub.gu.se/sv",
        "appheader.header_level1": "Göteborgs universitetsbibliotek",
        "appheader.header_level2": "GUP-ADMIN",

        "views.index.card.publications.header": "Publikationer",
        "views.index.card.publications.body": "Hantera importer av publikationer",
        "views.index.card.publications.link_text": "Gå till hantera publikationer",

        "views.index.card.people.header": "Personer",
        "views.index.card.people.body": "Hantera personer",
        "views.index.card.people.link_text": "Gå till hantera personer",

        "views.index.card.all_data.header": "All data",
        "views.index.card.all_data.body": "Hantera all data",
        "views.index.card.all_data.link_text": "Gå till hantera all data",



        "views.publications.title": "Superduperadmin",

        "views.publications.form.needs_attention": "Needs attention",
        "views.publications.form.source_header": "Visa från",
        "views.publications.form.scopus_title": "Scopus",
        "views.publications.form.wos_title": "WoS",
        "views.publications.form.manual_title": "Manuellt inlagda",
        "views.publications.form.title_label": "Sök på titel eller ID",
        "views.publications.form.pub_type_select_label": "Publikationstyp",
        "views.publications.form.year_select_label": "År",
        "views.publications.result_list.no_imported_posts_found": "Inga importerade poster hittades.",
        "views.publications.result_list.meta.of": "av",
        "views.publications.result_list.meta.posts": "poster",
        


        "views.publications.post.needs_attention": "Needs attention",
        "views.publications.post.fields.source": "Källa",
        "views.publications.post.import_from_scopus": "Import Scopus",
        "views.publications.post.import_from_wos": "Import WoS",
        "views.publications.post.fields.created_at": "Skapad",
        "views.publications.post.fields.version_created_by": "av",
        "views.publications.post.fields.updated_at": "Uppdaterad",
        "views.publications.post.fields.version_updated_by": "av",
        "views.publications.post.result_list.header": "Möjliga dubletter",
        "views.publications.post.result_list_by_id.header": "Dubletter på id",
        "views.publications.post.result_list.no_gup_posts_by_id_found": "Inga gup-poster med dubletter på id hittades",
        "views.publications.post.result_list_by_title.header": "Dubletter på titel",
        "views.publications.post.result_list.no_gup_posts_by_title_found": "Inga gup-poster med dubletter på titel hittades",
        "views.publications.post.fields.id": "ID",
        "views.publications.post.fields.title": "Titel",
        "views.publications.post.fields.attended": "Needs attention",
        "views.publications.post.fields.publication_type_label": "Publikationstyp",
        "views.publications.post.fields.sourcetitle": "Publicerad i",
        "views.publications.post.fields.pubyear": "Publikationsår",
        "views.publications.post.fields.authors": "Författare",
        "views.publications.post.fields.publication_identifiers": "Identifikatorer",
        "views.publications.post.fields.doi": "DOI",
        "views.publications.post.fields.isiid": "ISI-ID",
        "views.publications.post.fields.scopus": "Scopus-ID",
        "views.publications.post.fields.pubmed": "Pubmed-ID",
        "views.publications.post.fields.scopus_missing": "Saknas",
        "views.publications.post.fields.sourceissue_sourcepages_sourcevolume": "Vol/Issue/Pages",
        "views.publications.post.fields.missing": "Saknas",
        "views.publications.post.fields.publication_id": "Orginal ID",
        "views.publications.post.more_authors": "ytterliggare författare",




        "appfooter.contact_link": "https://www.ub.gu.se/node/189487/",
        "appfooter.contact_link_text": "Kontakta oss om GUP-admin",


        "messages.remove_success": "Posten togs bort!",
        "messages.confirm_remove": "Är du säker på att du vill ta bort den importerade posten?",
        "messages.confirm_create_in_gup": "Är du säker på att du vill skapa den importerade posten i GUP?",
        "messages.create_in_gup_success": "Posten skapades i  GUP",
        "messages.create_in_gup_success_body": "Vill du ta bort posten från GUP-ADMIN?",
        "buttons.remove": "Ta bort",
        "buttons.merge": "Slå ihop",
        "buttons.edit": "Redigera",
    
        "locale.other_lang": "English",
        "locale.other_locale_code": "en",
      }
    }
    let locale = fetchLocaleFromURL(data.localeURLname)
    if(!data[locale]) {
      locale = data.defaultLocale
    }
    data["locale"] = locale
    // console.log("Locale", data.locale)
    return data
  },
  actions: {
    setLocale(locale) {
      if(this[locale]) {
        this.locale = locale
      }
      return this.locale
    }
  }
})

export const useI18n = () => {
  const locale = useLocaleStore()
  const route = useRoute()
  if (!locale.isWatched) {
    watchEffect(() => {
      if(!route.query[locale.localeURLname] && route.query.lang !== locale.locale) {
        const router = useRouter()
        let newQuery = {
          ...route.query,
          lang: locale.locale
        }
        // console.log("watchEffect", route.path, newQuery)
        router.replace({query: newQuery})
       
      }
    })
    locale.isWatched = true;
  }


  const interp = (text, args) => {
    if(text) {
      return text.replace(/{([^}]+)?}/gm, (match, p1) => {
        return args[p1] || ""
      })
    }
    return text
  }

  const t = (code, args) => {
    const currentLocale = locale.locale || locale.defaultLocale
    if(!currentLocale || !locale[currentLocale]) { return code }
    const translation = locale[currentLocale][code] || code
    return interp(translation, args)
  }

  const toggleLocale = () => {
    const newLocale = locale.locale == "sv" ? "en" : "sv"
    locale.setLocale(newLocale)
  }

  const setLocale = (newLocale) => {
    // console.log("setLocale", newLocale)
    return locale.setLocale(newLocale)
  }

  const getLocale = () => {
    // console.log("getLocale", locale.locale)
    return locale.locale
  }

  return {
    t,
    toggleLocale,
    getLocale,
    setLocale
  }
}

function fetchLocaleFromURL(localeURLname) {
  const route = useRoute()
  if(route.query[localeURLname]) {
    return route.query[localeURLname]
  } else {
    return null
  }
}
