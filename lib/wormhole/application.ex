defmodule Wormhole.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WormholeWeb.Telemetry,
      {Phoenix.PubSub, name: Wormhole.PubSub},
      WormholeWeb.Endpoint,
      Wormhole.Tunnel
    ]

    opts = [strategy: :one_for_one, name: Wormhole.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WormholeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
