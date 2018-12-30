defmodule InSimEx.Packet.Rst do
  @behaviour InSimEx.Packet

  # struct IS_RST // Race STart
  # {
  # 	byte	Size;		// 28
  # 	byte	Type;		// ISP_RST
  # 	byte	ReqI;		// 0 unless this is a reply to an TINY_RST request
  # 	byte	Zero;
  #
  # 	byte	RaceLaps;	// 0 if qualifying
  # 	byte	QualMins;	// 0 if race
  # 	byte	NumP;		// number of players in race
  # 	byte	Timing;		// lap timing (see below)
  #
  # 	char	Track[6];	// short track name
  # 	byte	Weather;
  # 	byte	Wind;
  #
  # 	word	Flags;		// race flags (must pit, can reset, etc - see below)
  # 	word	NumNodes;	// total number of nodes in the path
  # 	word	Finish;		// node index - finish line
  # 	word	Split1;		// node index - split 1
  # 	word	Split2;		// node index - split 2
  # 	word	Split3;		// node index - split 3
  # };

  defstruct [
    :req_i,
    :race_laps,
    :qual_mins,
    :num_p,
    :timing,
    :track,
    :weather,
    :wind,
    :flags,
    :num_nodes,
    :finish,
    :split1,
    :split2,
    :split3
  ]

  def decode(binary) do
    <<
      28::little-unsigned-integer-size(8),
      17::little-unsigned-integer-size(8),
      req_i::little-unsigned-integer-size(8),
      0::little-unsigned-integer-size(8),

      race_laps :: little-unsigned-integer-size(8),
      qual_mins :: little-unsigned-integer-size(8),
      num_p :: little-unsigned-integer-size(8),
      timing :: little-unsigned-integer-size(8),

      track::binary-size(48),
      weather::little-unsigned-integer-size(8),
      wind::little-unsigned-integer-size(8),

      flags::little-unsigned-integer-size(16),
      num_nodes::little-unsigned-integer-size(16),
      finish::little-unsigned-integer-size(16),
      split1::little-unsigned-integer-size(16),
      split2::little-unsigned-integer-size(16),
      split3::little-unsigned-integer-size(16)
    >> = binary
    
    track = track
            |> :erlang.binary_to_list()
            |> to_string()
            |> String.trim(<<0>>)

    {:ok, struct!(__MODULE__, %{req_i: req_i, track: track})}
  end

  def encode(_struct) do
    {:error, "unsupported"}
  end

  def new(params \\ %{}) do
    {:ok, struct!(__MODULE__, params)}
  end
end
