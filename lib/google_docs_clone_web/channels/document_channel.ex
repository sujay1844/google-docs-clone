defmodule GoogleDocsCloneWeb.DocumentChannel do
  use Phoenix.Channel
  alias GoogleDocsClone.Repo
  alias GoogleDocsClone.Documents
  alias GoogleDocsClone.DocumentEditor
  alias GoogleDocsClone.Operations
  alias GoogleDocsClone.OperationalTransform
  require Logger

  def join("document:" <> _id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("operation", %{"operation" => operation, "revision" => revision}, socket) do
    # get the document id
    "document:" <> id = socket.topic
    # get the document
    document = Repo.get(Documents, id)

    # apply the operation to the document
    new_content = DocumentEditor.apply_operation(document.content, operation)
    new_revision = document.revision + 1

    # update the document
    document
    |> Documents.changeset(%{content: new_content, revision: new_revision})
    |> Repo.update!()

    # add operation to database
    operation
    |> OperationalTransform.transform_against_newer_operations(id, revision)
    |> Map.put("document_id", id)
    |> Map.put("revision", revision)
    |> then(&Operations.changeset(%Operations{}, &1))
    |> Repo.insert!()

    # send ack to the sender
    push(socket, "ack", %{operation: operation, revision: revision, new_revision: new_revision})

    # broadcast the delta to all clients except the sender
    broadcast_from!(socket, "operation", %{operation: operation, revision: new_revision})

    {:noreply, socket}
  end
end
