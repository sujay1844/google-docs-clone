FROM elixir:latest

WORKDIR /app

ENV PORT=4000
EXPOSE 4000

ENV MIX_ENV=prod
ENV DATABASE_PATH=/app/priv/db
ENV SECRET_KEY_BASE="dhyL2lPrPti2boDJjk/zDCkSso5wbOvKcpcQavOkTmWWk1GrlZuJTEv2dr2USO2r"

# Install dependencies.
COPY mix.exs mix.lock ./ 
RUN mix deps.get --only prod

COPY . /app

# Compile the release.
RUN mix compile
RUN mix assets.deploy

CMD ["mix", "phx.server"]