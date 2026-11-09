--- Native statusline: git branch and diff, file, LSP progress, diagnostics,
--- filetype and cursor position. Set with `statusline=%!v:lua.require'statusline'.render()`.
local M = {}

---@class statusline.State
---@field head string Git branch, empty outside a repository.
---@field diff string Hunk summary such as `+1 ~2 -3`, empty when clean.
---@field lsp string LSP progress, empty when idle or in an inactive window.
---@field diagnostics string Pre-highlighted counts from `vim.diagnostic.status()`.
---@field filetype string
---@field fileformat string
---@field fileencoding string

local SEP = ' | '

--- Escape `%` so buffer-derived text is not parsed as statusline items.
---@param s string
---@return string
local function escape(s)
  return (s:gsub('%%', '%%%%'))
end

--- Encoding and line endings, shown only when they differ from utf-8/unix.
---@param s statusline.State
---@return string
local function file_format(s)
  local parts = {}
  if s.fileencoding ~= '' and s.fileencoding ~= 'utf-8' then
    table.insert(parts, s.fileencoding)
  end
  if s.fileformat ~= 'unix' then
    table.insert(parts, s.fileformat)
  end
  return table.concat(parts, ' ')
end

--- Build a statusline string from a snapshot of window state.
---@param s statusline.State
---@return string
function M.build(s)
  local left = ' '
  if s.head ~= '' then
    left = left .. escape(vim.trim(s.head .. ' ' .. s.diff)) .. SEP
  end
  left = left .. '%<%f %h%w%m%r'

  local right = vim.tbl_filter(function(part) return part ~= '' end, {
    escape(s.lsp),
    s.diagnostics,
    s.filetype,
    file_format(s),
    '%l:%c %P',
  })

  return left .. '%=' .. table.concat(right, SEP) .. ' '
end

--- Read the state of the window being drawn and build its statusline.
---@return string
function M.render()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  return M.build {
    head = vim.b[buf].gitsigns_head or '',
    diff = vim.b[buf].gitsigns_status or '',
    -- vim.lsp.status() consumes pending messages, so only the focused window reads it.
    lsp = win == vim.api.nvim_get_current_win() and vim.lsp.status() or '',
    diagnostics = vim.diagnostic.status(buf),
    filetype = vim.bo[buf].filetype,
    fileformat = vim.bo[buf].fileformat,
    fileencoding = vim.bo[buf].fileencoding,
  }
end

return M
