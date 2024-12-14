defmodule GoogleDocsCloneWeb.DocumentController do
  use GoogleDocsCloneWeb, :controller
  alias GoogleDocsClone.Repo
  alias GoogleDocsClone.Documents

  def show(conn, %{"id" => id}) do
    document =
      case Repo.get(Documents, id) do
        nil ->
          %Documents{id: id, content: "Sample document content"}
          |> Repo.insert!()

        document ->
          document
      end

    conn
    |> put_layout(false)
    |> assign(:id, id)
    |> assign(:content, document.content)
    |> render(:document)
  end
end
