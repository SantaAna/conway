defmodule ToggleGridTest do
  use ExUnit.Case 
  import Conway.ToggleGrid

  test "lonely creature dies" do
    grid = 
      new(4)
      |> toggle({2,2})

      assert get(grid, {2,2}) == true

      grid = board_tick(grid) 

      assert get(grid, {2,2}) == false
  end

  test "square with three neighbors is born" do
    grid = for s <- [{1,1}, {1,2}, {2,1}], reduce: new(4) do
      acc -> toggle(acc, s)
    end

    assert get(grid, {1,1}) == true
    assert get(grid, {1,2}) == true
    assert get(grid, {2,1}) == true
    assert get(grid, {2,2}) == false
    
    grid = board_tick(grid)
    assert get(grid, {2,2}) == true
  end
end
