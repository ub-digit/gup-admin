FROM alpine:latest AS release
RUN apk add --no-cache git

ARG GIT_REVISION
ARG GIT_REPO_URL

WORKDIR /root

RUN set -ex \
  && git clone $GIT_REPO_URL release -b $GIT_REVISION --depth 1

FROM elixir:1.14.4

ENV MIX_ENV=prod
ENV DATABASE_URL=ecto://postgres:postgres@index-manager-db/gup_index_manager_dev
ENV SECRET_KEY_BASE=verysecretkeybasetobehiddenverysecretkeybasetobehiddenverysecretkeybasetobehiddenverysecretkeybasetobehiddenverysecretkeybasetobehiddenverysecretkeybasetobehidden
ENV TZ=Europe/Stockholm
RUN apt-get update && \
    apt-get install -y postgresql-client && \
    apt-get install -y inotify-tools && \
    apt-get clean && rm -f /var/lib/apt/lists/*_*

RUN curl https://repo.hex.pm/installs/1.13.0/rebar3-3.15.2 > rebar3 && \
    mix local.rebar rebar3 ./rebar3 && \
    mix local.hex --force

WORKDIR /app
COPY --from=release /root/release/index_manager ./

RUN mix deps.get && mix deps.compile && mix compile && mix phx.digest
COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh
CMD ["/usr/local/bin/wait-for-it.sh", "index-manager-db:5432", "elasticsearch:9200", "-t", "0", "--", "mix", "phx.server"]
