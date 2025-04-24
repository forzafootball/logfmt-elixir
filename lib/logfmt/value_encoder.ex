defprotocol Logfmt.ValueEncoder do
  @fallback_to_any true

  @spec encode(value :: term) :: String.t()
  def encode(value)
end

defimpl Logfmt.ValueEncoder, for: BitString do
  def encode(str), do: str
end

defimpl Logfmt.ValueEncoder, for: Atom do
  def encode(atom), do: Atom.to_string(atom)
end

defimpl Logfmt.ValueEncoder, for: Integer do
  def encode(int), do: Integer.to_string(int)
end

defimpl Logfmt.ValueEncoder, for: Float do
  def encode(float), do: Float.to_string(float)
end

defimpl Logfmt.ValueEncoder, for: PID do
  def encode(pid), do: inspect(pid)
end

defimpl Logfmt.ValueEncoder, for: Reference do
  def encode(ref), do: inspect(ref)
end

defimpl Logfmt.ValueEncoder, for: NaiveDateTime do
  def encode(naive_date_time), do: NaiveDateTime.to_iso8601(naive_date_time)
end

defimpl Logfmt.ValueEncoder, for: DateTime do
  def encode(date_time), do: DateTime.to_iso8601(date_time)
end

defimpl Logfmt.ValueEncoder, for: Function do
  def encode(value) when is_function(value, 0) do
    value.() |> Logfmt.ValueEncoder.encode()
  rescue
    e -> Exception.format(:error, e, __STACKTRACE__)
  end

  def encode(value), do: inspect(value)
end

defimpl Logfmt.ValueEncoder, for: List do
  def encode([]), do: ""
  def encode([value]), do: Logfmt.ValueEncoder.encode(value)

  def encode([a | b] = list) when is_list(b) do
    IO.iodata_to_binary(list)
  rescue
    _ -> Logfmt.ValueEncoder.encode(a) <> Logfmt.ValueEncoder.encode(b)
  end
end

defimpl Logfmt.ValueEncoder, for: Tuple do
  def encode({}), do: ""
  def encode({value}), do: Logfmt.ValueEncoder.encode(value)
  def encode(tuple), do: tuple |> Tuple.to_list() |> Logfmt.ValueEncoder.encode()
end

defimpl Logfmt.ValueEncoder, for: Any do
  def encode(term), do: inspect(term)
end
