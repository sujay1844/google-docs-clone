defmodule GoogleDocsCloneWeb.DocumentChannel do
  use Phoenix.Channel
  require Logger

  def join("document:" <> _id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("operation", %{"operation" => operation, "revision" => revision}, socket) do
    # broadcast the delta to all clients except the sender
    broadcast_from!(socket, "operation", %{operation: operation, revision: revision})

    # send ack to the sender
    push(socket, "ack", %{operation: operation})

    {:noreply, socket}
  end
end
