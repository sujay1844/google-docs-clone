defmodule GoogleDocsCloneWeb.DocumentChannelTest do
  use GoogleDocsCloneWeb.ChannelCase

  alias GoogleDocsClone.{Repo, Documents, DocumentServer}

  setup do
    doc_id = "doc-" <> Integer.to_string(System.unique_integer([:positive]))

    {:ok, %{revision: base}} = DocumentServer.snapshot(doc_id)

    on_exit(fn ->
      case Registry.lookup(GoogleDocsClone.DocumentRegistry, doc_id) do
        [{pid, _}] -> GenServer.stop(pid)
        [] -> :ok
      end
    end)

    {:ok, _, sender} =
      GoogleDocsCloneWeb.DocumentSocket
      |> socket("user_a", %{})
      |> subscribe_and_join(GoogleDocsCloneWeb.DocumentChannel, "document:" <> doc_id)

    %{sender: sender, doc_id: doc_id, base: base}
  end

  test "applying an insert broadcasts and updates revision", %{
    sender: sender,
    doc_id: doc_id,
    base: base
  } do
    push(sender, "operation", %{
      "delta" => %{"ops" => [%{"insert" => "Hi"}]},
      "revision" => base,
      "id" => "op-1"
    })

    assert_broadcast "operation", %{revision: new_rev, id: "op-1", delta: %{"ops" => _}}
    assert new_rev == base + 1

    doc = Repo.get!(Documents, doc_id)
    assert doc.revision == new_rev
    assert String.starts_with?(doc.content, "Hi")
  end

  test "two concurrent ops at the same base both converge", %{
    sender: sender,
    doc_id: doc_id,
    base: base
  } do
    push(sender, "operation", %{
      "delta" => %{"ops" => [%{"insert" => "X"}]},
      "revision" => base,
      "id" => "op-a"
    })

    assert_broadcast "operation", %{revision: rev_after_a, id: "op-a"}

    # Second op sent with the *stale* base; server must transform against the first.
    push(sender, "operation", %{
      "delta" => %{"ops" => [%{"insert" => "Y"}]},
      "revision" => base,
      "id" => "op-b"
    })

    assert_broadcast "operation", %{revision: rev_after_b, id: "op-b"}

    assert rev_after_b == rev_after_a + 1
    doc = Repo.get!(Documents, doc_id)
    assert doc.revision == rev_after_b
    # Both inserted characters survive.
    assert String.contains?(doc.content, "X")
    assert String.contains?(doc.content, "Y")
  end

  test "malformed payload pushes an error", %{sender: sender} do
    ref = push(sender, "operation", %{"nope" => true})
    _ = ref
    assert_push "error", %{reason: "malformed_operation"}
  end
end
