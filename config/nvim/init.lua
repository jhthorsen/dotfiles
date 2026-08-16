vim.pack.add({
  -- { src = "https://github.com/saghen/blink.cmp", version = "v1" },
  -- { src = "https://github.com/fang2hou/blink-copilot" },
  { src = "https://github.com/uga-rosa/ccc.nvim" },
  -- { src = "https://github.com/olimorris/codecompanion.nvim" },
  -- { src = "https://github.com/ravitemer/codecompanion-history.nvim" },
  -- { src = "https://github.com/zbirenbaum/copilot.lua" },
  -- { src = "https://github.com/rafamadriz/friendly-snippets" },
  -- { src = "https://github.com/ravitemer/mcphub.nvim" },
  -- { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/jake-stewart/multicursor.nvim" },
  -- { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  -- { src = "https://github.com/nvim-lua/plenary.nvim" },
  -- { src = "https://github.com/mrcjkb/rustaceanvim" },
  -- { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/jbyuki/venn.nvim" },
  { src = "https://github.com/folke/which-key.nvim" },
})

require("vim._core.ui2").enable({})

----------------------------------------------------------------------------------------------------
-- Basic Options
----------------------------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.netrw_liststyle = 3    -- tree view
vim.g.netrw_banner = 0       -- hide the top banner
vim.g.netrw_winsize = 25     -- fix the left split width
vim.g.netrw_browse_split = 0 -- open files in the previous window
vim.g.netrw_altfile = 1      -- keep the alternate file correct

vim.opt.autoindent = true
vim.opt.backup = false
vim.opt.breakindent = true
vim.opt.cmdheight = 0
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.foldenable = false
vim.opt.hlsearch = false
vim.opt.isfname:append("@-@")
vim.opt.lazyredraw = true
vim.opt.linebreak = true
vim.opt.mouse = ""
vim.opt.number = true
vim.opt.scrolloff = 8
vim.opt.shiftwidth = 2
vim.opt.signcolumn = "yes"
vim.opt.smartindent = true
vim.opt.softtabstop = 2
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.tabstop = 2
vim.opt.wildmode = { "longest:list", "full" }
vim.opt.winborder = "rounded"
vim.opt.wrap = false

----------------------------------------------------------------------------------------------------
-- Functions / Utilities
----------------------------------------------------------------------------------------------------
local smart_close = function()
  local is_terminal = string.match(vim.api.nvim_buf_get_name(0), "term://") ~= nil
  if is_terminal then return vim.cmd("close!") end

  local is_modified = vim.api.nvim_get_option_value("modified", { buf = vim.api.nvim_get_current_buf() })
  if is_modified then vim.api.nvim_command("silent w!") end

  local n_buffers = #vim.fn.getbufinfo({ buflisted = 1 })
  if n_buffers <= 1 then
    vim.api.nvim_command("quit")
  else
    vim.api.nvim_command("bd!")
  end
end

-- @param opts { desc = { }, key = string, mode? = string, is_enabled = function, set = function }
local toggle = function(opts)
  local color = { enabled = "green", disabled = "yellow" }
  local icon = { enabled = " ", disabled = " " }
  local option_map = {
    [true] = false,
    [false] = true,
    ["1"] = "0",
    ["0"] = "1",
    ["yes"] = "no",
    ["no"] = "yes",
    ["true"] = "false",
    ["false"] = "true",
  }

  if opts.option then
    opts.is_enabled = function() return vim.opt[opts.option]:get() end
    opts.set = function(val) vim.opt[opts.option] = option_map[val] end
  end

  vim.keymap.set(
    opts.mode or "n",
    opts.key,
    function() opts.set(opts.is_enabled()) end,
    { desc = opts.desc.disabled }
  )

  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.add({ {
      opts.key,
      mode = opts.mode or "n",
      icon = function()
        local k = opts.is_enabled() and "enabled" or "disabled"
        return {
          icon = opts.icon and opts.icon[k] or icon[k],
          color = opts.color and opts.color[k] or color[k],
        }
      end,
      desc = function()
        local k = opts.is_enabled() and "enabled" or "disabled"
        return opts.desc[k]
      end,
    } })
  end
end

----------------------------------------------------------------------------------------------------
-- Basic Key Bindings
----------------------------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>b", "<cmd>:ls<cr>:b", { silent = true, desc = "Show buffers" })
vim.keymap.set("n", "<leader>nU", function() vim.pack.update() end, { desc = "Update Neovim Plugins" })
vim.keymap.set("n", "<leader>nH", ":checkhealth<cr>", { desc = "Check Neovim Health" })
vim.keymap.set("n", "<s-tab>", "<cmd>bprevious<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<tab>", "<cmd>bnext<cr>", { desc = "Prev Buffer" })

vim.keymap.set("n", "<leader>qa", "<cmd>wqa<cr>", { desc = "Save and Quit All" })
vim.keymap.set("n", "<leader>qs", "<cmd>wa!<cr>", { desc = "Save all open buffers" })
vim.keymap.set({ "n", "t" }, "<leader>qq", smart_close, { desc = "Close Buffer" })
vim.keymap.set({ "n", "t" }, "<leader>qw", "<cmd>close!<cr>", { desc = "Close window" })

vim.keymap.set("n", "<c-h>", ":wincmd h<CR>", { silent = true, desc = "Move to left split" })
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>", { silent = true, desc = "Move to below split" })
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>", { silent = true, desc = "Move to above split" })
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>", { silent = true, desc = "Move to right split" })

vim.keymap.set({ "n", "v" }, "0d", '"_d', { desc = "Delete Line" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent and stay in indent mode" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent and stay in indent mode" })
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'",
  { desc = "Moving the cursor through long soft-wrapped lines", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'",
  { desc = "Moving the cursor through long soft-wrapped lines", expr = true, silent = true })

toggle({
  key = "<leader>nl",
  desc = { enabled = "Absolute Line Numbers", disabled = "Relative Line Numbers" },
  option = "relativenumber",
})

toggle({
  key = "<leader>nS",
  desc = { enabled = "Hide Sign Column", disabled = "Show Sign Column" },
  is_enabled = function() return vim.wo.signcolumn == "yes" end,
  set = function(enabled)
    vim.wo.signcolumn = enabled and "no" or "yes"
    vim.wo.number = not enabled
    vim.wo.relativenumber = not enabled
  end
})

toggle({
  key = "<leader>nw",
  desc = { enabled = "Cut Long Lines", disabled = "Wrap Lines" },
  option = "wrap",
})

----------------------------------------------------------------------------------------------------
-- Color picker
----------------------------------------------------------------------------------------------------
local ccc = require("ccc")
ccc.setup({
  alpha_show = "show",
  highlighter = { auto_enable = true },
  inputs = { ccc.input.oklch, ccc.input.rgb, ccc.input.hsl },
  outputs = { ccc.output.css_hsl, ccc.output.hex, ccc.output.css_oklch },
  convert = {
    { ccc.picker.hex,       ccc.output.css_hsl },
    { ccc.picker.css_hsl,   ccc.output.css_oklch },
    { ccc.picker.css_oklch, ccc.output.hex },
  },
})
vim.keymap.set("n", "<leader>cp", "<cmd>CccPick<cr>", { desc = "Open Color Picker" })
vim.keymap.set("n", "<leader>cP", "<cmd>CccConvert<cr>", { desc = "Convert Color" })

----------------------------------------------------------------------------------------------------
-- Create Parent Directories on Write
----------------------------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(event)
    if not event.match:match("^%w%w+:[\\/][\\/]") then
      local file = vim.uv.fs_realpath(event.match) or event.match
      vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end
  end,
})

----------------------------------------------------------------------------------------------------
-- Fuzzy Find and Grep
----------------------------------------------------------------------------------------------------
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep --smart-case --hidden"

vim.keymap.set("n", "<leader>f", ":find ", { silent = false, desc = "Find files" })
vim.keymap.set("n", "<leader><space>", ":find ", { silent = false, desc = "Find files" })

vim.keymap.set("n", "<leader>g", function()
  vim.ui.input({ prompt = "grep: " }, function(pattern)
    if pattern then
      vim.cmd("silent grep! " .. vim.fn.fnameescape(pattern))
      vim.cmd("copen")
    end
  end)
end, { silent = true, desc = "Grep for files" })

function _G.native_find(text, _)
  local files = vim.fn.glob("**/*", true, true)
  local ignore_patterns = {
    "node_modules",
    "%.git",
    "%.cache",
    "dist",
    "build",
    "%.tmp",
    "%.log",
  }


  local result = {}
  for _, f in ipairs(files) do
    if vim.fn.isdirectory(f) == 0 then
      local skip = false
      for _, pat in ipairs(ignore_patterns) do
        if f:match(pat) then
          skip = true
          break
        end
      end
      if not skip then
        result[#result + 1] = f
      end
    end
  end

  return vim.fn.matchfuzzy(result, text)
end

vim.opt.findfunc = "v:lua.native_find"

----------------------------------------------------------------------------------------------------
-- LSP Setup
----------------------------------------------------------------------------------------------------
vim.cmd("set completeopt+=noselect")
vim.lsp.enable({ "lua_ls", "tsgo" })
vim.diagnostic.config({ virtual_text = true })

vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, { desc = "Code Action" })
vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format() end, { desc = "Format code" })
vim.keymap.set("n", "<leader>cr", function() vim.lsp.buf.rename() end, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>cS", function() vim.lsp.buf.signature_help() end, { desc = "Signature Help" })
vim.keymap.set("n", "gK", function() vim.lsp.buf.signature_help() end, { desc = "Signature Help" })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end,
  { desc = "Displays information about the symbol under the cursor in a floating window" })

toggle({
  key = "<leader>dx",
  desc = { enabled = "Disable Diagnostics", disabled = "Enable Diagnostics" },
  current = function() return vim.diagnostic.is_enabled() end,
  set = function(enabled) vim.diagnostic.enable(not enabled) end,
})

toggle({
  key = "<leader>nh",
  desc = { enabled = "Hide Inlay Hints", disabled = "Show Inlay Hints" },
  current = function() return vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }) end,
  set = function(enabled) vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 }) end,
})

toggle({
  key = "<leader>dv",
  desc = { enabled = "Hide Virtual Lines", disabled = "Show Virtual Lines" },
  current = function() return vim.diagnostic.config().virtual_lines and true or false end,
  set = function(enabled) vim.diagnostic.config({ virtual_lines = not enabled }) end
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client ~= nil and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    if client ~= nil and client:supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.format({ async = false, bufnr = ev.buf, id = client.id })
        end,
      })
    end
  end,
})

----------------------------------------------------------------------------------------------------
-- Multi cursor - Edit with ease
----------------------------------------------------------------------------------------------------
local mc = require("multicursor-nvim")
mc.setup({})

vim.keymap.set({ "n", "x" }, "<c-d>", function() mc.matchAddCursor(1) end, { desc = "Add Next Cursor" })
vim.keymap.set({ "n", "x" }, "<c-s-d>", function() mc.matchAddCursor(-1) end, { desc = "Add Prev Cursor" })
vim.keymap.set({ "n" }, "<leader>mt", mc.toggleCursor, { desc = "Add and Remove Cursors" })
vim.keymap.set({ "n", "v", "x" }, "<leader>ma", mc.alignCursors, { desc = "Align Cursors" })
vim.keymap.set({ "v" }, "<space>mi", "<s-i>", { desc = "Insert Before Selection" })
vim.keymap.set({ "v" }, "<space>ma", "<s-a>", { desc = "Insert After Selection" })

mc.addKeymapLayer(function(mk)
  mk({ "n" }, "<esc>", mc.clearCursors)
  mk({ "v" }, "I", "<c-a>i", { desc = "Insert Before Selection" })
  mk({ "v" }, "A", "<esc>li", { desc = "Insert After Selection" })
  mk({ "v" }, "<space>i", "<c-a>i", { desc = "Insert Before Selection" })
  mk({ "v" }, "<space>a", "<esc>li", { desc = "Insert After Selection" })
end)

----------------------------------------------------------------------------------------------------
-- Quickfixlist
----------------------------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>d", function()
  vim.diagnostic.setqflist({ bufnr = 0, severity = vim.diagnostic.severity.ERROR })
  vim.cmd("copen")
end, { silent = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function(event)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf })
  end,
})

----------------------------------------------------------------------------------------------------
-- Restore Last Position, when Opening a File
----------------------------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

----------------------------------------------------------------------------------------------------
-- Theme
----------------------------------------------------------------------------------------------------
vim.cmd.colorscheme("catppuccin")
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#89b4fa", bg = "NONE" })
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })

----------------------------------------------------------------------------------------------------
-- Venn - Draw ASCII diagrams
----------------------------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>nv", function()
  local venn_enabled = vim.inspect(vim.b.venn_enabled)
  if venn_enabled == "nil" then
    vim.b.venn_enabled = true
    vim.cmd [[setlocal ve=all]]
    vim.api.nvim_buf_set_keymap(0, "n", "J", "<c-v>j:VBox<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "K", "<c-v>k:VBox<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "H", "<c-v>h:VBox<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "L", "<c-v>l:VBox<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>j", "R▼<Esc>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>k", "R▲<Esc>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>h", "R◄<Esc>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>l", "R►<Esc>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", { noremap = true })
  else
    vim.cmd [[setlocal ve=]]
    vim.api.nvim_buf_del_keymap(0, "n", "J")
    vim.api.nvim_buf_del_keymap(0, "n", "K")
    vim.api.nvim_buf_del_keymap(0, "n", "L")
    vim.api.nvim_buf_del_keymap(0, "n", "H")
    vim.api.nvim_buf_del_keymap(0, "v", "f")
    vim.b.venn_enabled = nil
  end
end, { desc = "Draw ASCII diagrams", noremap = true })
