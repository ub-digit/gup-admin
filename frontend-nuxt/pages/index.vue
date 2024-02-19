<template>
  <div class="container">
    <div class="row pt-5">
      <div class="col">
        <div class="card">
          <div class="card-body">
            <h2 class="card-title">
              {{ t("views.index.card.publications.header") }}
            </h2>
            <p class="card-text">
              {{ t("views.index.card.publications.body") }}
            </p>
            <LangLink to="/publications" class="btn btn-primary">{{
              t("views.index.card.publications.link_text")
            }}</LangLink>
          </div>
        </div>
      </div>
      <div class="col">
        <div class="card">
          <div class="card-body">
            <h2 class="card-title">
              {{ t("views.index.card.people.header") }}
            </h2>
            <p class="card-text">{{ t("views.index.card.people.body") }}</p>
            <LangLink to="/publications" class="btn btn-primary">{{
              t("views.index.card.people.link_text")
            }}</LangLink>
          </div>
        </div>
      </div>
      <div class="col">
        <div class="card">
          <div class="card-body">
            <h2 class="card-title">
              {{ t("views.index.card.all_data.header") }}
            </h2>
            <p class="card-text">{{ t("views.index.card.all_data.body") }}</p>
            <LangLink to="/publications" class="btn btn-primary">{{
              t("views.index.card.all_data.link_text")
            }}</LangLink>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
const { t } = useI18n();
</script>

<style lang="scss" scoped></style>
