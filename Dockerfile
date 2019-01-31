ARG ALPINE_VERSION=3.8

# Build image
FROM elixir:1.7.2-alpine AS builder

ARG APP_NAME=shipchoice
ARG PHOENIX_SUBDIR=apps/shipchoice_backend
ENV MIX_ENV=prod REPLACE_OS_VARS=true TERM=xterm

WORKDIR /opt/app

RUN apk add --no-cache --update \
    nodejs nodejs-npm make gcc g++ git build-base \
    && mix local.rebar --force \
    && mix local.hex --force

COPY . .

RUN mix deps.get

RUN cd deps/bcrypt_elixir \
    && make clean \
    && make \
    && cd ..

RUN mix do deps.compile, compile

RUN cd ${PHOENIX_SUBDIR}/assets \
    && npm install \
    && npm run deploy \
    && cd .. \
    && mix phx.digest

RUN mix release --env=prod --verbose \
    && mv _build/prod/rel/${APP_NAME} /opt/release \
    && mv /opt/release/bin/${APP_NAME} /opt/release/bin/start_server

# Release image
FROM alpine:${ALPINE_VERSION}

RUN apk update \
    && apk add --no-cache --update bash openssl-dev

ENV PORT=8080 MIX_ENV=prod REPLACE_OS_VARS=true

# Dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

WORKDIR /app
RUN chown -R nobody: /app

EXPOSE ${PORT}

COPY --from=builder /opt/release .

CMD ["/app/bin/start_server", "foreground"]
