defmodule GoogleDocsClone.DocumentServer do
  @moduledoc """
  One GenServer per document. Serializes the read-modify-write cycle for
  applying deltas: load current state, transform the incoming delta against
  any operations newer than the client's base revision, persist the result,
  bump the revision, return the transformed delta and the new revision.
  """

  use GenServer, restart: :transient
  require Logger
  import Ecto.Query

  alias GoogleDocsClone.{Repo, Documents, Operations, Delta}
  alias GoogleDocsCloneWeb.DefaultDocumentContent

  @registry GoogleDocsClone.DocumentRegistry
  @supervisor GoogleDocsClone.DocumentSupervisor
  # Stop the server after this many ms of inactivity to keep memory bounded.
  @idle_timeout :timer.minutes(10)

  ## public API

  def start_link(id) when is_binary(id) do
    GenServer.start_link(__MODULE__, id, name: via(id))
  end

  def child_spec(id) do
    %{
      id: {__MODULE__, id},
      start: {__MODULE__, :start_link, [id]},
      restart: :transient,
      type: :worker
    }
  end

  @spec apply_delta(String.t(), GoogleDocsClone.Delta.delta(), non_neg_integer()) ::
          {:ok, map(), non_neg_integer()} | {:error, atom()}
  def apply_delta(id, delta, base_revision)
      when is_binary(id) and is_integer(base_revision) and base_revision >= 0 do
    with {:ok, _pid} <- ensure_started(id) do
      GenServer.call(via(id), {:apply_delta, delta, base_revision})
    end
  end

  @spec snapshot(String.t()) :: {:ok, %{content: String.t(), revision: non_neg_integer()}}
  def snapshot(id) do
    with {:ok, _pid} <- ensure_started(id) do
      GenServer.call(via(id), :snapshot)
    end
  end

  defp via(id), do: {:via, Registry, {@registry, id}}

  defp ensure_started(id) do
    case DynamicSupervisor.start_child(@supervisor, {__MODULE__, id}) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, _} = err -> err
    end
  end

  ## callbacks

  @impl true
  def init(id) do
    doc = load_or_create(id)
    state = %{id: id, content: doc.content, revision: doc.revision || 0}
    {:ok, state, @idle_timeout}
  end

  @impl true
  def handle_call({:apply_delta, _delta, base_revision}, _from, %{revision: rev} = state)
      when base_revision > rev do
    {:reply, {:error, :base_revision_in_future}, state, @idle_timeout}
  end

  def handle_call({:apply_delta, delta, base_revision}, _from, state) do
    transformed = transform_against_newer(delta, state.id, base_revision)

    try do
      new_content = Delta.apply(state.content, transformed)
      new_revision = state.revision + 1

      Repo.transaction(fn ->
        from(d in Documents, where: d.id == ^state.id)
        |> Repo.update_all(set: [content: new_content, revision: new_revision])

        Operations.changeset(%Operations{}, %{
          document_id: state.id,
          revision: new_revision,
          delta: Jason.encode!(transformed)
        })
        |> Repo.insert!()
      end)

      new_state = %{state | content: new_content, revision: new_revision}
      {:reply, {:ok, transformed, new_revision}, new_state, @idle_timeout}
    rescue
      e ->
        Logger.error("Failed to apply delta on #{state.id}: #{Exception.message(e)}")
        {:reply, {:error, :apply_failed}, state, @idle_timeout}
    end
  end

  def handle_call(:snapshot, _from, state) do
    {:reply, {:ok, %{content: state.content, revision: state.revision}}, state, @idle_timeout}
  end

  @impl true
  def handle_info(:timeout, state), do: {:stop, :normal, state}
  def handle_info(_msg, state), do: {:noreply, state, @idle_timeout}

  ## helpers

  defp load_or_create(id) do
    case Repo.get(Documents, id) do
      nil ->
        %Documents{
          id: id,
          content: DefaultDocumentContent.content(),
          revision: 0
        }
        |> Repo.insert!()

      doc ->
        doc
    end
  end

  defp transform_against_newer(delta, id, base_revision) do
    from(o in Operations,
      where: o.document_id == ^id and o.revision > ^base_revision,
      order_by: [asc: o.revision],
      select: o.delta
    )
    |> Repo.all()
    |> Enum.reduce(delta, fn old_json, acc ->
      old = Jason.decode!(old_json)
      Delta.transform(old, acc, true)
    end)
  end
end
