defmodule GupIndexManager.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      GupIndexManagerWeb.Telemetry,
      # Start the Ecto repository
      GupIndexManager.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: GupIndexManager.PubSub},
      # Start Finch
      {Finch, name: GupIndexManager.Finch},
      # Start the Endpoint (http/https)
      GupIndexManagerWeb.Endpoint
      # Start a worker by calling: GupIndexManager.Worker.start_link(arg)
      # {GupIndexManager.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GupIndexManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GupIndexManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
