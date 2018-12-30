defmodule InSimEx.Packet.Sta do
  @behaviour InSimEx.Packet

  # struct IS_STA // STAte
  # {
  # 	byte	Size;			// 28
  # 	byte	Type;			// ISP_STA
  # 	byte	ReqI;			// ReqI if replying to a request packet
  # 	byte	Zero;
  #
  # 	float	ReplaySpeed;	// 4-byte float - 1.0 is normal speed
  #
  # 	word	Flags;			// ISS state flags (see below)
  # 	byte	InGameCam;		// Which type of camera is selected (see below)
  # 	byte	ViewPLID;		// Unique ID of viewed player (0 = none)
  #
  # 	byte	NumP;			// Number of players in race
  # 	byte	NumConns;		// Number of connections including host
  # 	byte	NumFinished;	// Number finished or qualified
  # 	byte	RaceInProg;		// 0 - no race / 1 - race / 2 - qualifying
  #
  # 	byte	QualMins;
  # 	byte	RaceLaps;		// see "RaceLaps" near the top of this document
  # 	byte	Spare2;
  # 	byte	Spare3;
  #
  # 	char	Track[6];		// short name for track e.g. FE2R
  # 	byte	Weather;		// 0,1,2...
  # 	byte	Wind;			// 0=off 1=weak 2=strong
  # };

  defstruct [
    :req_i,
    :replay_speed,
    :flags,
    :in_game_cam,
    :view_plid,
    :num_p,
    :num_conns,
    :num_finished,
    :race_in_prog,
    :qual_mins,
    :race_laps,
    :track,
    :weather,
    :wind
  ]

  def decode(binary) do
    <<
      28::unsigned-integer-size(8),
      5::unsigned-integer-size(8),
      req_i::unsigned-integer-size(8),
      0::unsigned-integer-size(8),
      replay_speed::float-size(32),
      flags::unsigned-integer-size(16),
      in_game_cam::unsigned-integer-size(8),
      view_plid::unsigned-integer-size(8),
      num_p::unsigned-integer-size(8),
      num_conns::unsigned-integer-size(8),
      num_finished::unsigned-integer-size(8),
      race_in_prog::unsigned-integer-size(8),
      qual_mins::unsigned-integer-size(8),
      race_laps::unsigned-integer-size(8),
      _sp2::unsigned-integer-size(8),
      _sp3::unsigned-integer-size(8),
      track::bitstring-size(48),
      weather::unsigned-integer-size(8),
      wind::unsigned-integer-size(8)
    >> = binary

    track = track
            |> :erlang.binary_to_list()
            |> to_string()
            |> String.trim(<<0>>)

    {:ok, struct!(__MODULE__, %{req_i: req_i, num_conns: num_conns, track: track})}
  end

  def encode(_struct) do
    {:error, "unsupported"}
  end

  def new(params \\ %{}) do
    {:ok, struct!(__MODULE__, params)}
  end
end
