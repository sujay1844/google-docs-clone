defmodule GoogleDocsCloneWeb.DocumentController do
  use GoogleDocsCloneWeb, :controller
  alias GoogleDocsCloneWeb.DefaultDocumentContent
  alias GoogleDocsClone.Repo
  alias GoogleDocsClone.Documents

  def show(conn, %{"id" => id}) do
    document =
      case Repo.get(Documents, id) do
        nil ->
          %Documents{
            id: id,
            content: DefaultDocumentContent.content(),
            revision: 0
          }
          |> Repo.insert!()

        document ->
          document
      end

    conn
    |> put_layout(false)
    |> assign(:id, id)
    |> assign(:content, Base.encode64(document.content))
    |> assign(:revision, document.revision)
    |> render(:document)
  end
end
