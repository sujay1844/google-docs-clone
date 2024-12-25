defmodule GoogleDocsClone.Documents do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :id}

  schema "documents" do
    field :content, :string
    field :revision, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(document, params \\ %{}) do
    document
    |> cast(params, [:content, :revision])
    |> validate_required([:content, :revision])
  end
end

defmodule GoogleDocsClone.DocumentEditor do
  @moduledoc """
  A module to apply operations (insert or delete) to a document string.
  """

  @doc """
  Applies an operation to the document.

  ## Parameters

    - document: The original document (a string).
    - operation: A map representing the operation to apply.
      - For insert: %{type: "insert", position: integer, content: string}
      - For delete: %{type: "delete", position: integer, length: integer}

  ## Examples

      iex> DocumentEditor.apply_operation("Hello, world!", %{type: "insert", position: 7, content: "beautiful "})
      "Hello, beautiful world!"

      iex> DocumentEditor.apply_operation("Hello, world!", %{type: "delete", position: 7, length: 6})
      "Hello, !"
  """
  def apply_operation(document, %{
        "type" => "insert",
        "position" => position,
        "content" => content
      }) do
    {before, after_} = String.split_at(document, position)
    before <> content <> after_
  end

  def apply_operation(document, %{"type" => "delete", "position" => position, "length" => length}) do
    {before, rest} = String.split_at(document, position)
    {_to_delete, after_} = String.split_at(rest, length)
    before <> after_
  end

  def apply_operation(_document, operation) do
    IO.inspect(operation, label: "operation")
    raise ArgumentError, "Unsupported operation type"
  end
end
