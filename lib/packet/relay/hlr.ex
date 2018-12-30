defmodule InSimEx.Packet.Relay.Hlr do
  @behaviour InSimEx.Packet

  # struct IR_HLR // HostList Request
  # {
  # 	byte	Size;		// 4
  # 	byte	Type;		// IRP_HLR
  # 	byte	ReqI;
  # 	byte	Sp0;
  # };

  defstruct [:req_i]

  def decode(binary) do
    {:error, "not supported"}
  end

  def encode(struct) do
    {:ok,
     <<
       # size
       4::unsigned-integer-size(8),
       # type
       252::unsigned-integer-size(8),
       # reqi
       maybe_int(struct.req_i)::unsigned-integer-size(8),
       0::unsigned-integer-size(8)
     >>}
  end

  def new(params \\ %{}) do
    {:ok, struct!(__MODULE__, params)}
  end

  defp maybe_int(s) when is_integer(s), do: s
  defp maybe_int(_), do: 0
end
