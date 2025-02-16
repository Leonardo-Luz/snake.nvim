# snake.nvim

*A Neovim Plugin that provides a text-based Snake game.*

**Dependencies:**

* `leonardo-luz/floatwindow.nvim`

**Installation:**  Add `leonardo-luz/snake.nvim` to your Neovim plugin manager (e.g., `init.lua` or `plugins/snake.lua`).

**Lazy**
```lua
{
  'leonardo-luz/snake.nvim',
  opts = {
    -- Configuration options (see below)
    -- Example: speed = 240,
  }
}
```

**Configuration Options**

* `speed` (number, default: 240):  The game speed in milliseconds.  A lower number means faster gameplay.
* `map_size` (table, default: `{x = 20, y = 20}`):  A table defining the game board dimensions: `{x = width, y = height}`.
* `max_foods` (number, default: 1): The maximum number of food items that can appear on the board at once.
* `spawn_rate` (number, default: 5): The number of game steps between the spawning of new food items.

**Usage:**

* **Start/Stop Game:**  `:Snake`
* **Controls:**
    * `q` or `<Esc><Esc>`: Quit the game.
    * `h`: Move Left
    * `j`: Move Down
    * `k`: Move Up
    * `l`: Move Right
