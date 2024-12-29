## snake.nvim

**Dependencies:** This plugin require `leonardo-luz/floatwindow`

**Installation:**  Add `leonardo-luz/snake.nvim` to your Neovim plugin manager (e.g., `init.lua` or `plugins/snake.lua`).

**Lazy**
```lua
{
  'leonardo-luz/snake.nvim',
  opts = {}, -- Default values
  -- OR
  opts = { -- Custom values
    speed = 240,
    map_size = { 
      x = 20, 
      y = 20
    },
    max_foods = 1,
    spawn_rate = 5,
  }
}
```

**Usage:**

* To start playing: `:Snake`
* Navigation:
  * `q`: Quit
  * `h`: Move Left
  * `j`: Move Up
  * `k`: Move Down
  * `l`: Move Right

