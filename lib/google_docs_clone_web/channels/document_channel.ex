defmodule GoogleDocsCloneWeb.DocumentChannel do
  use Phoenix.Channel
  require Logger

  def join("document:" <> _id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("delta", %{"body" => body, "revision" => revision}, socket) do
    # broadcast the delta to all clients except the sender
    broadcast_from!(socket, "delta", %{body: body})

    # send ack to the sender
    push(socket, "ack", %{status: "ok", revision: revision})

    {:noreply, socket}
  end
end
