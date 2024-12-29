local floatwindow = require("floatwindow")

local M = {}

local state = {
  window_config = {},
  map = {
    map_size = {
      x = 40,
      y = 20,
    },
    actual = {},
  },
  food = {
    max_foods = 2,
    spawn_rate = 3,
    items = {},
  },
  player = {
    speed = 240,
    direc = 0,
    old_direc = 0,
    body = {
      {
        y = 4,
        x = 5,
      },
    },
  },
  loop = nil,
}

local clear_map = function()
  for i = 1, state.map.map_size.y do
    local line = ""
    if i == 1 or i == state.map.map_size.y then
      line = string.rep("#", state.map.map_size.x)
    else
      line = "#" .. string.rep(" ", state.map.map_size.x - 2) .. "#"
    end
    state.map.actual[i] = line
  end
end

local game_over = function()
  state.player.body = {}
  state.player.direc = 0
  state.player.body = {
    {
      y = 4,
      x = 5,
    },
  }
  state.food.items = {}
  state.map.actual = {}

  clear_map()

  vim.fn.timer_stop(state.loop)
  vim.api.nvim_win_close(state.window_config.floating.win, true)

  state.loop = nil
end

local window_setup = function()
  local height = vim.o.lines
  local width = vim.o.columns

  return {
    floating = {
      buf = -1,
      win = -1,
    },
    ---@type vim.api.keyset.win_config
    opts = {
      relative = "editor",
      style = "minimal",
      width = state.map.map_size.x,
      height = state.map.map_size.y,
      col = math.floor((width - state.map.map_size.x) / 2),
      row = math.floor((height - state.map.map_size.y) / 2),
    },
    enter = true,
  }
end

local config_remap = function()
  vim.keymap.set("n", "q", function()
    game_over()
  end, {
    buffer = state.window_config.floating.buf,
  })

  vim.keymap.set("n", "h", function()
    if state.player.old_direc ~= 2 then
      state.player.direc = 4
    end
  end, {
    buffer = state.window_config.floating.buf,
  })
  vim.keymap.set("n", "j", function()
    if state.player.old_direc ~= 1 then
      state.player.direc = 3
    end
  end, {
    buffer = state.window_config.floating.buf,
  })
  vim.keymap.set("n", "k", function()
    if state.player.old_direc ~= 3 then
      state.player.direc = 1
    end
  end, {
    buffer = state.window_config.floating.buf,
  })
  vim.keymap.set("n", "l", function()
    if state.player.old_direc ~= 4 then
      state.player.direc = 2
    end
  end, {
    buffer = state.window_config.floating.buf,
  })
end

local loop_count = 0

local out_of_map = function()
  return state.player.body[1].x > state.map.map_size.x - 2
    or state.player.body[1].x < 1
    or state.player.body[1].y > state.map.map_size.y - 1
    or state.player.body[1].y < 2
end

local eat_itself = function()
  for i = #state.player.body, 2, -1 do
    if state.player.body[1].x == state.player.body[i].x and state.player.body[1].y == state.player.body[i].y then
      return true
    end
  end
  return false
end

local update_content = function() end
update_content = function()
  loop_count = loop_count + 1

  if loop_count >= state.food.spawn_rate and #state.food.items < state.food.max_foods then
    local new_fruit = {
      x = math.random(1, state.map.map_size.x - 2),
      y = math.random(2, state.map.map_size.y - 1),
    }
    table.insert(state.food.items, new_fruit)
    loop_count = 0
  elseif #state.food.items >= state.food.max_foods then
    loop_count = 0
  end

  clear_map()

  for i = 1, #state.food.items, 1 do
    if state.player.body[1].x == state.food.items[i].x and state.player.body[1].y == state.food.items[i].y then
      table.insert(state.player.body, { x = state.player.body[1].x, y = state.player.body[1].y })
      table.remove(state.food.items, i)
      break
    end
  end

  for i = #state.player.body, 2, -1 do
    state.player.body[i].x = state.player.body[i - 1].x
    state.player.body[i].y = state.player.body[i - 1].y
  end

  if state.player.direc == 1 then
    state.player.body[1].y = state.player.body[1].y - 1
  elseif state.player.direc == 2 then
    state.player.body[1].x = state.player.body[1].x + 1
  elseif state.player.direc == 3 then
    state.player.body[1].y = state.player.body[1].y + 1
  elseif state.player.direc == 4 then
    state.player.body[1].x = state.player.body[1].x - 1
  end

  state.player.old_direc = state.player.direc

  if out_of_map() or eat_itself() then
    game_over()
    return
  end

  for i = 1, #state.food.items do
    local row = state.map.actual[state.food.items[i].y]
    state.map.actual[state.food.items[i].y] = row:sub(1, state.food.items[i].x)
      .. "x"
      .. row:sub(state.food.items[i].x + 2)
  end

  for i = 1, #state.player.body do
    local new_row = state.map.actual[state.player.body[i].y]
    state.map.actual[state.player.body[i].y] = new_row:sub(1, state.player.body[i].x)
      .. "o"
      .. new_row:sub(state.player.body[i].x + 2)
  end

  vim.api.nvim_buf_set_lines(state.window_config.floating.buf, 0, -1, true, state.map.actual)
end

M.start_game = function()
  math.randomseed(os.time())

  state.window_config = window_setup()
  state.window_config.floating = floatwindow.create_floating_window(state.window_config)

  clear_map()

  config_remap()

  update_content()

  state.loop = vim.fn.timer_start(state.player.speed, update_content, { ["repeat"] = -1 })
end

vim.api.nvim_create_user_command("Exit", game_over, {})

vim.api.nvim_create_user_command("Snake", M.start_game, {})

---@class snake.Opts
---@field speed integer:Milliseconds for each loop. Default: 240
---@field map_size { x: integer, y:integer }: Map size x by x. Default: 20x20
---@field max_foods integer: Max spawned foods on map. Default: 1
---@field spawn_rate integer: Spawn rate of food by loop. Default: 5

---Setup plugin
---@param opts snake.Opts
M.setup = function(opts)
  state.player.speed = opts.speed or 240
  state.map.map_size = opts.map_size or { x = 20, y = 20 }
  state.food.max_foods = opts.max_foods or 1
  state.food.spawn_rate = opts.spawn_rate or 5
end

return M
