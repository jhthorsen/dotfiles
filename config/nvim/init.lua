vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp",                    version = "v1" },
  { src = "https://github.com/fang2hou/blink-copilot" },
  { src = "https://github.com/uga-rosa/ccc.nvim" },
  { src = "https://github.com/olimorris/codecompanion.nvim" },
  { src = "https://github.com/ravitemer/codecompanion-history.nvim" },
  { src = "https://github.com/zbirenbaum/copilot.lua" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  { src = "https://github.com/ravitemer/mcphub.nvim" },
  { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/jake-stewart/multicursor.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",     version = "main" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/mrcjkb/rustaceanvim" },
  { src = "https://github.com/jbyuki/venn.nvim" },
  { src = "https://github.com/folke/which-key.nvim" },
})

require("vim._core.ui2").enable({})
require("plenary") -- Used by CodeCompanion

----------------------------------------------------------------------------------------------------
-- Basic Options
----------------------------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.netrw_liststyle = 3                     -- tree view
vim.g.netrw_banner = 0                        -- hide the top banner
vim.g.netrw_winsize = 25                      -- fix the left split width
vim.g.netrw_browse_split = 0                  -- open files in the previous window
vim.g.netrw_altfile = 1                       -- keep the alternate file correct

vim.opt.autoindent = true                     -- keep indentation from previous line
vim.opt.backup = false                        -- don't create backup files
vim.opt.breakindent = true                    -- preserve indent when wrapping lines
vim.opt.clipboard = "unnamedplus"             -- use system clipboard
vim.opt.cmdheight = 0                         -- hide command line when not used
vim.opt.expandtab = true                      -- convert tabs to spaces
vim.opt.foldenable = false                    -- disable code folding
vim.opt.hlsearch = false                      -- don't highlight search matches
vim.opt.isfname:append("@-@")                 -- treat @-@ as filename characters
vim.opt.lazyredraw = true                     -- redraw only when needed (faster macros)
vim.opt.linebreak = true                      -- wrap lines at word boundaries
vim.opt.mouse = ""                            -- disable mouse support
vim.opt.number = true                         -- show line numbers
vim.opt.scrolloff = 8                         -- keep 8 lines visible above/below cursor
vim.opt.shiftwidth = 2                        -- indent width for << and >>
vim.opt.showcmd = false                       -- don't show command in statusline
vim.opt.signcolumn = "yes"                    -- always show sign column
vim.opt.smartindent = true                    -- smarter auto-indentation
vim.opt.softtabstop = 2                       -- number of spaces per tab in insert mode
vim.opt.splitbelow = true                     -- open horizontal splits below
vim.opt.splitright = true                     -- open vertical splits to the right
vim.opt.swapfile = false                      -- disable swapfile creation
vim.opt.tabstop = 2                           -- number of spaces a tab counts for
vim.opt.timeoutlen = 250                      -- time to wait for mapped sequence
vim.opt.undofile = true                       -- persistent undo across sessions
vim.opt.virtualedit = "block"                 -- allow cursor anywhere in visual block mode
vim.opt.wildmode = { "longest:list", "full" } -- enhanced command-line completion
vim.opt.winborder = "rounded"                 -- rounded window borders
vim.opt.wrap = false                          -- disable line wrapping

----------------------------------------------------------------------------------------------------
-- Functions / Utilities
----------------------------------------------------------------------------------------------------
local edit_scratch_window = function(lines, on_close)
  local buf = vim.api.nvim_create_buf(false, true) -- listed=false, scratch=true
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(event)
      if tonumber(event.match) == win then
        on_close(vim.api.nvim_buf_get_lines(buf, 0, -1, false))
      end
    end,
  })
end

local get_lsp_client = function(name)
  for _, l in ipairs(vim.lsp.get_clients()) do
    if l and l.name == name then
      return l
    end
  end
  return nil
end

local smart_close = function()
  local is_terminal = string.match(vim.api.nvim_buf_get_name(0), "term://") ~= nil
  if is_terminal then return vim.cmd("close!") end

  local is_modified = vim.api.nvim_get_option_value("modified", { buf = vim.api.nvim_get_current_buf() })
  if is_modified then vim.api.nvim_command("silent w!") end

  local n_buffers = #vim.fn.getbufinfo({ buflisted = 1 })
  if n_buffers <= 1 then
    vim.api.nvim_command("quit")
  else
    require("mini.bufremove").delete()
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
vim.keymap.set("n", "<leader>nR", "<cmd>restart<cr>", { desc = "Restart Neovim" })
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
-- Basic plugin - mini.nvim
-- TODO:
-- * <leader>nn = List notifications
-- * <leader>nI = List icons
----------------------------------------------------------------------------------------------------
local MiniPick = require("mini.pick")

require("mini.align").setup({})
require("mini.colors").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.pick").setup({
  mappings = {
    move_down = "<c-j>",
    move_up   = "<c-k>",
  },
})
require("mini.surround").setup({})
require("mini.statusline").setup({})

vim.keymap.set("n", ",e", function() require("mini.files").open(vim.api.nvim_buf_get_name(0)) end,
  { desc = "Find and Edit" })
vim.keymap.set("n", "<leader>fe", function() require("mini.files").open() end, { desc = "Open File Explorer" })

vim.keymap.set("n", "<leader><space>", function() MiniPick.builtin.files() end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>b", function() MiniPick.builtin.buffers() end, { desc = "Switch Buffer" })
vim.keymap.set("n", "<leader>ff", function() MiniPick.builtin.files() end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", function() MiniPick.builtin.grep_live() end, { desc = "Grep Project Files" })
vim.keymap.set("n", "<leader>fx",
  function() MiniPick.builtin.files({}, { source = { cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":h") } }) end,
  { desc = "Find Parent Files" })

vim.keymap.set("n", "z=", function() require("mini.extra").pickers.spellsuggest() end, { desc = "Search Colorschemes" })
vim.keymap.set("n", "<leader>nC", function() require("mini.extra").pickers.colorschemes() end,
  { desc = "Search Colorschemes" })
vim.keymap.set("n", "<leader>nf", function() require("mini.misc").zoom() end, { desc = "Fullscreen Window" })

vim.keymap.set("n", '<leader>nr', function()
  local items = {}
  for _, regname in ipairs(vim.split('"*+/=-0123456789abcdefghijklmnopqrstuvwxyz', "")) do
    local _, regval = pcall(vim.fn.getreg, regname, 1)
    local text = string.format('%s │ %s', regname, regval or "")
    table.insert(items, { prompt = "Edit register: ", regname = regname, default = regval, text = text })
  end

  MiniPick.start({
    source = {
      items = items,
      name = "Registers",
      choose = function(item)
        MiniPick.stop()
        if item == nil then return end
        vim.schedule(function()
          vim.cmd("split")
          edit_scratch_window({ item.default }, function(lines)
            vim.fn.setreg(item.regname, table.concat(lines, "\n"))
          end)
        end)
      end
    }
  })
end, { desc = "Edit Register" })

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesWindowUpdate",
  callback = function(ev)
    local win_id = ev.data.win_id
    vim.wo[win_id].winblend = 1
    local config = vim.api.nvim_win_get_config(win_id)
    config.relative = "laststatus"
    config.height = 16
    vim.api.nvim_win_set_config(win_id, config)
  end,
})

----------------------------------------------------------------------------------------------------
-- Basic plugin - WhichKey
----------------------------------------------------------------------------------------------------
require("which-key").setup({
  preset = "helix",
  expand = function(node)
    local children = node:count()
    return node:can_expand() == false and children > 0 and children <= 2
  end,
  sort = { "group", "alphanum" },
  plugins = {
    marks = true,
    registers = false,
    spelling = { enabled = false },
    presets = {
      g = true,
      motions = true,
      nav = true,
      operators = true,
      text_objects = true,
      windows = true,
      z = true,
    },
  },
})

require("which-key.plugins.presets").operators["v"] = nil
require("which-key").add({
  { "<leader>h", function() require("which-key").show() end, icon = "🎹", desc = "Show All Keys" },
  { "<leader>c", group = "Code...", icon = "󰅩" },
  { "<leader>d", group = "Diagnostics...", icon = "󰒡" },
  { "<leader>f", group = "Files...", icon = "󰈔" },
  { "<leader>m", group = "Multicursors...", icon = "󰘞" },
  { "<leader>n", group = "Neovim...", icon = "" },
  { "<leader>q", group = "Quit...", icon = "󰩈" },
})

----------------------------------------------------------------------------------------------------
-- Blink - Autocomplete
----------------------------------------------------------------------------------------------------
require("blink.cmp").setup({
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 750 },
    menu = {
      draw = {
        columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
        treesitter = { "lsp" }
      },
    },
  },
  keymap = {
    preset = "default",
    ["<tab>"] = { function(ctx) return ctx.select_next() end, "fallback" },
    ["<s-tab>"] = { function(ctx) return ctx.select_prev() end, "fallback" },
    ["<cr>"] = {
      function(ctx)
        local item = ctx.get_selected_item() or {}
        if item.source_id == "copilot" then return ctx.select_and_accept() end
        if item.source_id == "snippets" then return ctx.select_and_accept() end

        local col = vim.api.nvim_win_get_cursor(0)[2]
        if col == 0 then return nil end

        local line = vim.api.nvim_get_current_line()
        local word_before = line:sub(col, col):match("[%w_.]")
        if word_before ~= nil then return ctx.select_and_accept() end
      end,
      "fallback",
    },
  },
  sources = {
    default = {
      "buffer",
      "lsp",
      "snippets",
      "path",
      "copilot",
      "codecompanion",
    },
    providers = {
      codecompanion = {
        name = "CodeCompanion",
        module = "codecompanion.providers.completion.blink",
      },
      copilot = {
        name = "copilot",
        module = "blink-copilot",
        min_keyword_length = 2,
        async = true,
        score_offset = 50,
        opts = {
          debounce = 500,
          max_completions = 2,
          max_attempts = 2,
        },
      },
    },
  },
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
-- LLM - Codecompanion, Copilot and MCP client
----------------------------------------------------------------------------------------------------
local codecompanion_adapter = {
  name = string.match(vim.api.nvim_buf_get_name(0) or "", "([^/]+)%.ai$") or vim.env.CODECOMPANION_ADAPTER or "copilot",
  model = vim.env.CODECOMPANION_MODEL or "gpt-5.6-terra",
}

vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "CodeCompanion Chat" })
vim.keymap.set("n", "<leader>cH", "<cmd>CodeCompanionHistory<cr>", { desc = "CodeCompanion History" })
vim.keymap.set("n", "<leader>cs", "<cmd>CodeCompanionSummaries<cr>", { desc = "CodeCompanion Summaries" })
vim.keymap.set("v", "<leader>ce", "<cmd>CodeCompanion /explain<cr>", { desc = "Explain Code" })
vim.keymap.set("v", "<leader>cf", "<cmd>CodeCompanion /fix<cr>", { desc = "Fix Code" })
vim.keymap.set("n", "<leader>cl", "<cmd>CodeCompanion /lsp<cr>", { desc = "Explain The LSP Diagnostics" })
vim.keymap.set("v", "<leader>ct", "<cmd>CodeCompanion /tests<cr>", { desc = "Generte Tests" })

require("copilot").setup({
  suggestion = { debounce = 350 },
  should_attach = function(_, bufname)
    if string.match(bufname, ".env") then return false end
    if string.match(bufname, "_alien") then return false end
    return true
  end
})

require("codecompanion._extensions.history")
require("codecompanion").setup({
  display = { chat = { window = { opts = { number = false, relativenumber = false, signcolumn = "no" } } } },
  extensions = {
    history = { enabled = true },
  },
  interactions = {
    chat = { adapter = codecompanion_adapter },
    inline = { adapter = codecompanion_adapter },
  },
})

require("mcphub").setup({})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost", "VimResized" }, {
  callback = function()
    local config = require("codecompanion.config").config
    local codecompanion_adapter_name = string.match(vim.api.nvim_buf_get_name(0) or "", "([^/]+)%.ai$")

    if codecompanion_adapter_name then
      config.display.chat.window.layout = "buffer"
      vim.cmd("CodeCompanionChat")
    elseif vim.o.columns > 200 then
      config.display.chat.window.width = 0.4
      config.display.chat.window.layout = "vertical"
      config.display.chat.window.position = "right"
    else
      config.display.chat.window.height = 0.7
      config.display.chat.window.layout = "horizontal"
      config.display.chat.window.position = "bottom"
    end
  end
})

----------------------------------------------------------------------------------------------------
-- LSP Setup
----------------------------------------------------------------------------------------------------
vim.diagnostic.config({
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.HINT] = ">",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.WARN] = "⚠️",
      [vim.diagnostic.severity.ERROR] = "‼️",
    },
  },
})

vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, { desc = "Code Action" })
vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format() end, { desc = "Format code" })
vim.keymap.set("n", "<leader>cr", function() vim.lsp.buf.rename() end, { desc = "Rename symbol" })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { desc = "Info about the symbol" })

toggle({
  key = "<leader>ng",
  desc = { enabled = "Disable Grammar LSP", disabled = "Enable Grammar LSP" },
  is_enabled = function() return get_lsp_client("harper_ls") and true or false end,
  set = function(enabled) vim.lsp.enable("harper_ls", not enabled) end
})

toggle({
  key = "<leader>dv",
  desc = { enabled = "Hide Virtual Lines", disabled = "Show Virtual Lines" },
  is_enabled = function() return vim.diagnostic.config().virtual_lines and true or false end,
  set = function(enabled) vim.diagnostic.config({ virtual_lines = not enabled }) end
})

toggle({
  key = "<leader>dV",
  desc = { enabled = "Hide Virtual Text", disabled = "Show Virtual Text" },
  is_enabled = function() return vim.diagnostic.config().virtual_lines and true or false end,
  set = function(enabled) vim.diagnostic.config({ virtual_text = not enabled }) end
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
          if vim.b.allow_autocmd_format == true then
            vim.lsp.buf.format({ async = false, bufnr = ev.buf, id = client.id })
          end
        end,
      })
    end
  end,
})

vim.g.rustaceanvim = function()
  local features = {}
  for _, feature in ipairs(vim.split(vim.env.RUST_FEATURES or "", ",")) do
    if feature ~= "" then table.insert(features, feature) end
  end

  return {
    server = {
      default_settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = false,
            features = features,
            loadOutDirsFromCheck = false,
          },
          check = { features = features },
          inlayHints = { enable = false },
          procMacos = { enable = true },
        },
      },
    },
  }
end

-- https://github.com/neovim/nvim-lspconfig/tree/master/lsp
vim.lsp.enable({ "bashls" })                -- sh: pnpm install -g bash-language-server
vim.lsp.enable({ "css_variables" })         -- sh: pnpm install -g css-variable-ls
vim.lsp.enable({ "cssls" })                 -- sh: pnpm install -g vscode-langservers-extracted
vim.lsp.enable({ "cssmodules_ls" })         -- sh: pnpm install -g cssmodules-language-server
vim.lsp.enable({ "denols" })                -- sh: brew install deno
vim.lsp.enable({ "dprint" })                -- sh: cargo install dprint
vim.lsp.enable({ "emmet_language_server" }) -- sh: pnpm install -g emmet-language-server
vim.lsp.enable({ "gopls" })                 -- sh: brew install gopls
vim.lsp.enable({ "harper_ls" })             -- sh: brew install harper
vim.lsp.enable({ "html" })                  -- sh: pnpm install -g vscode-langservers-extracted
vim.lsp.enable({ "jinja_lsp" })             -- sh: cargo install jinja-lsp
vim.lsp.enable({ "jsonls" })                -- sh: pnpm install -g vscode-langservers-extracted
vim.lsp.enable({ "lua_ls" })                -- sh: brew install lua-language-server
vim.lsp.enable({ "marksman" })              -- sh: brew install marksman
vim.lsp.enable({ "perlnavigator" })         -- sh: pnpm install -g perlnavigator-server
vim.lsp.enable({ "sqlls" })                 -- sh: pnpm install -g sql-language-server
vim.lsp.enable({ "svelte" })                -- sh: pnpm install -g svelte-language-server
vim.lsp.enable({ "systemd_lsp" })           -- sh: pnpm install -g systemd-language-server
vim.lsp.enable({ "yamlls" })                -- sh: pnpm install -g yaml-language-server

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
vim.keymap.set("n", "<leader>de", function()
  vim.diagnostic.setqflist({ bufnr = 0, severity = vim.diagnostic.severity.ERROR })
  vim.cmd("copen")
end, { silent = true, desc = "Send errors to quickfix list" })

vim.keymap.set("n", "<leader>da", function()
  vim.diagnostic.setqflist({ bufnr = 0 })
  vim.cmd("copen")
end, { silent = true, desc = "Send diagnostics to quickfix list" })

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
-- Treesitter - https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
----------------------------------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.html", "*.html.j2" },
  callback = function()
    vim.bo.filetype = "html"
  end,
})

require("nvim-treesitter").install({
  "bash",
  "css",
  "gitcommit",
  "go",
  "html",
  "javascript",
  "jinja",
  "markdown",
  "perl",
  "python",
  "rust",
  "sql",
  "svelte",
  "yaml",
})

----------------------------------------------------------------------------------------------------
-- Theme
----------------------------------------------------------------------------------------------------
vim.cmd.colorscheme("catppuccin")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#89b4fa", bg = "#181825" })
vim.api.nvim_set_hl(0, "FloatNormal", { fg = "#89b4fa", bg = "#181825" })
vim.api.nvim_set_hl(0, "MiniFilesBorder", { fg = "#89b4fa", bg = "#181825" })
vim.api.nvim_set_hl(0, "MiniFilesNormal", { bg = "#181825" })

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
