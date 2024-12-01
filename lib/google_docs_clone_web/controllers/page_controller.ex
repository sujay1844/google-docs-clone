defmodule GoogleDocsCloneWeb.PageController do
  use GoogleDocsCloneWeb, :controller

  def home(conn, _params) do
    random_id = generate_random_string(10)
    redirect(conn, to: "/document/" <> random_id)
  end

  def ping(conn, _params) do
    json(conn, %{message: "pong"})
  end

  def generate_random_string(length) do
    chars = ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    for _ <- 1..length, into: "", do: <<Enum.random(chars)>>
  end
end
