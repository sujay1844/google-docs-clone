defmodule GoogleDocsCloneWeb.DocumentChannel do
  use Phoenix.Channel
  alias GoogleDocsClone.Repo
  alias GoogleDocsClone.Documents
  alias GoogleDocsClone.DocumentEditor
  require Logger

  def join("document:" <> _id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("operation", %{"operation" => operation, "revision" => revision}, socket) do
    # broadcast the delta to all clients except the sender
    broadcast_from!(socket, "operation", %{operation: operation, revision: revision})

    # get the document id
    "document:" <> id = socket.topic
    # get the document
    document = Repo.get(Documents, id)

    # apply the operation to the document
    new_content = DocumentEditor.apply_operation(document.content, operation)

    # update the document
    new_document = Documents.changeset(document, %{content: new_content})
    Repo.update!(new_document)

    # send ack to the sender
    push(socket, "ack", %{operation: operation})

    {:noreply, socket}
  end
end
