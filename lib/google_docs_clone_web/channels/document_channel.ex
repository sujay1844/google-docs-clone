defmodule GoogleDocsCloneWeb.DocumentChannel do
  use Phoenix.Channel
  require Logger

  def join("document:" <> _id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("delta", %{"delta" => delta, "revision" => revision}, socket) do
    # broadcast the delta to all clients except the sender
    broadcast_from!(socket, "delta", %{delta: delta, revision: revision})

    # send ack to the sender
    push(socket, "ack", %{delta: delta})

    {:noreply, socket}
  end
end
