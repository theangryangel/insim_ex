defmodule InSimEx.Packet.Relay.Hos do
  @behaviour InSimEx.Packet

  # struct IR_HOS // Hostlist (hosts connected to the Relay)
  # {
  # 	byte	Size;		// 4 + NumHosts * 40
  # 	byte	Type;		// IRP_HOS
  # 	byte	ReqI;		// As given in IR_HLR
  # 	byte	NumHosts;	// Number of hosts described in this packet
  #
  # 	HInfo	Info[6];	// Host info for every host in the Relay. 1 to 6 of these in a IR_HOS
  # };

  defstruct [:req_i, :num_hosts, :info]

  def decode(binary) do
    <<
      _size::unsigned-integer-size(8),
      253::unsigned-integer-size(8),
      req_i::unsigned-integer-size(8),
      num_hosts::unsigned-integer-size(8),
      info::bitstring
    >> = binary

    hosts = decode_hinfo([], info)

    {:ok, struct!(__MODULE__, %{req_i: req_i, num_hosts: num_hosts, info: hosts})}
  end

  defp decode_hinfo(
         acc,
         <<hostname::bitstring-size(256), track::bitstring-size(48),
           flags::unsigned-integer-size(8), num_conns::unsigned-integer-size(8), rest::bitstring>>
       ) do
    acc =
      acc ++
        [
          %{
            hostname: to_string(hostname),
            track: to_string(track),
            flags: flags,
            num_conns: num_conns
          }
        ]

    decode_hinfo(acc, rest)
  end

  defp decode_hinfo(acc, _), do: acc

  def encode(struct) do
    {:error, "not supported"}
  end

  def new(params \\ %{}) do
    {:ok, struct!(__MODULE__, params)}
  end

  defp maybe_int(s) when is_integer(s), do: s
  defp maybe_int(_), do: 0
end
