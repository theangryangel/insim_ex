defmodule InSimEx do
  @moduledoc """
  Documentation for InSimEx.
  """

  alias InSimEx.Packet

  use GenServer

  @initial_state %{
    module: nil,
    buffer: <<>>
  }

  @callback handle_connect(socket :: any()) :: nil
  @callback handle_packet(msg :: struct(), socket :: any()) :: nil
  @optional_callbacks handle_packet: 2

  def start_link(module, opts \\ [], genserver_opts \\ []) do
    GenServer.start_link(__MODULE__, {module, opts}, genserver_opts)
  end

  def init({module, opts}) do
    host = Keyword.get(opts, :host, "localhost") |> String.to_charlist()
    port = Keyword.get(opts, :port, 29999)

    with {:ok, socket} <- :gen_tcp.connect(host, port, [:binary]),
         {:ok, isi} <- Packet.encode(%{iname: "test app"}, as: Packet.Isi) do
      :gen_tcp.send(socket, isi)

      apply(module, :handle_connect, [socket])

      {:ok, Map.put(@initial_state, :module, module)}
    else
      {:error, _reason} ->
        {:stop, :connection_failed}
    end
  end

  def handle_info({:tcp, socket, packet}, state) do
    new_buffer = take_packets(<<state.buffer::bitstring, packet::bitstring>>, socket, state)

    {:noreply, %{state | buffer: new_buffer}}
  end

  def handle_info({:tcp_closed, _socket}, _state) do
    IO.inspect("Socket has been closed")
  end

  def handle_info({:tcp_error, socket, reason}, _state) do
    IO.inspect(socket, label: "connection closed due to #{reason}")
  end

  def take_packets(
        <<size_of_packet::unsigned-integer-size(8), _::bitstring>> = buffer,
        socket,
        state
      )
      when byte_size(buffer) >= size_of_packet do
    size_of_packet = size_of_packet * 8
    <<packet::bitstring-size(size_of_packet), rest::bitstring>> = buffer

    with {:ok, decoded_packet} <- Packet.decode(packet) do
      apply(state.module, :handle_packet, [decoded_packet, socket])
    else
      e ->
        IO.inspect(e)
    end

    take_packets(rest, socket, state)
  end

  def take_packets(buffer, _, _state) do
    buffer
  end

  def send_packet(socket, %_{} = packet) do
    with {:ok, packet} <- Packet.encode(packet) do
      :gen_tcp.send(socket, packet)
    else
      e -> e
    end
  end

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)
      import unquote(__MODULE__)

      def handle_packet(%Packet.Tiny{sub_t: 0}, socket) do
        IO.puts("ping? pong!")
        send_packet(socket, %Packet.Tiny{})
      end
    end
  end
end
