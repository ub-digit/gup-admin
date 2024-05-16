FROM elixir:1.14.4

ENV MIX_ENV=prod
ENV DATABASE_URL=ecto://postgres:postgres@admin-db/gup_admin_dev
ENV SECRET_KEY_BASE=verysecretkeybasetobehiddenverysecretkeybasetobehiddenverysecretkeybasetobehiddenverysecretkeybasetobehiddenverysecretkeybasetobehiddenverysecretkeybasetobehidden
ENV TZ=Europe/Stockholm
RUN apt-get update && \
    apt-get install -y postgresql-client && \
    apt-get install -y inotify-tools && \
    mix local.hex --force && \
    mix archive.install hex phx_new 1.5.10 --force && \
    mix local.rebar --force

ARG GIT_REVISION
ARG GIT_REPO_URL

RUN set -ex \
  && git clone $GIT_REPO_URL release -b $GIT_REVISION --depth 1
ENV APP_HOME /release/backend/
WORKDIR $APP_HOME
RUN mix deps.get && mix deps.compile && mix compile && mix phx.digest
COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh
CMD ["/usr/local/bin/wait-for-it.sh", "admin-db:5432", "elasticsearch:9200", "-t", "0", "--", "mix", "phx.server"]