defmodule InSimEx.Packet.Pll do
  @behaviour InSimEx.Packet

  defstruct [:req_i, :plid]

  def decode(binary) do
    <<
      _size::little-unsigned-integer-size(8),
      23::little-unsigned-integer-size(8),
      0::little-unsigned-integer-size(8),
      # plid
      plid::little-unsigned-integer-size(8),
    >> = binary

    {:ok,
     struct!(__MODULE__, %{
       plid: plid,
     })}
  end

  def encode(_struct) do
    {:error, "unsupported"}
  end

  def new(params \\ %{}) do
    {:ok, struct!(__MODULE__, params)}
  end
end
