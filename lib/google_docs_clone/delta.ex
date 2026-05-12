defmodule GoogleDocsClone.Delta do
  @moduledoc """
  Operational Transformation over Quill-compatible deltas.

  A delta is `%{"ops" => [op, ...]}` (or just the ops list). Each op is one of:

    - `%{"insert" => binary}` — insert text
    - `%{"retain" => non_neg_integer}` — keep N characters
    - `%{"delete" => non_neg_integer}` — drop N characters

  Formatting attributes are not supported. Lengths are measured in graphemes,
  which matches Quill's behavior for the Basic Multilingual Plane and diverges
  for emoji/surrogate-pair characters — acceptable for an ASCII/BMP document.
  """

  @type op :: %{optional(String.t()) => term()}
  @type delta :: %{required(String.t()) => [op()]} | [op()]

  @spec ops(delta()) :: [op()]
  def ops(%{"ops" => ops}) when is_list(ops), do: ops
  def ops(ops) when is_list(ops), do: ops

  @spec wrap([op()]) :: %{required(String.t()) => [op()]}
  def wrap(ops), do: %{"ops" => ops}

  @spec op_length(op()) :: non_neg_integer()
  def op_length(%{"insert" => s}) when is_binary(s), do: String.length(s)
  def op_length(%{"retain" => n}) when is_integer(n), do: n
  def op_length(%{"delete" => n}) when is_integer(n), do: n

  @doc "Apply a delta to a string, returning the resulting string."
  @spec apply(String.t(), delta()) :: String.t()
  def apply(doc, delta) when is_binary(doc) do
    do_apply(doc, ops(delta), [])
  end

  defp do_apply(remaining, [], acc),
    do: IO.iodata_to_binary([Enum.reverse(acc), remaining])

  defp do_apply(remaining, [%{"insert" => s} | rest], acc) when is_binary(s),
    do: do_apply(remaining, rest, [s | acc])

  defp do_apply(remaining, [%{"retain" => n} | rest], acc) do
    {kept, tail} = String.split_at(remaining, n)
    do_apply(tail, rest, [kept | acc])
  end

  defp do_apply(remaining, [%{"delete" => n} | rest], acc) do
    {_dropped, tail} = String.split_at(remaining, n)
    do_apply(tail, rest, acc)
  end

  @doc """
  Transform delta `b` against delta `a`. If `priority` is true, `a` is treated as
  having happened first — its inserts shift positions in the resulting `b'`.

  Satisfies TP1: for any string `s`,

      apply(apply(s, a), transform(a, b, true)) == apply(apply(s, b), transform(b, a, false))
  """
  @spec transform(delta(), delta(), boolean()) :: %{required(String.t()) => [op()]}
  def transform(a, b, priority) when is_boolean(priority) do
    do_transform(ops(a), ops(b), priority, [])
    |> Enum.reverse()
    |> chop()
    |> wrap()
  end

  defp do_transform([], [], _priority, acc), do: acc

  defp do_transform([%{"insert" => s} | rest_a], b_ops, true, acc) when is_binary(s),
    do: do_transform(rest_a, b_ops, true, [%{"retain" => String.length(s)} | acc])

  defp do_transform([%{"insert" => _} | _] = a_ops, [%{"insert" => _} = op_b | rest_b], false, acc),
    do: do_transform(a_ops, rest_b, false, [op_b | acc])

  defp do_transform([%{"insert" => s} | rest_a], b_ops, false, acc) when is_binary(s),
    do: do_transform(rest_a, b_ops, false, [%{"retain" => String.length(s)} | acc])

  defp do_transform(a_ops, [%{"insert" => _} = op_b | rest_b], priority, acc),
    do: do_transform(a_ops, rest_b, priority, [op_b | acc])

  defp do_transform([], [op_b | rest_b], priority, acc),
    do: do_transform([], rest_b, priority, [op_b | acc])

  defp do_transform([_ | _], [], _priority, acc), do: acc

  defp do_transform([op_a | rest_a], [op_b | rest_b], priority, acc) do
    len = min(op_length(op_a), op_length(op_b))
    {a_head, a_tail} = take(op_a, len)
    {b_head, b_tail} = take(op_b, len)

    new_acc =
      cond do
        Map.has_key?(a_head, "delete") -> acc
        Map.has_key?(b_head, "delete") -> [b_head | acc]
        true -> [%{"retain" => len} | acc]
      end

    new_a = if a_tail, do: [a_tail | rest_a], else: rest_a
    new_b = if b_tail, do: [b_tail | rest_b], else: rest_b
    do_transform(new_a, new_b, priority, new_acc)
  end

  defp take(%{"insert" => s}, n) when is_binary(s) do
    {first, rest} = String.split_at(s, n)
    {%{"insert" => first}, if(rest == "", do: nil, else: %{"insert" => rest})}
  end

  defp take(%{"retain" => total}, n),
    do: {%{"retain" => n}, if(total - n > 0, do: %{"retain" => total - n}, else: nil)}

  defp take(%{"delete" => total}, n),
    do: {%{"delete" => n}, if(total - n > 0, do: %{"delete" => total - n}, else: nil)}

  @doc "Compose two deltas: a followed by b. apply(s, compose(a, b)) == apply(apply(s, a), b)."
  @spec compose(delta(), delta()) :: %{required(String.t()) => [op()]}
  def compose(a, b) do
    do_compose(ops(a), ops(b), [])
    |> Enum.reverse()
    |> chop()
    |> wrap()
  end

  defp do_compose([], [], acc), do: acc
  defp do_compose([], [op | rest], acc), do: do_compose([], rest, [op | acc])
  defp do_compose([op | rest], [], acc), do: do_compose(rest, [], [op | acc])

  defp do_compose([%{"delete" => _} = a | rest_a], b_ops, acc),
    do: do_compose(rest_a, b_ops, [a | acc])

  defp do_compose(a_ops, [%{"insert" => _} = b | rest_b], acc),
    do: do_compose(a_ops, rest_b, [b | acc])

  defp do_compose([a | rest_a], [b | rest_b], acc) do
    len = min(op_length(a), op_length(b))
    {a_head, a_tail} = take(a, len)
    {b_head, b_tail} = take(b, len)

    new_acc =
      cond do
        # retain + retain -> retain
        Map.has_key?(a_head, "retain") and Map.has_key?(b_head, "retain") ->
          [%{"retain" => len} | acc]

        # retain + delete -> delete
        Map.has_key?(a_head, "retain") and Map.has_key?(b_head, "delete") ->
          [%{"delete" => len} | acc]

        # insert + retain -> insert (kept)
        Map.has_key?(a_head, "insert") and Map.has_key?(b_head, "retain") ->
          [a_head | acc]

        # insert + delete -> nothing (the inserted text is immediately deleted)
        Map.has_key?(a_head, "insert") and Map.has_key?(b_head, "delete") ->
          acc
      end

    new_a = if a_tail, do: [a_tail | rest_a], else: rest_a
    new_b = if b_tail, do: [b_tail | rest_b], else: rest_b
    do_compose(new_a, new_b, new_acc)
  end

  @doc "Strip a trailing pure-retain op (it is a no-op)."
  @spec chop([op()]) :: [op()]
  def chop(ops) do
    case Enum.reverse(ops) do
      [%{"retain" => _} | rest] -> Enum.reverse(rest)
      _ -> ops
    end
  end
end
