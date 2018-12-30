defmodule InSimEx.Packet.Isi do
  @behaviour InSimEx.Packet

  @insim_version 7

  # struct IS_ISI // InSim Init - packet to initialise the InSim system
  # {
  # 	byte	Size;		// 44
  # 	byte	Type;		// ISP_ISI
  # 	byte	ReqI;		// If non-zero LFS will send an IS_VER packet
  # 	byte	Zero;		// 0
  #
  # 	word	UDPPort;	// Port for UDP replies from LFS (0 to 65535)
  # 	word	Flags;		// Bit flags for options (see below)
  #
  # 	byte	InSimVer;	// The INSIM_VERSION used by your program
  # 	byte	Prefix;		// Special host message prefix character
  # 	word	Interval;	// Time in ms between NLP or MCI (0 = none)
  #
  # 	char	Admin[16];	// Admin password (if set in LFS)
  # 	char	IName[16];	// A short name for your program
  # };

  defstruct [:req_i, :flags, :insim_ver, :prefix, :interval, :admin, :iname]

  def decode(_) do
    {:error, "not implemented"}
  end

  def encode(struct) do
    {:ok,
     <<
       # size
       44::little-unsigned-integer-size(8),
       # type
       1::little-unsigned-integer-size(8),
       # reqi
       maybe_int(struct.req_i)::little-unsigned-integer-size(8),
       # zero
       0::little-unsigned-integer-size(8),
       # udpport
       0::little-unsigned-integer-size(16),
       # prefix
       0::little-unsigned-integer-size(16),
       @insim_version::little-unsigned-integer-size(8),
       0::little-unsigned-integer-size(8),
       maybe_int(struct.interval)::little-unsigned-integer-size(16)
     >> <>
       String.pad_trailing(maybe_string(struct.admin), 16, <<0>>) <>
       String.pad_trailing("test", 16, <<0>>)}
  end

  def new(params \\ %{}) do
    {:ok, struct!(__MODULE__, params)}
  end

  defp maybe_string(s) when is_binary(s), do: s
  defp maybe_string(_), do: ""

  defp maybe_int(s) when is_integer(s), do: s
  defp maybe_int(_), do: 0
end
