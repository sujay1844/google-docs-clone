defmodule GoogleDocsCloneWeb.DocumentChannel do
  use Phoenix.Channel
  require Logger

  def join("document:lobby", _message, socket) do
    {:ok, socket}
  end
end
