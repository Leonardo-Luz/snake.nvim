# snake.nvim

*A Neovim Plugin that provides a text-based Snake game.*

**Dependencies:**

* `leonardo-luz/floatwindow.nvim`
* `nvim-lua/plenary.nvim`

**Installation:**  Add `leonardo-luz/snake.nvim` to your Neovim plugin manager (e.g., `init.lua` or `plugins/snake.lua`).

**Lazy**
```lua
{
  'leonardo-luz/snake.nvim',
  dependencies = {
    {
      'leonardo-luz/floatwindow.nvim',
      'nvim-lua/plenary.nvim',
    },
  },
  opts = {
    wall_collision = false,
    speed = 100,
    map_size = {
      x = 44,
      y = 22,
    },
    max_foods = 3,
    spawn_rate = 5,
    highscore_persistence = false,
    visual = {
      head = {
        "^",
        ">",
        "v",
        "<"
      },
      body = "+",
      food = "x",
      start_pos = "o",
      wall = "#",
      background = " ",
    }
  }
}
```

**Configuration Options**

* `wall_collision` (boolean, default: `false`): Enables/disables wall collisions.  Game over if the snake hits a wall when enabled.
* `speed` (number, default: `100`):  The game speed in milliseconds.  A lower number means faster gameplay.
* `map_size` (table, default: `{x = 44, y = 22}`):  A table defining the game board dimensions: `{x = width, y = height}`.
* `max_foods` (number, default: `3`): The maximum number of food items that can appear on the board at once.
* `spawn_rate` (number, default: `5`): The number of game steps between the spawning of new food items.
* `highscore_persistence` (boolean, default: `false`): Enable this option to persist the highscore between sessions.
* `visual` (table, default: `{head = { "^", ">", "v", "<" }, body = "+", food = "x", start_pos = "o", wall = "#", background = " "}`): Visual of the game.

**Usage:**

* **Start/Stop Game:**  `:Snake`
* **Controls:**
    * `q` or `<Esc><Esc>`: Quit the game.
    * `h`: Move Left
    * `j`: Move Down
    * `k`: Move Up
    * `l`: Move Right
