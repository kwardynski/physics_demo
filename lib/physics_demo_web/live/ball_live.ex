defmodule PhysicsDemoWeb.BallLive do
  use PhysicsDemoWeb, :live_view

  alias GamesEngine.Grid.Point
  alias GamesEngine.Physics
  alias GamesEngine.Physics.Velocity

  @board_width 300
  @board_height 300

  @speed 2
  @frame_rate 10

  def render(assigns) do
    ~H"""
    <br />
    <div id="ball-field" phx-hook="BallHook" />
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket),
      do: :timer.send_interval(@frame_rate, self(), :tick)

    socket =
      socket
      |> assign(point: Point.new(@board_width / 2, @board_height / 2))
      |> assign(velocity: Velocity.new(@speed, Enum.random(0..360)))
      |> push_event("init", %{width: @board_width, height: @board_height})

    {:ok, socket}
  end

  def handle_info(:tick, socket) do
    point = socket.assigns.point
    velocity = socket.assigns.velocity

    %{x: next_x, y: next_y} = Physics.translate(point, velocity)

    updated_velocity =
      cond do
        next_x < 0 or next_x > @board_height -> Physics.bounce(velocity, :horizontal)
        next_y < 0 or next_y > @board_height -> Physics.bounce(velocity, :vertical)
        true -> velocity
      end

    translated_point = Physics.translate(point, updated_velocity)

    socket =
      socket
      |> assign(point: translated_point)
      |> assign(velocity: updated_velocity)
      |> push_event("update-circle", %{x: translated_point.x, y: translated_point.y})

    {:noreply, socket}
  end
end
