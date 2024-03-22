defmodule Conway.ToggleGrid do
  @type coordinate() :: {integer, integer}
  @type grid() :: %{coordinate => boolean}
  @type prepped_grid() :: %{coordinate => {boolean , [boolean]}}
  @doc """
  Create new square toggle board of size n
  """
  @spec new(integer) :: grid
  def new(size) do
    for row <- 1..size, col <- 1..size, into: %{} do
      {{row, col}, false}
    end
  end

  @doc """
  toggles the value at coordinate if it exists.
  """
  @spec toggle(grid, coordinate) :: grid
  def toggle(tg, coord) when is_map_key(tg, coord) do
    Map.update!(tg, coord, &(!&1))
  end

  @doc """
  return the value at the given coord if it exists.
  """
  @spec toggle(grid, coordinate) :: boolean
  def get(tg, coord) when is_map_key(tg, coord) do
    tg[coord]
  end

  @doc """
  returns all the neighbors that are present on the board
  for the given coord if the coord is on the board.
  """
  @spec neighbors(grid, coordinate) :: [coordinate]
  def neighbors(tg, coord) when is_map_key(tg, coord) do
    m = max(tg)

    coord
    |> adjacent()
    |> Enum.filter(fn n ->
      both(n, &(&1 >= 1)) and both(n, &(&1 <= m))
    end)
  end

  @doc """
  Checks whether a givne tuple will evaluate to true (not truthy) values when 
  a given function is applied.
  """
  @spec both({integer, integer}, ({integer, integer} -> boolean)) :: boolean
  def both({x, y}, f) do
    f.(x) and f.(y)
  end

  @doc """
  Gets all adjacent coords, does not check whether adjacenies are on the board.
  """
  @spec adjacent(coordinate) :: list(coordinate)
  def adjacent({x, y}) do
    for x1 <- (x - 1)..(x + 1), y1 <- (y - 1)..(y + 1), {x1, y1} != {x, y} do
      {x1, y1}
    end
  end

  @doc """
  Gets the maximum coord value on a given board.
  """
  @spec max(grid) :: integer
  def max(tg) do
    tg
    |> Enum.max_by(fn {{r, _c}, _v} -> r end)
    |> elem(0)
    |> elem(0)
  end

  # functions for life
  @doc """
  Applies conways game of life rules to a single square 
  given a list containing its neighbor values.
  [conways game of life rules](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)
  """
  @spec square_tick(boolean, [boolean]) :: boolean
  def square_tick(true, neighbors) do
    case Enum.count(neighbors, & &1) do
      live when live < 2 -> false
      live when live > 3 -> false
      _ -> true
    end
  end

  def square_tick(false, neighbors) do
    if Enum.count(neighbors, & &1) == 3, do: true, else: false
  end

  @doc """
  Prepares a toggle board to be run through a life round.
  Each value is mapped to a tuple containing the current value
  and a list of the values of all neighbors.
  """
  @spec prep_board(grid) :: prepped_grid
  def prep_board(tb) do
    tb
    |> Enum.map(fn {k, v} ->
      neighbor_vals =
        neighbors(tb, k)
        |> Enum.map(&get(tb, &1))

      {k, {v, neighbor_vals}}
    end)
    |> Map.new()
  end

  @doc """
  Decides the fate of each square for a round of life.
  The board must be prepped with prep_board before this can 
  be run!
  """
  @spec decide_fate(prepped_grid) :: grid
  def decide_fate(prepped_board) do
    prepped_board 
    |> Enum.map(fn {k, {cv, neighbor_vals}} -> 
      {k, square_tick(cv, neighbor_vals)}
    end)
    |> Map.new()
  end

  @doc """
  Runs one tick of life on the given board
  """
  @spec board_tick(grid) :: grid
  def board_tick(tb) do
    tb
    |> prep_board()
    |> decide_fate()
  end
end
