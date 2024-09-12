defmodule PhysicsDemoWeb.TestLive do
  use PhysicsDemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <br />
    <div id="test" phx-hook="TestHook" />
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket),
      do: :timer.send_interval(1000, self(), :tick)

    {:ok, socket}
  end

  def handle_info(:tick, socket) do
    color = "rgb(#{random_color()}, #{random_color()}, #{random_color()})"
    x_pos = random_position()
    y_pos = random_position()

    {:noreply, push_event(socket, "update-circle", %{color: color, x: x_pos, y: y_pos})}
  end

  defp random_color, do: Enum.random(0..255)
  defp random_position, do: Enum.random(0..300)
end
