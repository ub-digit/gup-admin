import { defineStore } from 'pinia'

export const useLocaleStore = defineStore('locale', {
  state: () => {
    let data = {
      defaultLocale: "sv",
      localeURLname: "lang",
      isWatched: false,
      en: {
        "seo.application_title": 'GUP - superduperadmin',
        "appheader.logo_link": "http://gu.se/",
        "appheader.header_level1_link": "http://www.ub.gu.se/sv",
        "appheader.header_level1": "Göteborgs universitetsbibliotek",
        "appheader.header_level2": "Superduperadmin",

        "views.home.title": "Superduperadmin",

        "appfooter.contact_link": "https://www.ub.gu.se/node/189487/",
        "appfooter.contact_link_text": "Kontakta oss om GUP superduperadmin",


        "locale.other_lang": "Svenska",
        "locale.other_locale_code": "sv",
      },
      sv:{
        "seo.application_title": 'GUP - superduperadmin',
        "appheader.logo_link": "http://gu.se/",
        "appheader.header_level1_link": "http://www.ub.gu.se/sv",
        "appheader.header_level1": "Göteborgs universitetsbibliotek",
        "appheader.header_level2": "Superduperadmin",

        "views.home.title": "Superduperadmin",

        "views.home.form.needs_attention": "Needs attention",
        "views.home.form.source_header": "Visa från",
        "views.home.form.scopus_title": "Scopus",
        "views.home.form.wos_title": "Web of Science",
        "views.home.form.manual_title": "Manuellt inlagda",
        "views.home.form.title_label": "Titel",
        "views.home.form.pub_type_select_label": "Publikationstyp",

        "appfooter.contact_link": "https://www.ub.gu.se/node/189487/",
        "appfooter.contact_link_text": "Kontakta oss om GUP superduperadmin",

        "buttons.remove": "Ta bort",
        "buttons.merge": "Slå ihop",
        "buttons.edit": "Redigera",

        "pubtypes.journal_article": "journal_article",
        "pubtypes.review_article": "review_article",
        "pubtypes.magazine_article": "magazine_article",
        "pubtypes.editorial_letter": "editorial_letter",    
    
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
