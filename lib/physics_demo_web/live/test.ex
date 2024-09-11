defmodule PhysicsDemoWeb.Test do
  use PhysicsDemoWeb, :live_view

  defp bump, do: Process.send_after(self(), "bump", 500)

  def render(assigns) do
    ~H"""
    <%= @bumps %>
    """
  end

  def mount(_params, _session, socket) do
    bump()
    {:ok, assign(socket, bumps: 0)}
  end

  def handle_info("bump", socket) do
    new_bumps = socket.assigns.bumps + 1
    bump()

    {:noreply, assign(socket, bumps: new_bumps)}
  end
end
