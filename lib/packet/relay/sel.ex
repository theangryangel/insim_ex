defmodule InSimEx.Packet.Relay.Sel do
  @behaviour InSimEx.Packet

  # struct IR_SEL // Relay select - packet to select a host, so relay starts sending you data.
  # {
  # 	byte	Size;		// 68
  # 	byte	Type;		// IRP_SEL
  # 	byte	ReqI;		// If non-zero Relay will reply with an IS_VER packet
  # 	byte	Zero;		// 0
  #
  # 	char	HName[32];	// Hostname to receive data from - may be colourcode stripped
  # 	char	Admin[16];	// Admin password (to gain admin access to host)
  # 	char	Spec[16];	// Spectator password (if host requires it)
  #
  # };

  defstruct [:req_i, :hname, :admin, :spec]

  def decode(_binary) do
    {:error, "not supported"}
  end

  def encode(struct) do
    {:ok,
     <<
       # size
       68::unsigned-integer-size(8),
       # type
       254::unsigned-integer-size(8),
       # reqi
       maybe_int(struct.req_i)::unsigned-integer-size(8),
       # zero
       0::unsigned-integer-size(8)
     >> <>
       maybe_string(struct.hname, 32) <>
       maybe_string(struct.admin, 16) <> maybe_string(struct.spec, 16)}
  end

  def new(params \\ %{}) do
    {:ok, struct!(__MODULE__, params)}
  end

  defp maybe_int(s) when is_integer(s), do: s
  defp maybe_int(_), do: 0

  defp maybe_string(s, length) when is_binary(s), do: String.pad_trailing(s, length, <<0>>)
  defp maybe_string(_, length), do: String.pad_trailing("", length, <<0>>)
end
