defmodule InSimEx.Packet.Mci do
  @behaviour InSimEx.Packet

  # struct IS_MCI // Multi Car Info - if more than 8 in race then more than one of these is sent
  # {
  # 	byte	Size;		// 4 + NumC * 28
  # 	byte	Type;		// ISP_MCI
  # 	byte	ReqI;		// 0 unless this is a reply to an TINY_MCI request
  # 	byte	NumC;		// number of valid CompCar structs in this packet
  #
  # 	CompCar	Info[8];	// car info for each player, 1 to 8 of these (NumC)
  # };

  defstruct [:req_i, :num_c, :info]

  def decode(binary) do
    <<
      _size::little-unsigned-integer-size(8),
      # type
      38::little-unsigned-integer-size(8),
      # reqi
      req_i::little-unsigned-integer-size(8),
      num_c::little-unsigned-integer-size(8),
      info::binary
    >> = binary

    info = decode_info([], info)

    {:ok, struct!(__MODULE__, %{req_i: req_i, num_c: num_c, info: info})}
  end

  # struct CompCar // Car info in 28 bytes - there is an array of these in the MCI (below)
  # {
  # 	word	Node;		// current path node
  # 	word	Lap;		// current lap
  # 	byte	PLID;		// player's unique id
  # 	byte	Position;	// current race position : 0 = unknown, 1 = leader, etc...
  # 	byte	Info;		// flags and other info - see below
  # 	byte	Sp3;
  # 	int		X;			// X map (65536 = 1 metre)
  # 	int		Y;			// Y map (65536 = 1 metre)
  # 	int		Z;			// Z alt (65536 = 1 metre)
  # 	word	Speed;		// speed (32768 = 100 m/s)
  # 	word	Direction;	// car's motion if Speed > 0 : 0 = world y direction, 32768 = 180 deg
  # 	word	Heading;	// direction of forward axis : 0 = world y direction, 32768 = 180 deg
  # 	short	AngVel;		// signed, rate of change of heading : (16384 = 360 deg/s)
  # };
  #
  # // char			1-byte character
  # byte			1-byte unsigned integer
  # word			2-byte unsigned integer
  # short		2-byte signed integer
  # unsigned		4-byte unsigned integer
  # int			4-byte signed integer
  # float		4-byte float
  #
  defp decode_info(acc, <<
         node::little-unsigned-integer-size(16),
         lap::little-unsigned-integer-size(16),
         plid::little-unsigned-integer-size(8),
         position::little-unsigned-integer-size(8),
         info::little-unsigned-integer-size(8),
         _sp3::little-unsigned-integer-size(8),
         x::little-signed-integer-size(32),
         y::little-signed-integer-size(32),
         z::little-signed-integer-size(32),
         speed::little-unsigned-integer-size(16),
         direction::little-unsigned-integer-size(16),
         heading::little-unsigned-integer-size(16),
         angvel::little-integer-size(16),
         rest::binary
       >>) do
    decode_info(
      acc ++
        [
          %{
            node: node,
            lap: lap,
            plid: plid,
            position: position,
            info: info,
            x: x,
            y: y,
            z: z,
            speed: speed,
            direction: direction,
            heading: heading,
            angvel: angvel
          }
        ],
      rest
    )
  end

  defp decode_info(acc, rest) do

    if byte_size(rest) > 0 do
      raise "FUCKING HELL, sometings fucked!"
    end

    acc
  end

  def encode(_struct) do
    {:error, "unsupported"}
  end

  def new(params \\ %{}) do
    {:ok, struct!(__MODULE__, params)}
  end
end
