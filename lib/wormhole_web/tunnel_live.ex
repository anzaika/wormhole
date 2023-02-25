defmodule WormholeWeb.TunnelLive do
  use WormholeWeb, :live_view

  @impl true
  def mount(_, _, socket) do
    peer_id = UUID.uuid4()

    if connected?(socket) do
      Wormhole.Tunnel.add_peer(self(), peer_id)
    end

    {:ok, assign(socket, :peer_id, peer_id)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div id="tunnel" phx-hook="joinTunnel" width="600">
      <video id="remote-stream" playsinline autoplay muted />
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("mediaEvent", %{"data" => data}, socket) do
    send(Wormhole.Tunnel, {:media_event, socket.assigns.peer_id, data})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:media_event, event}, socket) do
    {:noreply, socket |> push_event("mediaEvent", %{event: event})}
  end
end
