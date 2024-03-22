defmodule ConwayWeb.Grid do
  use ConwayWeb, :live_view
  alias Conway.ToggleGrid
  @size 50
  def mount(_params, _session, socket) do
    {:ok, assign(socket, size: @size, grid: ToggleGrid.new(@size), running: false)}
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-center text-xl mb-3"> The Game of Life </h1>
    <div class="flex flex-row justify-center gap-5 mb-5">
      <.button phx-click="tick">Tick</.button>
      <.button phx-click="clear">Clear</.button>
      <.button phx-click="toggle-run">
        <%= if @running, do: "Stop", else: "Start" %>
      </.button>
    </div>
    <div :for={row <- 1..@size} class="flex flex-row">
      <div
        :for={col <- 1..@size}
        class={[
          "h-3 w-3 border-white border",
          if(ToggleGrid.get(@grid, {row, col}), do: "bg-slate-500", else: "bg-slate-100")
        ]}
        id={"#{row},#{col}"}
        phx-click={on_grid_click(ToggleGrid.get(@grid, {row, col}), row, col)}
      >
      </div>
    </div>
    """
  end

  def handle_event("toggle-run", _unsigned_params, socket) do
    socket
    |> update(:running, &(!&1))
    |> then(fn socket ->
      if socket.assigns.running, do: send(self(), :tick) 
      socket
    end)
    |> then(&{:noreply, &1})
  end

  def handle_event("clear", _unsigned_params, socket) do
    socket
    |> assign(:grid, ToggleGrid.new(@size))
    |> then(&{:noreply, &1})
  end

  def handle_event("tick", _unsigned_params, socket) do
    socket
    |> update(:grid, &ToggleGrid.board_tick(&1))
    |> then(&{:noreply, &1})
  end

  def handle_event("grid-click", %{"row" => row, "col" => col}, socket) do
    socket
    |> update(:grid, &ToggleGrid.toggle(&1, {row, col}))
    |> then(&{:noreply, &1})
  end

  def on_grid_click(_val, row, col, js \\ %JS{}) do
    js
    |> JS.push("grid-click", value: %{row: row, col: col})
  end

  def handle_info(:tick, socket) do
    socket
    |> then(fn socket -> 
      if socket.assigns.running do
        Process.send_after(self(), :tick, 500)
        update(socket, :grid, &ToggleGrid.board_tick/1)
      else
        socket
      end
    end)
    |> then(&{:noreply, &1})
  end
end
