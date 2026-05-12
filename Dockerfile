FROM elixir:latest

WORKDIR /app

ENV PORT=4000
EXPOSE 4000

ENV MIX_ENV=prod
ENV DATABASE_PATH=/app/priv/db

# Install dependencies.
COPY mix.exs mix.lock ./
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get --only prod

COPY . /app

RUN mix compile
RUN mix assets.deploy

# SECRET_KEY_BASE must be provided at runtime, e.g.:
#   docker run -e SECRET_KEY_BASE=$(mix phx.gen.secret) ...
CMD ["mix", "phx.server"]
