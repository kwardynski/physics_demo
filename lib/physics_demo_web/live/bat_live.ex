defmodule PhysicsDemoWeb.BatLive do
  use PhysicsDemoWeb, :live_view

  alias GamesEngine.Grid.Point
  alias GamesEngine.Physics
  alias GamesEngine.Physics.Velocity

  @board_width 300
  @board_height 300

  @bat_width 10
  @bat_height 50
  @bat_x_offset 10
  @bat_speed 4

  def render(assigns) do
    ~H"""
    <div id="field" phx-hook="BatHook" phx-window-keydown="key-down" />
    """
  end

  def mount(_params, _session, socket) do
    bat_x = @bat_x_offset
    bat_y = calculate_bat_elevation()

    initial_render_attrs = %{
      board_width: @board_width,
      board_height: @board_height,
      bat_width: @bat_width,
      bat_height: @bat_height,
      bat_x: bat_x,
      bat_y: bat_y
    }

    socket =
      socket
      |> assign(:bat_anchor, Point.new(bat_x, bat_y))
      |> push_event("init", initial_render_attrs)

    {:ok, socket}
  end

  def handle_event("key-down", %{"key" => "ArrowUp"}, socket) do
    %{y: next_bat_top} = Physics.translate(socket.assigns.bat_anchor, up_velocity())
    can_move? = next_bat_top >= 0

    socket = maybe_move_bat(socket, can_move?, next_bat_top)
    {:noreply, socket}
  end

  def handle_event("key-down", %{"key" => "ArrowDown"}, socket) do
    %{y: next_bat_top} = Physics.translate(socket.assigns.bat_anchor, down_velocity())
    can_move? = next_bat_top + @bat_height <= @board_height

    socket = maybe_move_bat(socket, can_move?, next_bat_top)
    {:noreply, socket}
  end

  def handle_event("key-down", _, socket), do: {:noreply, socket}

  defp maybe_move_bat(socket, true, next_bat_top) do
    socket
    |> assign(:bat_anchor, Point.new(@bat_x_offset, next_bat_top))
    |> push_event("move-bat", %{bat_y: next_bat_top})
  end

  defp maybe_move_bat(socket, false, _next_bat_top), do: socket

  defp calculate_bat_elevation, do: (@board_height - @bat_height) / 2

  defp up_velocity, do: Velocity.new(@bat_speed, 270)
  defp down_velocity, do: Velocity.new(@bat_speed, 90)
end
