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

local Binding = function(row, col, behavior, keys, command)
  return {
    row = row,
    col = col,
    behavior = behavior,
    keys = keys,
    command = command,
  }
end

local Bindings = function()
  local bindings = {
    {},
    {},
    {},
    {},
    {},
  }
  local max_col = 21 + 1

  -- populate rows 1 and 2
  local row = 0
  for col = 0, 7 do
    table.insert(bindings[1], Binding(row, col))
    table.insert(bindings[2], Binding(row + 1, col))
  end
  for col = 15, max_col do
    table.insert(bindings[1], Binding(row, col))
    table.insert(bindings[2], Binding(row + 1, col))
  end

  -- populate row 3
  row = 2
  for col = 0, 7 do
    table.insert(bindings[3], Binding(row, col))
  end
  for col = 8, 14 do
    table.insert(bindings[3], Binding(row, col))
  end
  for col = 15, max_col do
    table.insert(bindings[3], Binding(row, col))
  end

  -- populate row 4
  row = 3
  for col = 0, 6 do
    table.insert(bindings[4], Binding(row, col))
  end
  for col = 7, 15 do
    table.insert(bindings[4], Binding(row, col))
  end
  for col = 16, max_col do
    table.insert(bindings[4], Binding(row, col))
  end

  -- populate row 5
  row = 3
  for col = 0, 5 do
    table.insert(bindings[5], Binding(row, col))
  end
  for col = 7, 10 do
    table.insert(bindings[5], Binding(row, col))
  end
  for col = 12, 15 do
    table.insert(bindings[5], Binding(row, col))
  end
  for col = 17, max_col do
    table.insert(bindings[5], Binding(row, col))
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
local get_max_length_in_column = function(parent)
end

---@param node TSNode
local format_layer_bindings = function(node)
  for _, child in ipairs(node:named_children()) do
    t(child)
  end
end

M.format = function()
  local bindings = get_keymap_bindings()
  for _, layer_bindings in ipairs(bindings) do
    format_layer_bindings(layer_bindings)
  end
end

M.format()

return M
