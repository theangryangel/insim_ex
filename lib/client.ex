defmodule InSimExClient do
  use InSimEx

  alias InSimEx.Packet

  def start_link(opts \\ []) do
    InSimEx.start_link(__MODULE__, opts)
  end

  def handle_connect(socket) do
    IO.inspect(socket, label: "Connected!")

    # send TINY_ISM request
    send_packet(socket, %Packet.Tiny{req_i: 1, sub_t: 10})

    # send relay request
    send_packet(socket, %Packet.Relay.Hlr{req_i: 2})

    # connect to a specific server via the relay
    send_packet(socket, %Packet.Relay.Sel{req_i: 3, hname: "Nubbins EU Demo"})

    # request state
    send_packet(socket, %Packet.Tiny{req_i: 4, sub_t: 7})
  end

  def handle_packet(%Packet.Sta{track: track}, socket) do
    IO.puts("*** joined #{String.trim(track, <<0>>)} ****")
    Process.exit(self(), :stop)
  end

  def handle_packet(%Packet.Ism{hname: msg} = p, socket) do
    IO.puts("joined #{msg}")
  end

  def handle_packet(%Packet.Mci{} = p, socket) do
    Enum.each(p.info, fn p ->
      IO.puts("#{p.plid} @ {#{p.x}, #{p.y}, #{p.z}} #{p.speed / 146}mph")
    end)
  end

  def handle_packet(%Packet.Relay.Hos{} = p, socket) do
    p.info
    |> Enum.filter(fn host ->
      host.num_conns > 0
    end)
    |> Enum.each(fn host ->
      IO.puts("#{host.hostname} #{host.num_conns}")
    end)
  end

  def handle_packet(p, socket) do
    IO.inspect(p, label: "Unhandled packet")
  end
end
