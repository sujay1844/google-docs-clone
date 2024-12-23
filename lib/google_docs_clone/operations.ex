defmodule GoogleDocsClone.Operations do
  use Ecto.Schema
  import Ecto.Changeset

  schema "operations" do
    belongs_to :document, GoogleDocsClone.Documents

    field :type, :string
    field :position, :integer
    field :content, :string
    field :length, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(operation, params \\ %{}) do
    operation
    |> cast(params, [:document_id, :type, :position, :content, :length])
    |> validate_required([:document_id, :type])
    |> foreign_key_constraint(:document_id)
  end
end
