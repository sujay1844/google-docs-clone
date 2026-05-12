defmodule GoogleDocsClone.Documents do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}

  schema "documents" do
    field :content, :string, default: ""
    field :revision, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  def changeset(document, params \\ %{}) do
    document
    |> cast(params, [:content, :revision])
    |> validate_required([:content, :revision])
  end
end
