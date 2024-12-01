defmodule GoogleDocsCloneWeb.DocumentController do
  use GoogleDocsCloneWeb, :controller

  def show(conn, %{"id" => id}) do
    conn
    |> put_layout(false)
    |> assign(:id, id)
    |> render(:document)
  end
end
