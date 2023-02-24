    <template>
    <div>
        <header>
          <div class="container-md">
            <div class="row">
              <div class="col-auto">
                <a :href="getLogoURL" aria-label="Gothenburg University"><div class="logo" :class="getLocale()"></div></a>
                <div style="display:none" class="addfont">NNNNNNNNNN</div>
              </div>
              <div class="col">
                <div class="header">
                  <div class="header-level-1">
                    <a :href="getHeaderURL">
                    {{ t("appheader.header_level1") }}
                    </a>
                  </div>
                  <div class="header-level-2 d-none">
                    {{ t("appheader.header_level2") }}
                  </div>
                </div>
              </div>
              <div class="col-auto align-self-top">
                <LangSelect :locale="t('locale.other_locale_code')">{{t('locale.other_lang')}}</LangSelect>
              </div>
            </div>
          </div>
        </header>
    </div>
</template>

<script setup>
  const { t, getLocale } = useI18n()


  const getHeaderURL = computed(() =>  {
    return t("appheader.header_level1_link");
  })
  const getLogoURL = computed(() => {
        return t("appheader.logo_link");
  })
</script>



<style lang="scss" scoped>
.addfont {
        font-family: NimbusSanNovCon-Bol, "Nimbus Sans Novus Cond Bold",
          Arial Narrow, Helvetica, Arial, "Lucida Grande", sans-serif;
        font-size: 1rem;
        @media (min-width: 768px) {
          font-size: 1.7rem;  
        }
}
  header {
    padding-bottom: 20px;
    border-bottom: 1px solid #ccc;
    margin-bottom: 30px;

    .header {
      text-transform: uppercase;
      padding-top: 16px;
      @media (min-width: 768px) {
        padding-top: 32px;
        padding-left: 10px;
      }

      .header-level-1 {
        font-family: NimbusSanNovCon-Bol, "Nimbus Sans Novus Cond Bold",
          Arial Narrow, Helvetica, Arial, "Lucida Grande", sans-serif;
        font-size: 1rem;
        line-height: 1.2;
        @media (min-width: 768px) {
          font-size: 1.7rem;  
        }
  
        a {
          text-decoration: none;
          color:#000000;
          &:hover {
            text-decoration: underline;
          }
  
        }
      }
      .header-level-2 {
        font-family: NimbusSanNovCon-SemBol, "Nimbus Sans Novus Cond SemiBold",
          Arial Narrow, Helvetica, Arial, "Lucida Grande", sans-serif;
      }
    }

    .logo {
      width: 86px;
      height: 87px;
      @media (min-width: 768px) {
        width: 146px;
        height: 148px;
      }
      background-size: 100%;
      &.en {
        background-image: url("/gu_logo_en_high-faf63c23d8370f48fef9567491132726.png");
      }
      &.sv {
        background-image: url("/gu_logo_sv_high-9dc5fa9d776aa37d0af5991c6abce041.png");
      }
    }
  }
</style>