defmodule InSimEx.Packet.Mso do
  @behaviour InSimEx.Packet

  # struct IS_MSO // MSg Out - system messages and user messages - variable size
  # {
  # 	byte	Size;		// 12, 16, 20... 136 depending on Msg
  # 	byte	Type;		// ISP_MSO
  # 	byte	ReqI;		// 0
  # 	byte	Zero;
  #
  # 	byte	UCID;		// connection's unique id (0 = host)
  # 	byte	PLID;		// player's unique id (if zero, use UCID)
  # 	byte	UserType;	// set if typed by a user (see User Values below) 
  # 	byte	TextStart;	// first character of the actual text (after player name)
  #
  # 	char	Msg[128];	// 4, 8, 12... 128 characters - last byte is zero
  # };

  defstruct [:req_i, :ucid, :plid, :user_type, :text_start, :msg]

  def decode(binary) do
    <<
      _size::little-unsigned-integer-size(8),
      # type
      11::little-unsigned-integer-size(8),
      # reqi
      req_i::little-unsigned-integer-size(8),
      # zero
      0::little-unsigned-integer-size(8),
      # ucid
      ucid::little-unsigned-integer-size(8),
      # plid
      plid::little-unsigned-integer-size(8),
      # text_start
      text_start::little-unsigned-integer-size(8),
      msg::binary
    >> = binary

    {:ok,
     struct!(__MODULE__, %{
       req_i: req_i,
       ucid: ucid,
       plid: plid,
       text_start: text_start,
       msg: String.trim(to_string(:erlang.binary_to_list(msg)), <<0>>)
     })}
  end

  def encode(_struct) do
    {:error, "unsupported"}
  end

  def new(params \\ %{}) do
    {:ok, struct!(__MODULE__, params)}
  end
end
