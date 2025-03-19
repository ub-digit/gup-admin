<template>
  <div>
    <span v-for="(item, index) in dataMatrix" :key="index">
      <div
        class="row mb-2 me-1 p-2"
        v-if="isVisible(item)"
        :class="{ diff: item.diff }"
      >
        <PostFieldMeta v-if="item.display_type === 'meta'">
          <template v-if="item.second" v-slot:label>
            <div class="col-2"></div>
          </template>
          <template v-slot:content_first>
            <ul class="list-inline">
              <li
                v-if="!item.first.value.attended.value"
                class="list-inline-item"
              >
                <font-awesome-icon
                  class="text-danger"
                  icon="fa-solid fa-flag"
                />
                {{
                  t(
                    `views.publications.post.fields.${item.first.value.attended.display_label}`
                  )
                }}
              </li>
              <br /><br />

              <li class="list-inline-item">
                <strong
                  >{{
                    t(
                      `views.publications.post.fields.${item.first.value.source.display_label}`
                    )
                  }}
                </strong>
                {{ item.first.value.source.value }}
              </li>

              <li
                v-if="item.first.value.created_at.value"
                class="list-inline-item"
              >
                <strong>{{
                  t(
                    `views.publications.post.fields.${item.first.value.created_at.display_label}`
                  )
                }}</strong>
                {{ getDate(item.first.value.created_at.value) }}
                <span v-if="item.first.value.version_created_by.value">
                  {{
                    t(
                      `views.publications.post.fields.${item.first.value.version_created_by.display_label}`
                    )
                  }}
                </span>
                {{ item.first.value.version_created_by.value }}
              </li>

              <li
                v-if="item.first.value.version_updated_by.value"
                class="list-inline-item"
              >
                <strong>{{
                  t(
                    `views.publications.post.fields.${item.first.value.updated_at.display_label}`
                  )
                }}</strong>
                {{ getDate(item.first.value.updated_at.value) }}
                {{
                  t(
                    `views.publications.post.fields.${item.first.value.version_updated_by.display_label}`
                  )
                }}
                {{ item.first.value.version_updated_by.value }}
              </li>
            </ul>
          </template>

          <template v-if="item.second" v-slot:content_second>
            <div class="col">
              <ul class="list-inline">
                <li
                  v-if="!item.second.value.attended.value"
                  class="list-inline-item"
                >
                  <font-awesome-icon
                    class="text-danger"
                    icon="fa-solid fa-flag"
                  />
                  {{
                    t(
                      `views.publications.post.fields.${item.second.value.attended.display_label}`
                    )
                  }}
                </li>
                <br /><br />

                <li class="list-inline-item">
                  <font-awesome-icon
                    class="text-info d-none"
                    icon="fa-solid fa-file-arrow-down"
                  />
                  <strong
                    >{{
                      t(
                        `views.publications.post.fields.${item.second.value.source.display_label}`
                      )
                    }}
                  </strong>
                  {{ item.second.value.source.value }}
                </li>

                <li
                  v-if="item.second.value.created_at.value"
                  class="list-inline-item"
                >
                  <font-awesome-icon
                    class="text-warning d-none"
                    icon="fa-solid fa-award"
                  />
                  <strong>{{
                    t(
                      `views.publications.post.fields.${item.second.value.created_at.display_label}`
                    )
                  }}</strong>
                  {{ getDate(item.second.value.created_at.value) }}
                  {{
                    t(
                      `views.publications.post.fields.${item.second.value.version_created_by.display_label}`
                    )
                  }}
                  {{ item.second.value.version_created_by.value }}
                </li>

                <li
                  v-if="item.second.value.version_updated_by.value"
                  class="list-inline-item"
                >
                  <font-awesome-icon
                    class="text-warning d-none"
                    icon="fa-solid fa-award"
                  />
                  <strong>{{
                    t(
                      `views.publications.post.fields.${item.second.value.updated_at.display_label}`
                    )
                  }}</strong>
                  {{ getDate(item.second.value.updated_at.value) }}
                  {{
                    t(
                      `views.publications.post.fields.${item.second.value.version_updated_by.display_label}`
                    )
                  }}
                  {{ item.second.value.version_updated_by.value }}
                </li>
              </ul>
            </div>
          </template>
        </PostFieldMeta>
        <PostFieldString v-if="item.display_type === 'string'">
          <template v-slot:label>
            <div class="fw-bold" :class="[item.second ? 'col-2' : 'col-4']">
              {{ t(`views.publications.post.fields.${item.display_label}`) }}
            </div>
          </template>
          <template v-slot:content>
            {{ item.first.value }}
          </template>
          <template v-if="item.second" v-slot:content_second>
            <div class="col">
              {{ item.second.value }}
            </div>
          </template>
        </PostFieldString>

        <PostFieldTitle
          v-if="item.display_type === 'title' && item.second"
          :title_first="item.first.value.title"
          :title_second="item.second.value.title"
          :url_second="item.second.value.url"
        />
        <PostFieldTitle
          v-if="item.display_type === 'title' && !item.second"
          :title_first="item.first.value.title"
        />

        <PostFieldString v-if="item.display_type === 'bool'">
          <template v-slot:label>
            <span v-if="item.first.value">
              <font-awesome-icon class="text-danger" icon="fa-solid fa-flag" />
              {{ t(`views.publications.post.fields.${item.display_label}`) }}
            </span>
          </template>
          <template v-slot:content> </template>
          <template v-if="item.second" v-slot:content_second> </template>
        </PostFieldString>
        <PostFieldString v-if="item.display_type === 'date'">
          <template v-slot:label>
            <div class="fw-bold" :class="[item.second ? 'col-2' : 'col-4']">
              {{ t(`views.publications.post.fields.${item.display_label}`) }}
            </div>
          </template>
          <template v-slot:content>
            {{ getDate(item.first.value) }}
          </template>
          <template v-if="item.second" v-slot:content_second>
            <div class="col">
              {{ getDate(item.second.value) }}
            </div>
          </template>
        </PostFieldString>
        <PostFieldString
          v-if="item.display_type === 'sourceissue_sourcepages_sourcevolume'"
        >
          <template v-slot:label>
            <div class="fw-bold" :class="[item.second ? 'col-2' : 'col-4']">
              {{ t(`views.publications.post.fields.${item.display_label}`) }}
            </div>
          </template>
          <template v-slot:content>
            {{ item.first.value.sourcevolume }} |
            {{ item.first.value.sourceissue }} |
            {{ item.first.value.sourcepages }}
          </template>
          <template v-if="item.second" v-slot:content_second>
            <div class="col">
              {{ item.second.value.sourcevolume }} |
              {{ item.second.value.sourceissue }} |
              {{ item.second.value.sourcepages }}
            </div>
          </template>
        </PostFieldString>
        <PostFieldString v-if="item.display_type === 'authors'">
          <template v-slot:label>
            <div class="fw-bold" :class="[item.second ? 'col-2' : 'col-4']">
              {{ t(`views.publications.post.fields.${item.display_label}`) }}
            </div>
          </template>
          <template v-slot:content>
            <ul class="list-unstyled">
              <li v-for="(author, index) in item.first.value" :key="author.id">
                <span v-if="index < numberOfAuthorsToList">
                  {{ author.name }}
                </span>
              </li>
              <li v-if="item.first.value.length > numberOfAuthorsToList">
                + {{ item.first.value.length - numberOfAuthorsToList }}
                {{ t("views.publications.post.more_authors") }}
              </li>
            </ul>
          </template>
          <template v-if="item.second" v-slot:content_second>
            <div class="col">
              <ul class="list-unstyled">
                <li
                  v-for="(author, index) in item.second.value"
                  :key="author.id"
                >
                  <span v-if="index < numberOfAuthorsToList">
                    {{ author.name }}
                  </span>
                </li>
                <li v-if="item.second.value.length > numberOfAuthorsToList">
                  + {{ item.second.value.length - numberOfAuthorsToList }}
                  {{ t("views.publications.post.more_authors") }}
                </li>
              </ul>
            </div>
          </template>
        </PostFieldString>
        <PostFieldString v-if="item.display_type === 'url'">
          <template v-slot:label>
            <div class="fw-bold" :class="[item.second ? 'col-2' : 'col-4']">
              {{ t(`views.publications.post.fields.${item.display_label}`) }}
            </div>
          </template>
          <template v-slot:content>
            <a
              v-if="item.first.value.url"
              target="_blank"
              :href="item.first.value.url"
              >{{ item.first.value.display_title }}</a
            >
            <span v-else>Missing</span>
          </template>
          <template v-if="item.second" v-slot:content_second>
            <div class="col">
              <a
                v-if="item.second.value.url"
                target="_blank"
                :href="item.second.value.url"
                >{{ item.second.value.display_title }}</a
              >
              <span v-else>Missing</span>
            </div>
          </template>
        </PostFieldString>
      </div>
    </span>
  </div>
</template>

<script lang="ts" setup>
const { t } = useI18n();
const props = defineProps(["dataMatrix"]);
const numberOfAuthorsToList = 3;

const getDate = (date: string) => {
  let temp_date = new Date(date);
  return (
    temp_date.getFullYear() +
    "-" +
    ("0" + (temp_date.getMonth() + 1)).slice(-2) +
    "-" +
    ("0" + temp_date.getDate()).slice(-2)
  );
};

const isVisible = (item) => {
  if (item.visibility === "always") {
    return true;
  }
  if (item.visiblity === "never") {
    return false;
  }
  if (item.visiblity === "diff" && item.diff) {
    return true;
  }
};
</script>

<style lang="scss" scoped>
.diff {
  border: 1px dotted red;
}
.bg-danger {
  opacity: 1;
}
.text-white {
  a {
    color: #fff !important;
  }
  color: #fff !important;
}
</style>
