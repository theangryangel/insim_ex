defmodule InSimEx.Packet.Tiny do
  @behaviour InSimEx.Packet

  # struct IS_TINY // General purpose 4 byte packet
  # {
  # 	byte	Size;		// 4
  # 	byte	Type;		// ISP_TINY
  # 	byte	ReqI;		// 0 unless it is an info request or a reply to an info request
  # 	byte	SubT;		// subtype, from TINY_ enumeration (e.g. TINY_RACE_END)
  # };

  defstruct [:type, :req_i, :sub_t]

  def decode(binary) do
    <<
      4::little-unsigned-integer-size(8),
      # type
      3::little-unsigned-integer-size(8),
      # reqi
      req_i::little-unsigned-integer-size(8),
      # subt
      subtype::little-unsigned-integer-size(8)
    >> = binary

    {:ok, struct!(__MODULE__, %{req_i: req_i, sub_t: subtype})}
  end

  def encode(struct) do
    {:ok,
     <<
       # size
       4::little-unsigned-integer-size(8),
       # type
       3::little-unsigned-integer-size(8),
       # reqi
       maybe_int(struct.req_i)::little-unsigned-integer-size(8),
       # subt
       maybe_int(struct.sub_t)::little-unsigned-integer-size(8)
     >>}
  end

  def new(params \\ %{}) do
    {:ok, struct!(__MODULE__, params)}
  end

  defp maybe_int(s) when is_integer(s), do: s
  defp maybe_int(_), do: 0
end
