defmodule GoogleDocsCloneWeb.PageController do
  use GoogleDocsCloneWeb, :controller

  def home(conn, _params) do
    json(conn, %{message: "Welcome to the Google Docs Clone Backend!"})
  end

  def ping(conn, _params) do
    json(conn, %{message: "pong"})
  end
end