defmodule Medusa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies)
    children = [
      MedusaWeb.Telemetry,
      Medusa.Repo,
      {DNSCluster, query: Application.get_env(:medusa, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Medusa.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Medusa.Finch},
      # Start a worker by calling: Medusa.Worker.start_link(arg)
      # {Medusa.Worker, arg},
      # Start to serve requests, typically the last entry
      MedusaWeb.Endpoint,
      {Cluster.Supervisor, [topologies, [name: MyApp.ClusterSupervisor]]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Medusa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MedusaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
