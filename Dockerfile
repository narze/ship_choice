FROM bitwalker/alpine-elixir:1.6.5 as build

COPY . /app

WORKDIR /app

ENV PORT 80
ENV DATABASE_URL localhost
ENV MIX_ENV prod

EXPOSE 80

RUN rm -Rf _build && \
    mix deps.get && \
    mix release

RUN mix phx.digest
