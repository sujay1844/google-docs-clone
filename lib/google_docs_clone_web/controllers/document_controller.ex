defmodule GoogleDocsCloneWeb.DocumentController do
  use GoogleDocsCloneWeb, :controller
  alias GoogleDocsClone.DocumentServer

  def show(conn, %{"id" => id}) do
    {:ok, %{content: content, revision: revision}} = DocumentServer.snapshot(id)

    conn
    |> put_layout(false)
    |> assign(:id, id)
    |> assign(:content, Base.encode64(content))
    |> assign(:revision, revision)
    |> render(:document)
  end
end
