local ts = vim.treesitter
local tsquery = require('nvim-treesitter.query')
local u = reload('adv360_formatter.formatter_utils')

local M = {}

local borders = {
  horizontal = '─',
  vertical = '│',
  table_header_separator = '┬',
  column_intersection = '┼',
  table_footer_separator = '┴',
  table_left_separator = '├',
  table_right_separator = '┤',
  upper_left_corner = '┌',
  bottom_left_corner = '└',
  upper_right_corner = '┐',
  bottom_right_corner = '┘',
}

---@type {row: number, col: number, behavior: string, keys: string[], command: string}
local Cell = {
  row = -1,
  col = -1,
  behavior = '',
  keys = {},
  command = '',
}

---@param props {row: number, col: number, behavior: string | nil, keys: string[] | nil, command: string | nil, blank: boolean | nil}
function Cell:new(props)
  local cell = {
    row = props.row,
    col = props.col,
    behavior = props.behavior or '',
    keys = props.keys or {},
    command = props.command or '',
    blank = props.blank or false,
  }
  setmetatable(cell, self)
  self.__index = self
  return cell
end

local Bindings = {}
Bindings.__index = Bindings

function Bindings:new()
  local cells = {
    { Cell:new({ row = 1, col = 1 }), Cell:new({ row = 1, col = 2 }), Cell:new({ row = 1, col = 3 }),
      Cell:new({ row = 1, col = 4 }), Cell:new({ row = 1, col = 5 }), Cell:new({ row = 1, col = 6 }),
      Cell:new({ row = 1, col = 7 }),
      Cell:new({ row = 1, col = 8, blank = true }), Cell:new({ row = 1, col = 9, blank = true }),
      Cell:new({ row = 1, col = 10, blank = true }), Cell:new({ row = 1, col = 11, blank = true }),
      Cell:new({ row = 1, col = 12, blank = true }), Cell:new({ row = 1, col = 13, blank = true }),
      Cell:new({ row = 1, col = 14, blank = true }), Cell:new({ row = 1, col = 15, blank = true }),
      Cell:new({ row = 1, col = 16 }), Cell:new({ row = 1, col = 17 }), Cell:new({ row = 1, col = 18 }),
      Cell:new({ row = 1, col = 19 }), Cell:new({ row = 1, col = 20 }), Cell:new({ row = 1, col = 21 }),
      Cell:new({ row = 1, col = 22 }), },
    { Cell:new({ row = 2, col = 1 }), Cell:new({ row = 2, col = 2 }), Cell:new({ row = 2, col = 3 }),
      Cell:new({ row = 2, col = 4 }), Cell:new({ row = 2, col = 5 }), Cell:new({ row = 2, col = 6 }),
      Cell:new({ row = 2, col = 7 }),
      Cell:new({ row = 2, col = 8, blank = true }), Cell:new({ row = 2, col = 9, blank = true }),
      Cell:new({ row = 2, col = 10, blank = true }), Cell:new({ row = 2, col = 11, blank = true }),
      Cell:new({ row = 2, col = 12, blank = true }), Cell:new({ row = 2, col = 13, blank = true }),
      Cell:new({ row = 2, col = 14, blank = true }), Cell:new({ row = 2, col = 15, blank = true }),
      Cell:new({ row = 2, col = 16 }), Cell:new({ row = 2, col = 17 }), Cell:new({ row = 2, col = 18 }),
      Cell:new({ row = 2, col = 19 }), Cell:new({ row = 2, col = 20 }), Cell:new({ row = 2, col = 21 }),
      Cell:new({ row = 2, col = 22 }), },
    { Cell:new({ row = 3, col = 1 }), Cell:new({ row = 3, col = 2 }), Cell:new({ row = 3, col = 3 }),
      Cell:new({ row = 3, col = 4 }), Cell:new({ row = 3, col = 5 }), Cell:new({ row = 3, col = 6 }),
      Cell:new({ row = 3, col = 7 }),
      Cell:new({ row = 3, col = 8, blank = true }), Cell:new({ row = 3, col = 9 }),
      Cell:new({ row = 3, col = 10 }), Cell:new({ row = 3, col = 11 }), Cell:new({ row = 3, col = 12 }),
      Cell:new({ row = 3, col = 13 }), Cell:new({ row = 3, col = 14 }), Cell:new({ row = 3, col = 15, blank = true }),
      Cell:new({ row = 3, col = 16 }), Cell:new({ row = 3, col = 17 }), Cell:new({ row = 3, col = 18 }),
      Cell:new({ row = 3, col = 19 }), Cell:new({ row = 3, col = 20 }), Cell:new({ row = 3, col = 21 }),
      Cell:new({ row = 3, col = 22 }), },
    { Cell:new({ row = 4, col = 1 }), Cell:new({ row = 4, col = 2 }), Cell:new({ row = 4, col = 3 }),
      Cell:new({ row = 4, col = 4 }), Cell:new({ row = 4, col = 5 }), Cell:new({ row = 4, col = 6 }),
      Cell:new({ row = 4, col = 7, blank = true }),
      Cell:new({ row = 4, col = 8 }), Cell:new({ row = 4, col = 9 }),
      Cell:new({ row = 4, col = 10 }), Cell:new({ row = 4, col = 11 }), Cell:new({ row = 4, col = 12 }),
      Cell:new({ row = 4, col = 13 }), Cell:new({ row = 4, col = 14 }), Cell:new({ row = 4, col = 15 }),
      Cell:new({ row = 4, col = 16, blank = true }), Cell:new({ row = 4, col = 17 }), Cell:new({ row = 4, col = 18 }),
      Cell:new({ row = 4, col = 19 }), Cell:new({ row = 4, col = 20 }), Cell:new({ row = 4, col = 21 }),
      Cell:new({ row = 4, col = 22 }), },
    { Cell:new({ row = 5, col = 1 }), Cell:new({ row = 5, col = 2 }), Cell:new({ row = 5, col = 3 }),
      Cell:new({ row = 5, col = 4 }), Cell:new({ row = 5, col = 5 }), Cell:new({ row = 5, col = 6, blank = true }),
      Cell:new({ row = 5, col = 7, blank = true }),
      Cell:new({ row = 5, col = 8 }), Cell:new({ row = 5, col = 9 }),
      Cell:new({ row = 5, col = 10 }), Cell:new({ row = 5, col = 11, blank = true }),
      Cell:new({ row = 5, col = 12, blank = true }), Cell:new({ row = 5, col = 13 }), Cell:new({ row = 5, col = 14 }),
      Cell:new({ row = 5, col = 15 }),
      Cell:new({ row = 5, col = 16, blank = true }), Cell:new({ row = 5, col = 17, blank = true }),
      Cell:new({ row = 5, col = 18 }),
      Cell:new({ row = 5, col = 19 }), Cell:new({ row = 5, col = 20 }), Cell:new({ row = 5, col = 21 }),
      Cell:new({ row = 5, col = 22 }), },
  }
  setmetatable({}, self)
  self.cells = cells
  return self
end

---@param col 1 | 2 | 3 | 4 | 5
function Bindings:get_col(col)
  local cells = {}
  for row = 1, #self.cells do
    local cell = self.cells[row][col]
    table.insert(cells, cell)
  end
  return cells
end

---@param row number
function Bindings:get_row(row)
  local cells = {}
  for col = 0, #self.cells[1] do
    local cell = self.cells[row][col]
    table.insert(cells, cell)
  end
  return cells
end

function Bindings:max_length_in_column(col)
  ---@type Cell[]
  local cells = self:get_col(col)
  local max = 0
  for _, cell in ipairs(cells) do
    if cell.behavior then
      max = math.max(#cell.behavior, max)
    end
  end
end

local function get_keymap_bindings()
  local results = u.get_query_results([[
    (node
      name: (identifier) @keymap_node (#eq? @keymap_node "keymap")
      (node
        (property
          name: (identifier) @name (#eq? @name "bindings")
          value: (integer_cells
                   (reference)) @cells)))
  ]], 3)
  return results
end

---@param node TSNode
local format_layer_bindings = function(node)
  for _, child in ipairs(node:named_children()) do
    t(child)
  end
end

M.format = function()
  -- local bindings = get_keymap_bindings()
  -- for _, layer_bindings in ipairs(bindings) do
  --   format_layer_bindings(layer_bindings)
  -- end
  local bindings = Bindings:new()
  for _, col in ipairs(bindings:get_col(1)) do
    p(col)
  end
end

M.format()

return M
