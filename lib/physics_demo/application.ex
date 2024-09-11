defmodule PhysicsDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhysicsDemoWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:physics_demo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhysicsDemo.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PhysicsDemo.Finch},
      # Start a worker by calling: PhysicsDemo.Worker.start_link(arg)
      # {PhysicsDemo.Worker, arg},
      # Start to serve requests, typically the last entry
      PhysicsDemoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhysicsDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhysicsDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
