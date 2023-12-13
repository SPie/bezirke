defmodule Bezirke.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BezirkeWeb.Telemetry,
      Bezirke.Repo,
      {DNSCluster, query: Application.get_env(:bezirke, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Bezirke.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Bezirke.Finch},
      # Start a worker by calling: Bezirke.Worker.start_link(arg)
      # {Bezirke.Worker, arg},
      # Start to serve requests, typically the last entry
      BezirkeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bezirke.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BezirkeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
