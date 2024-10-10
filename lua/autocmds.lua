local fn = vim.fn
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Auto-create dir when saving a file, in case some intermediate directory does not exist
autocmd({ "BufWritePre" }, {
  pattern = "*",
  group = augroup("auto_create_dir", { clear = true }),
  callback = function(ctx)
    local dir = fn.fnamemodify(ctx.file, ":p:h")
    if fn.isdirectory(dir) == 0 then
      fn.mkdir(dir, "p")
    end
  end,
})

-- Automatically reload the file if it is changed outside of Nvim, see https://unix.stackexchange.com/a/383044/221410.
-- It seems that `checktime` does not work in command line. We need to check if we are in command
-- line before executing this command, see also https://vi.stackexchange.com/a/20397/15292 .
augroup("auto_read", { clear = true })

autocmd({ "FileChangedShellPost" }, {
  pattern = "*",
  group = "auto_read",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded!", vim.log.levels.WARN, { title = "nvim-config" })
  end,
})

autocmd({ "FocusGained", "CursorHold" }, {
  pattern = "*",
  group = "auto_read",
  callback = function()
    if fn.getcmdwintype() == "" then vim.cmd("checktime")
    end
  end,
})

-- Remove whitespace on save
autocmd('BufWritePre', {
  pattern = '',
  command = ":%s/\\s\\+$//e"
})

-- Resize all windows when we resize the terminal
autocmd("VimResized", {
  group = augroup("win_autoresize", { clear = true }),
  desc = "autoresize windows on resizing operation",
  command = "wincmd =",
})

-- Return to last cursor position when opening a file, note that here we cannot use BufReadPost
-- as event. It seems that when BufReadPost is triggered, FileType event is still not run.
-- So the filetype for this buffer is empty string.
autocmd("FileType", {
  group = augroup("resume_cursor_position", { clear = true }),
  pattern = "*",
  callback = function(ev)
    local mark_pos = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local last_cursor_line = mark_pos[1]

    local max_line = vim.fn.line("$")
    local buf_filetype = vim.api.nvim_get_option_value("filetype", { buf = ev.buf })
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = ev.buf })

    -- only handle normal files
    if buf_filetype == "" or buftype ~= "" then
      return
    end

    -- Only resume last cursor position when there is no go-to-line command (something like '+23').
    if vim.fn.match(vim.v.argv, [[\v^\+(\d){1,}$]]) ~= -1 then
      return
    end

    if last_cursor_line > 1 and last_cursor_line <= max_line then
      -- vim.print(string.format("mark_pos: %s", vim.inspect(mark_pos)))
      -- it seems that without vim.schedule, the cursor position can not be set correctly
      vim.schedule(function()
        local status, result = pcall(vim.api.nvim_win_set_cursor, 0, mark_pos)
        if not status then
          vim.api.nvim_err_writeln(string.format("Failed to resume cursor position. Context %s, error: %s",
          vim.inspect(ev), result))
        end
      end)
      -- the following two ways also seem to work,
      -- ref: https://www.reddit.com/r/neovim/comments/104lc26/how_can_i_press_escape_key_using_lua/
      -- vim.api.nvim_feedkeys("g`\"", "n", true)
      -- vim.fn.execute("normal! g`\"")
    end
  end,
})

local number_toggle_group = vim.api.nvim_create_augroup("numbertoggle", { clear = true })
autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  pattern = "*",
  group = number_toggle_group,
  desc = "togger line number",
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = true
    end
  end,
})

autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = number_toggle_group,
  desc = "togger line number",
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
    end
  end,
})
