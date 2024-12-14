defmodule GoogleDocsClone.Documents do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}

  schema "documents" do
    field :content, :string

    timestamps(type: :utc_datetime)
  end
end
