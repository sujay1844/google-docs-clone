defmodule GoogleDocsClone.OperationalTransform do
  @moduledoc """
  Implements operational transformation algorithms for collaborative editing.
  Handles Insert and Delete operations with their transformations.
  """
  alias GoogleDocsClone.Operations
  alias GoogleDocsClone.Repo
  import Ecto.Query

  @doc """
  Transforms the new operation against the old operation.
  """
  def transform(new, old = %{type: "insert"}) do
    cond do
      new.position < old.position ->
        new

      new.position == old.position ->
        # WARN: Might not be correct. Intended for testing.
        new

      new.position > old.position ->
        %{new | position: new.position + old.length}
    end
  end

  def transform(new, old = %{type: "delete"}) do
    cond do
      new.position <= old.position ->
        new

      new.position > old.position ->
        %{new | position: new.position - old.length}
    end
  end

  def transform(new, old) do
    IO.inspect(new, label: "new")
    IO.inspect(old, label: "old")
    raise ArgumentError, "Unsupported operation type"
  end

  def get_newer_operations(id, revision) do
    query =
      from o in Operations,
        where: o.document_id == ^id and o.revision > ^revision,
        order_by: [asc: o.revision]

    Repo.all(query)
  end

  def transform_against_newer_operations(operation, id, revision) do
    Enum.reduce(
      get_newer_operations(id, revision),
      operation,
      fn old, new ->
        transform(new, old)
      end
    )
  end
end
