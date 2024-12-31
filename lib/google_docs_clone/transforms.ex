defmodule GoogleDocsClone.OperationalTransform do
  @moduledoc """
  Implements operational transformation algorithms for collaborative editing.
  Handles Insert and Delete operations with their transformations.
  """

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
end
