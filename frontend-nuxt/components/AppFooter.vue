<template>
    <footer>
      <div class="container">
        <div class="row">
            <div class="col-auto align-self-top">
                <div class="feedback-link">
                  <a class="btn nav-link" :href="t('appfooter.contact_link')" ><font-awesome-icon icon="fa-solid fa-comment" /> {{ t('appfooter.contact_link_text') }}</a>
                </div>
              </div>
        </div>
      </div>  
    </footer>
</template>

<script setup>
const {t} = useI18n();

</script>

<style lang="scss" scoped>
footer {
  margin-top: 50px;
  padding-top: 40px;
  padding-bottom: 40px;
  background-color: #1f1f1f;
  color: #f2f2f2;
  a {
    color: #cccccc;
  }
}
</style>