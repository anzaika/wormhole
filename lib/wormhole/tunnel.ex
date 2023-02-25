defmodule Wormhole.Tunnel do
  @moduledoc """
  The name comes from the phone switch, as this module essentially fulfills it's role.
  """
  require Membrane.Logger

  use GenServer

  alias Membrane.ICE.TURNManager
  alias Membrane.RTC.Engine
  alias Membrane.RTC.Engine.Message
  alias Membrane.RTC.Engine.Endpoint.WebRTC

  # --- Public API ---

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def add_peer(peer_pid, peer_id) do
    GenServer.call(__MODULE__, {:add_peer, peer_pid, peer_id})
  end

  # --- Internal API ---

  @impl GenServer
  def init(_) do
    turn_options = [
      ip: {0, 0, 0, 0},
      mock_ip: Application.fetch_env!(:wormhole, :ip),
      ports_range: {50000, 59999},
      cert_file: nil
    ]

    network_options = [
      turn_options: turn_options,
      turn_domain: Application.fetch_env!(:wormhole, :host)
    ]

    TURNManager.ensure_tcp_turn_launched(turn_options, port: 49999)

    {:ok, pid} = Engine.start_link([], [])
    Engine.register(pid, self())

    {:ok,
     %{
       rtc_engine: pid,
       peers: %{},
       network_options: network_options,
       simulcast?: false
     }}
  end

  @impl GenServer
  def handle_call({:add_peer, peer_pid, peer_id}, _from, state) do
    state = put_in(state, [:peers, peer_id], peer_pid)

    Membrane.Logger.info("New peer: #{inspect(peer_id)}. Accepting.")
    peer_node = node(peer_pid)

    handshake_opts = [
      client_mode: false,
      dtls_srtp: true
    ]

    endpoint = %WebRTC{
      rtc_engine: state.rtc_engine,
      ice_name: peer_id,
      owner: self(),
      integrated_turn_options: state.network_options[:turn_options],
      integrated_turn_domain: state.network_options[:turn_domain],
      handshake_opts: handshake_opts,
      rtcp_sender_report_interval: Membrane.Time.seconds(5),
      rtcp_receiver_report_interval: Membrane.Time.seconds(5)
    }

    :ok = Engine.add_endpoint(state.rtc_engine, endpoint, peer_id: peer_id, node: peer_node)

    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_info(%Message.EndpointMessage{endpoint_id: to, message: {:media_event, data}}, state) do
    if state.peers[to] != nil do
      send(state.peers[to], {:media_event, data})
    end

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:media_event, from, event} = msg, state) do
    Engine.message_endpoint(state.rtc_engine, from, {:media_event, event})
    {:noreply, state}
  end
end
