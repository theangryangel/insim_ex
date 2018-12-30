defmodule InSimEx.Packet.Ism do
  @behaviour InSimEx.Packet

  # struct IS_ISM // InSim Multi
  # {
  # 	byte	Size;		// 40
  # 	byte	Type;		// ISP_ISM
  # 	byte	ReqI;		// usually 0 / or if a reply : ReqI as received in the TINY_ISM
  # 	byte	Zero;
  #
  # 	byte	Host;		// 0 = guest / 1 = host
  # 	byte	Sp1;
  # 	byte	Sp2;
  # 	byte	Sp3;
  #
  # 	char	HName[32];	// the name of the host joined or started
  # };

  defstruct [:req_i, :host, :hname]

  def decode(binary) do
    <<
      40::little-unsigned-integer-size(8),
      # type
      10::little-unsigned-integer-size(8),
      # reqi
      req_i::little-unsigned-integer-size(8),
      # zero
      0::little-unsigned-integer-size(8),
      # host
      host::little-unsigned-integer-size(8),
      # sp1
      _sp1::little-unsigned-integer-size(8),
      # sp1
      _sp2::little-unsigned-integer-size(8),
      # sp1
      _sp3::little-unsigned-integer-size(8),
      hname::binary
    >> = binary

    {:ok, struct!(__MODULE__, %{req_i: req_i, host: host, hname: hname})}
  end

  def encode(_struct) do
    {:error, "unsupported"}
  end

  def new(params \\ %{}) do
    {:ok, struct!(__MODULE__, params)}
  end
end
