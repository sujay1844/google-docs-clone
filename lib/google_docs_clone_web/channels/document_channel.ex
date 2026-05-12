defmodule GoogleDocsCloneWeb.DocumentChannel do
  use Phoenix.Channel
  require Logger

  alias GoogleDocsClone.DocumentServer

  @impl true
  def join("document:" <> _id, _params, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in(
        "operation",
        %{"delta" => delta, "revision" => base, "id" => op_id} = _payload,
        socket
      )
      when is_integer(base) and base >= 0 and is_binary(op_id) do
    "document:" <> doc_id = socket.topic

    case DocumentServer.apply_delta(doc_id, delta, base) do
      {:ok, transformed, new_revision} ->
        # Broadcast to *all* subscribers (including sender). The sender recognizes
        # its own op via `id` and treats it as an ack. Using broadcast for the
        # sender's path too keeps the ordering of acks and remote ops consistent.
        broadcast!(socket, "operation", %{
          delta: transformed,
          revision: new_revision,
          id: op_id
        })

        {:noreply, socket}

      {:error, reason} ->
        Logger.warning("operation rejected on #{doc_id}: #{reason}")
        push(socket, "error", %{reason: to_string(reason), id: op_id})
        {:noreply, socket}
    end
  end

  def handle_in("operation", _payload, socket) do
    push(socket, "error", %{reason: "malformed_operation"})
    {:noreply, socket}
  end
end
