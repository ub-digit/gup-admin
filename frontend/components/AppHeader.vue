<template>
  <div>
    <header>
      <div class="container-fluid">
        <div class="row">
          <div class="col">
            <div class="header">
              <div class="header-level-1">
                <LangLink to="/">
                  {{ t("appheader.header_level1") }}
                </LangLink>
              </div>
              <div class="header-level-2">
                {{ t("appheader.header_level2") }}
              </div>
            </div>
          </div>

          <div class="col-auto align-self-top pt-2">
            <LangSelect :locale="t('locale.other_locale_code')">{{
              t("locale.other_lang")
            }}</LangSelect>
          </div>
          <div class="col-auto align-self-top pt-2">
            <div style="margin-top: 10px" v-if="isLoggedIn">
              <span class="me-2">{{ data.user.name }}</span>
              <span
                ><a href="javascript:void(0)" @click="handeSignOut()"
                  >Logga ut</a
                ></span
              >
            </div>
          </div>
        </div>
      </div>
    </header>
  </div>
</template>

<script lang="ts" setup>
import { useImportedPostsStore } from "~/store/imported_posts";
import { storeToRefs } from "pinia";

const { status, data, signIn, signOut } = useAuth();

const isLoggedIn = computed(() => status.value === "authenticated");

async function handeSignOut() {
  await signOut();
}

const { t, getLocale } = useI18n();

const getHeaderURL = computed(() => {
  return t("appheader.header_level1_link");
});
const getLogoURL = computed(() => {
  return t("appheader.logo_link");
});
</script>

<style lang="scss" scoped>
.addfont {
  font-family: acumin-pro, Helvetica, sans-serif;
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
    padding-top: 20px;
    padding-left: 10px;

    .header-level-1 {
      font-family: acumin-pro-extra-condensed, HelveticaNeue-CondensedBold,
        sans-serif;
      font-size: 1rem;
      font-weight: 700;
      line-height: 1.2;
      @media (min-width: 768px) {
        font-size: 1.7rem;
      }

      a {
        text-decoration: none;
        color: #000000;
        &:hover {
          text-decoration: underline;
        }
      }
    }
    .header-level-2 {
      font-family: acumin-pro, Helvetica, sans-serif;
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
