FROM elixir:alpine as builder
ARG APP_NAME=shipchoice
ARG PHOENIX_SUBDIR=apps/shipchoice_backend
ENV MIX_ENV=prod REPLACE_OS_VARS=true TERM=xterm
WORKDIR /opt/app
RUN apk update \
    && apk --no-cache --update add nodejs nodejs-npm make gcc g++ \
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
    && ./node_modules/brunch/bin/brunch build -p \
    && cd .. \
    && mix phx.digest
RUN mix release --env=prod --verbose \
    && mv _build/prod/rel/${APP_NAME} /opt/release \
    && mv /opt/release/bin/${APP_NAME} /opt/release/bin/start_server

FROM alpine:latest
RUN apk update && apk --no-cache --update add bash openssl-dev
ENV PORT=8080 MIX_ENV=prod REPLACE_OS_VARS=true
WORKDIR /opt/app
EXPOSE ${PORT}
COPY --from=builder /opt/release .
CMD ["/opt/app/bin/start_server", "foreground"]
