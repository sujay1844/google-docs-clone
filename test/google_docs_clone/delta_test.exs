defmodule GoogleDocsClone.DeltaTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias GoogleDocsClone.Delta

  describe "apply/2" do
    test "insert and delete on ASCII" do
      assert Delta.apply("Hello, world!", %{
               "ops" => [%{"retain" => 7}, %{"insert" => "beautiful "}]
             }) == "Hello, beautiful world!"

      assert Delta.apply("Hello, world!", %{
               "ops" => [%{"retain" => 7}, %{"delete" => 6}]
             }) == "Hello, !"
    end

    test "trailing retain is a no-op" do
      assert Delta.apply("abc", %{"ops" => [%{"retain" => 3}]}) == "abc"
    end
  end

  describe "transform/3 — TP1 convergence" do
    test "insert vs insert at same position" do
      a = %{"ops" => [%{"insert" => "X"}]}
      b = %{"ops" => [%{"insert" => "Y"}]}

      assert converges?("abc", a, b)
    end

    test "delete vs insert in same range" do
      a = %{"ops" => [%{"retain" => 1}, %{"delete" => 2}]}
      b = %{"ops" => [%{"retain" => 2}, %{"insert" => "X"}]}

      assert converges?("abcd", a, b)
    end

    test "delete vs delete overlapping" do
      a = %{"ops" => [%{"retain" => 1}, %{"delete" => 2}]}
      b = %{"ops" => [%{"retain" => 2}, %{"delete" => 2}]}

      assert converges?("abcde", a, b)
    end

    property "any pair of valid deltas converges (TP1)" do
      check all string <- ascii_string(),
                {a, b} <- two_deltas_over(string),
                max_runs: 200 do
        assert converges?(string, a, b)
      end
    end
  end

  describe "compose/2" do
    property "compose is equivalent to sequential apply" do
      check all string <- ascii_string(),
                a <- delta_over(string),
                b <- delta_over(Delta.apply(string, a)),
                max_runs: 200 do
        assert Delta.apply(string, Delta.compose(a, b)) ==
                 Delta.apply(Delta.apply(string, a), b)
      end
    end
  end

  ## helpers

  defp converges?(s, a, b) do
    b_prime = Delta.transform(a, b, true)
    a_prime = Delta.transform(b, a, false)
    Delta.apply(Delta.apply(s, a), b_prime) == Delta.apply(Delta.apply(s, b), a_prime)
  end

  defp ascii_string do
    StreamData.string(?a..?z, min_length: 0, max_length: 12)
  end

  defp delta_over(string) do
    len = String.length(string)
    StreamData.bind(StreamData.integer(0..min(4, max(len, 0))), fn n_ops ->
      build_delta(len, n_ops, 0, [])
    end)
  end

  defp build_delta(_doc_len, 0, _pos, acc) do
    StreamData.constant(%{"ops" => Enum.reverse(acc)})
  end

  defp build_delta(doc_len, n, pos, acc) when pos >= doc_len do
    StreamData.bind(StreamData.string(?a..?z, min_length: 1, max_length: 4), fn s ->
      build_delta(doc_len, n - 1, pos, [%{"insert" => s} | acc])
    end)
  end

  defp build_delta(doc_len, n, pos, acc) do
    remaining = doc_len - pos

    StreamData.bind(StreamData.integer(0..2), fn kind ->
      case kind do
        0 ->
          StreamData.bind(StreamData.integer(1..remaining), fn r ->
            build_delta(doc_len, n - 1, pos + r, [%{"retain" => r} | acc])
          end)

        1 ->
          StreamData.bind(StreamData.integer(1..remaining), fn d ->
            build_delta(doc_len, n - 1, pos + d, [%{"delete" => d} | acc])
          end)

        2 ->
          StreamData.bind(StreamData.string(?a..?z, min_length: 1, max_length: 3), fn s ->
            build_delta(doc_len, n - 1, pos, [%{"insert" => s} | acc])
          end)
      end
    end)
  end

  defp two_deltas_over(string) do
    StreamData.bind(delta_over(string), fn a ->
      StreamData.bind(delta_over(string), fn b -> StreamData.constant({a, b}) end)
    end)
  end
end
