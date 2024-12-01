defmodule GoogleDocsClone.Repo do
  use Ecto.Repo,
    otp_app: :google_docs_clone,
    adapter: Ecto.Adapters.SQLite3
end
