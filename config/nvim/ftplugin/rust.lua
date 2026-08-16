local function rust_lsp(action)
  return function() vim.cmd.RustLsp(action) end
end

vim.keymap.set("n", "K", rust_lsp({"hover", "actions"}), { desc = "RustLsp hover actions", silent = true, buffer = true })
vim.keymap.set("n", "<a-j>", rust_lsp({"moveItem",  "down"}), { desc = "RustLsp moveItem down", silent = true, buffer = true })
vim.keymap.set("n", "<a-k>", rust_lsp({"moveItem",  "up"}), { desc = "RustLsp moveItem up", silent = true, buffer = true })
vim.keymap.set("n", "<leader>a", rust_lsp("codeAction"), { desc = "Code Actions", silent = true, buffer = true })
vim.keymap.set("n", "<leader>cC", rust_lsp("openCargo"), { desc = "Open Cargo.toml", silent = true, buffer = true })
vim.keymap.set("n", "<leader>ce", rust_lsp("expandMacro"), { desc = "Expand Macro", silent = true, buffer = true })
vim.keymap.set("n", "<leader>cE", rust_lsp("explainError"), { desc = "Explain Error", silent = true, buffer = true })
vim.keymap.set("n", "<leader>cH", rust_lsp({ "view", "hir" }), { desc = "Open HIR Representation", silent = true, buffer = true })
vim.keymap.set("n", "<leader>cP", rust_lsp("parentModule"), { desc = "Open Parent Module", buffer = true })
vim.keymap.set("n", "<leader>cT", rust_lsp({ "testables" }), { desc = "Select and Run Test", buffer = true })
vim.keymap.set("n", "<leader>ct", rust_lsp({ "testables", bang = true }), { desc = "Select or Run Previous Test", buffer = true })

if vim.b.allow_autocmd_format == nil then vim.b.allow_autocmd_format = true end
