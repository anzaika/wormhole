import Config

if System.get_env("PHX_SERVER") do
  config :wormhole, WormholeWeb.Endpoint, server: true
end

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :wormhole, WormholeWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end

defmodule ConfigParser do
  # "192.168.1.1" -> {192, 168, 1, 1}
  def ip_string_to_tuple(ip_as_string) do
    with {:ok, ip_as_tuple} <- ip_as_string |> to_charlist() |> :inet.parse_address() do
      ip_as_tuple
    else
      _ ->
        raise("""
        Bad TURN IP format. Expected IPv4, got: \
        #{inspect(ip_as_string)}
        """)
    end
  end
end

config :wormhole,
  host: System.get_env("PHX_HOST"),
  ip: ConfigParser.ip_string_to_tuple(System.get_env("HOST_IP"))
