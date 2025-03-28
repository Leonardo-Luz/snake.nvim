local floatwindow = require("floatwindow")

local M = {}

local state = {
  window_config = {
    floating = {
      buf = -1,
      win = -1,
    },
    opts = "",
    enter = nil,
  },
  map = {
    map_size = {
      x = 60,
      y = 40,
    },
    actual = {},
  },
  food = {
    max_foods = 2,
    spawn_rate = 3,
    items = {},
  },
  player = {
    score = 0,
    highscore = 0,
    speed = 70,
    direc = 0,
    old_direc = 0,
    body = {
      {
        y = 4,
        x = 5,
      },
    },
  },
  wall_collision = true,
  restore = {},
  loop = nil,
}

local clear_map = function()
  for i = 1, state.map.map_size.y + 1 do
    local line = ""
    if i == 1 or i == state.map.map_size.y then
      line = string.rep("#", state.map.map_size.x)
    elseif i == state.map.map_size.y + 1 then
      local score = string.format("SCORE:%d", state.player.score)
      local highscore = string.format("HIGHSCORE:%d", state.player.highscore)

      line = string.format(
        "%s%s%s",
        score,
        string.rep(".", state.map.map_size.x - string.len(score) - string.len(highscore)),
        highscore
      )
    else
      line = "#" .. string.rep(" ", state.map.map_size.x - 2) .. "#"
    end
    state.map.actual[i] = line
  end
end

local game_over = function()
  if state.player.score > state.player.highscore then
    state.player.highscore = state.player.score
  end

  state.player.score = 0

  state.player.body = {
    {
      x = 4,
      y = 5,
    },
  }
  state.player.direc = 0
  state.player.old_direc = 0
  state.player.speed = state.restore.player.speed

  state.food.items = {}
  state.food.max_foods = state.restore.food.max_foods
  state.food.spawn_rate = state.restore.food.spawn_rate
end

local window_setup = function()
  local height = vim.o.lines
  local width = vim.o.columns

  return {
    ---@type vim.api.keyset.win_config
    opts = {
      relative = "editor",
      style = "minimal",
      width = state.map.map_size.x,
      height = state.map.map_size.y + 1,
      col = math.floor((width - state.map.map_size.x) / 2),
      row = math.floor((height - state.map.map_size.y + 2) / 2),
    },
    enter = true,
  }
end

local config_remap = function()
  vim.keymap.set("n", "q", function()
    vim.fn.timer_stop(state.loop)
    vim.api.nvim_win_close(state.window_config.floating.win, true)

    state.loop = nil
  end, {
    buffer = state.window_config.floating.buf,
  })

  vim.keymap.set("n", "<Esc><Esc>", function()
    vim.fn.timer_stop(state.loop)
    vim.api.nvim_win_close(state.window_config.floating.win, true)

    state.loop = nil
  end, { buffer = state.window_config.floating.buf })

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

local hit_wall = function()
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
      state.player.score = state.player.score + 1
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

  if state.wall_collision then
    if hit_wall() or eat_itself() then
      game_over()
      return
    end
  else
    if state.player.body[1].x > state.map.map_size.x - 2 then
      state.player.body[1].x = 1
    end
    if state.player.body[1].x < 1 then
      state.player.body[1].x = state.map.map_size.x - 2
    end
    if state.player.body[1].y > state.map.map_size.y - 1 then
      state.player.body[1].y = 2
    end
    if state.player.body[1].y < 2 then
      state.player.body[1].y = state.map.map_size.y - 1
    end

    if eat_itself() then
      game_over()
      return
    end
  end

  for i = 1, #state.food.items do
    local row = state.map.actual[state.food.items[i].y]
    state.map.actual[state.food.items[i].y] = row:sub(1, state.food.items[i].x)
        .. "x"
        .. row:sub(state.food.items[i].x + 2)
  end

  for i = 1, #state.player.body do
    local new_row = state.map.actual[state.player.body[i].y]

    if i == 1 then
      local head = "o"

      if state.player.direc == 1 then
        head = "^"
      elseif state.player.direc == 2 then
        head = ">"
      elseif state.player.direc == 3 then
        head = "v"
      elseif state.player.direc == 4 then
        head = "<"
      end

      state.map.actual[state.player.body[i].y] = new_row:sub(1, state.player.body[i].x)
          .. head
          .. new_row:sub(state.player.body[i].x + 2)
    else
      state.map.actual[state.player.body[i].y] = new_row:sub(1, state.player.body[i].x)
          .. "+"
          .. new_row:sub(state.player.body[i].x + 2)
    end
  end

  vim.api.nvim_buf_set_lines(state.window_config.floating.buf, 0, -1, true, state.map.actual)
end

M.start_game = function()
  math.randomseed(os.time())

  state.restore = {
    player = {
      speed = state.player.speed,
    },
    food = {
      max_foods = state.food.max_foods,
      spawn_rate = state.food.spawn_rate,
    },
  }

  local config = window_setup()

  state.window_config.opts = config.opts
  state.window_config.enter = config.enter

  state.window_config.floating = floatwindow.create_floating_window(state.window_config)

  clear_map()

  config_remap()

  update_content()

  state.loop = vim.fn.timer_start(state.player.speed, update_content, { ["repeat"] = -1 })
end

local toggle_game = function()
  if not vim.api.nvim_win_is_valid(state.window_config.floating.win) then
    M.start_game()
  else
    vim.fn.timer_stop(state.loop)
    vim.api.nvim_win_close(state.window_config.floating.win, true)
  end
end

vim.api.nvim_create_user_command("Snake", toggle_game, {})

---@class snake.Opts
---@field wall_collision boolean: Wall colliion. default: false
---@field speed integer:Milliseconds for each loop. Default: 240
---@field map_size { x: integer, y:integer }: Map size x by x. Default: 20x20
---@field max_foods integer: Max spawned foods on map. Default: 1
---@field spawn_rate integer: Spawn rate of food by loop. Default: 5

---Setup plugin
---@param opts snake.Opts
M.setup = function(opts)
  state.wall_collision = opts.wall_collision
  state.player.speed = opts.speed or 240
  state.map.map_size = opts.map_size or { x = 20, y = 20 }
  state.food.max_foods = opts.max_foods or 1
  state.food.spawn_rate = opts.spawn_rate or 5
end

return M
