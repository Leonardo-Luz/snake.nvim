## snake.nvim

*A Neovim Plugin that provides a text-based Snake game.*

**Dependencies:**

* `leonardo-luz/floatwindow`

**Installation:**  Add `leonardo-luz/snake.nvim` to your Neovim plugin manager (e.g., `init.lua` or `plugins/snake.lua`).

**Lazy**
```lua
{
  'leonardo-luz/snake.nvim',
  opts = { -- Optional configuration
    speed = 240,          -- Game speed (milliseconds)
    map_size = { x = 20, y = 20 }, -- Game board dimensions
    max_foods = 1,        -- Maximum number of food items on the board
    spawn_rate = 5,       -- Steps between food spawns
  }
}
```

**Usage:**

* Start the game: `:Snake`
* Controls:
    * `q`: Quit
    * `h`: Move Left
    * `j`: Move Down
    * `k`: Move Up
    * `l`: Move Right

