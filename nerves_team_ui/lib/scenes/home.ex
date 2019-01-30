defmodule NervesTeamUI.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Scenic.ViewPort

  import Scenic.Primitives
  # import Scenic.Components

  @note """
  NervesTeam
  """

  @text_size 8

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, opts) do
    ScenicFontPressStart2p.load()
    # get the width and height of the viewport. This is to demonstrate creating
    # a transparent full-screen rectangle to catch user input
    {:ok, %ViewPort.Status{size: {width, height}}} = ViewPort.info(opts[:viewport])

    center = {0.5 * width, 0.5 * height}

    graph =
      Graph.build(font: ScenicFontPressStart2p.hash(), font_size: @text_size)
      |> add_specs_to_graph([
        text_spec(@note, text_align: :center, translate: center),
      ])

    send(self(), :connect)

    {:ok, %{
      graph: graph,
      viewport: opts[:viewport]
    }, push: graph}
  end

  def handle_info(:connect, %{viewport: viewport} = state) do
    if PhoenixClient.Socket.connected?(PhoenixClient.Socket) do
      ViewPort.set_root(viewport,
        {NervesTeamUI.Scene.Lobby, nil})
    else
      Process.send_after(self(), :connect, 1_000)
    end
    {:noreply, state}
  end

  def handle_input(event, _context, state) do
    Logger.info("Received event: #{inspect(event)}")
    {:noreply, state}
  end
end
