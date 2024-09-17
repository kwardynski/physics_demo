defmodule PhysicsDemoWeb.RandomBounceLive do
  use PhysicsDemoWeb, :live_view

  alias GamesEngine.Grid.Point
  alias GamesEngine.Physics
  alias GamesEngine.Physics.Velocity

  @board_width 450
  @board_height 300

  @bat_width 3
  @bat_height 75
  @bat_x_offset 0
  @bat_speed 5

  @ball_radius 2
  @ball_speed 4
  @frame_rate 15

  def render(assigns) do
    ~H"""
    <div id="field" phx-hook="BoardHook" phx-window-keydown="key-down" />
    """
  end

  def mount(_params, _session, socket) do
    bat_x = @bat_x_offset
    bat_y = calculate_bat_elevation()

    ball_x = @board_width / 2
    ball_y = @board_height / 2

    initial_render_attrs = %{
      board_width: @board_width,
      board_height: @board_height,
      bat_width: @bat_width,
      bat_height: @bat_height,
      bat_x: bat_x,
      bat_y: bat_y,
      ball_radius: @ball_radius,
      ball_x: ball_x,
      ball_y: ball_y
    }

    initial_velocity = random_velocity()

    socket =
      socket
      |> assign(:bat_anchor, Point.new(bat_x, bat_y))
      |> assign(:ball_center, Point.new(ball_x, ball_y))
      |> assign(:ball_velocity, initial_velocity)
      |> push_event("init", initial_render_attrs)

    :timer.send_interval(@frame_rate, self(), "move-ball")

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

  def handle_info("move-ball", socket) do
    ball_center = socket.assigns.ball_center
    ball_velocity = socket.assigns.ball_velocity
    bat_anchor = socket.assigns.bat_anchor

    moved_ball = Physics.translate(ball_center, ball_velocity)

    cond do
      past_top?(moved_ball) -> bounce_ball(socket, :down)
      past_bottom?(ball_center) -> bounce_ball(socket, :up)
      past_right?(moved_ball) -> bounce_ball(socket, :left)
      past_left?(moved_ball) -> bounce_ball(socket, :right)
      hit_paddle?(moved_ball, bat_anchor) -> reset_ball(socket)
      true -> move_ball(socket)
    end
  end

  defp past_top?(ball_center), do: ball_center.y <= 0
  defp past_bottom?(ball_center), do: ball_center.y >= @board_height
  defp past_left?(ball_center), do: ball_center.x <= 0
  defp past_right?(ball_center), do: ball_center.x >= @board_width

  defp hit_paddle?(ball_center, bat_anchor) do
    ball_center.x <= @bat_width &&
      (ball_center.y >= bat_anchor.y && ball_center.y <= bat_anchor.y + @bat_height)
  end

  defp bounce_ball(socket, direction) do
    ball_center = socket.assigns.ball_center

    new_direction =
      case direction do
        :up -> Enum.random(200..340)
        :down -> Enum.random(20..160)
        :left -> Enum.random(110..250)
        :right -> [0..70, 290..360] |> Enum.random() |> Enum.random()
      end

    bounced_velocity = Velocity.new(@ball_speed, new_direction)
    translated_ball_center = Physics.translate(ball_center, bounced_velocity)

    socket =
      socket
      |> assign(:ball_center, translated_ball_center)
      |> assign(:ball_velocity, bounced_velocity)
      |> push_event("move-ball", %{
        ball_x: translated_ball_center.x,
        ball_y: translated_ball_center.y
      })

    {:noreply, socket}
  end

  defp move_ball(socket) do
    ball_velocity = socket.assigns.ball_velocity
    ball_center = socket.assigns.ball_center
    translated_ball_center = Physics.translate(ball_center, ball_velocity)

    socket =
      socket
      |> assign(:ball_center, translated_ball_center)
      |> assign(:ball_velocity, ball_velocity)
      |> push_event("move-ball", %{
        ball_x: translated_ball_center.x,
        ball_y: translated_ball_center.y
      })

    {:noreply, socket}
  end

  defp reset_ball(socket) do
    ball_x = @board_width / 2
    ball_y = @board_height / 2
    ball_center = Point.new(ball_x, ball_y)
    ball_velocity = random_velocity()

    socket =
      socket
      |> assign(:ball_center, ball_center)
      |> assign(:ball_velocity, ball_velocity)
      |> push_event("move-ball", %{ball_x: ball_x, ball_y: ball_y})

    {:noreply, socket}
  end

  defp calculate_bat_elevation, do: (@board_height - @bat_height) / 2

  defp up_velocity, do: Velocity.new(@bat_speed, 270)
  defp down_velocity, do: Velocity.new(@bat_speed, 90)

  defp random_velocity, do: Velocity.new(@ball_speed, Enum.random(0..360))
end
