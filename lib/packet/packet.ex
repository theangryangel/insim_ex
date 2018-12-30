defmodule InSimEx.Packet do
  @packets [
    {1, __MODULE__.Isi},
    {3, __MODULE__.Tiny},
    {5, __MODULE__.Sta},
    {10, __MODULE__.Ism},
    {11, __MODULE__.Mso},
    {17, __MODULE__.Rst},
    {22, __MODULE__.Pll},
    {23, __MODULE__.Pll},
    {38, __MODULE__.Mci},
    {252, __MODULE__.Relay.Hlr},
    {253, __MODULE__.Relay.Hos},
    {254, __MODULE__.Relay.Sel}
  ]

  @callback new(map()) :: {:ok, struct()} | {:error, binary()}
  @callback decode(bitstring()) :: {:ok, struct()} | {:error, binary()}
  @callback encode(struct()) :: {:ok, bitstring()} | {:error, binary()}

  def new(implementation, map) do
    implementation.new(map)
  end

  def decode(
        <<_::little-unsigned-integer-size(8), packet_type::unsigned-integer-size(8), _::bitstring>> =
          binary
      ) do
    decode(packet_type, binary)
  end

  Enum.each(@packets, fn {id, mod} ->
    defp decode(unquote(id), binary) do
      apply(unquote(mod), :decode, [binary])
    end
  end)

  defp decode(id, _binary) do
    {:error, "unsupported packet", id}
  end

  def encode(struct) do
    apply(struct.__struct__, :encode, [struct])
  end

  def encode(%{} = params, as: implementation) do
    {:ok, struct} = implementation.new(params)

    apply(implementation, :encode, [struct])
  end
end
