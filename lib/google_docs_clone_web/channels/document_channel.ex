defmodule GoogleDocsCloneWeb.DocumentChannel do
  use Phoenix.Channel
  require Logger

  def join("document:" <> _id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("delta", %{"body" => body}, socket) do
    broadcast_from!(socket, "delta", %{body: body})
    {:noreply, socket}
  end
end
