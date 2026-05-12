defmodule GoogleDocsClone.Operations do
  use Ecto.Schema
  import Ecto.Changeset

  schema "operations" do
    belongs_to :document, GoogleDocsClone.Documents, type: :string

    field :revision, :integer
    field :delta, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(operation, params \\ %{}) do
    operation
    |> cast(params, [:document_id, :revision, :delta])
    |> validate_required([:document_id, :revision, :delta])
    |> foreign_key_constraint(:document_id)
    |> unique_constraint([:document_id, :revision])
  end
end
