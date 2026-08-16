vim.keymap.set("n", "<leader>cS", ":update<cr>:source %<cr>", { desc = "Source file", buffer = true })
vim.keymap.set("n", "<leader>cX", ":.lua<cr>", { desc = "Source line", buffer = true, silent = true })
vim.keymap.set("v", "<leader>cX", ":lua<cr>", { desc = "Source block", buffer = true, silent = true })
