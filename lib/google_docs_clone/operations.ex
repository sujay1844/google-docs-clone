defmodule GoogleDocsClone.Operations do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias GoogleDocsClone.Repo

  schema "operations" do
    belongs_to :document, GoogleDocsClone.Documents, type: :string

    field :revision, :integer
    field :type, :string
    field :position, :integer
    field :content, :string
    field :length, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(operation, params \\ %{}) do
    operation
    |> cast(params, [:document_id, :revision, :type, :position, :content, :length])
    |> validate_required([:document_id, :revision, :type])
    |> foreign_key_constraint(:document_id)
  end
end
